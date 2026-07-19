import express from 'express';
import cors from 'cors';
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { eq, asc } from 'drizzle-orm';
import { db } from './db/drizzle.js';
import { users, surveys, familyMembers, wilayahSangihe } from './db/schema.js';
import { requireAuth, AuthenticatedRequest } from './middleware/auth.js';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || '';

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Handle cPanel subpath proxying
app.use((req, res, next) => {
  if (req.url.startsWith('/backend-form')) {
    req.url = req.url.substring('/backend-form'.length) || '/';
  }
  next();
});

app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// ── Auth ───────────────────────────────────────────────────────────────────

app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, desa, kecamatan, kabupaten, nama, role } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const existing = await db.select({ id: users.id }).from(users).where(eq(users.email, email)).limit(1);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'User with this email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = crypto.randomUUID();

    const emailPrefix = email.split('@')[0] || '';
    const nameParts = emailPrefix.split('.');
    const defaultNama = nameParts
      .map((p: string) => p.length === 0 ? '' : p[0].toUpperCase() + p.substring(1))
      .join(' ');

    await db.insert(users).values({
      id: userId,
      email,
      password: hashedPassword,
      desa: desa || '',
      kecamatan: kecamatan || '',
      kabupaten: kabupaten || '',
      nama: nama || defaultNama,
      role: role || 'Pencacah',
    });

    res.status(201).json({ message: 'User registered successfully', userId });
  } catch (error: any) {
    console.error('Registration Error:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.post('/api/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    const result = await db.select().from(users).where(eq(users.email, email)).limit(1);
    if (result.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = result[0];
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (!JWT_SECRET) {
      console.error('ERROR: JWT_SECRET is not configured.');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    const token = jwt.sign(
      { sub: user.id, email: user.email, desa: user.desa, kecamatan: user.kecamatan, kabupaten: user.kabupaten, nama: user.nama, role: user.role },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: { id: user.id, email: user.email, desa: user.desa, kecamatan: user.kecamatan, kabupaten: user.kabupaten, nama: user.nama, role: user.role },
    });
  } catch (error: any) {
    console.error('Login Error:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// ── Protected routes ───────────────────────────────────────────────────────

app.use('/api', requireAuth);

app.get('/api/profile', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const result = await db.select().from(users).where(eq(users.id, userId)).limit(1);
    if (result.length === 0) return res.status(404).json({ error: 'Profile not found' });

    const { password: _pw, ...profile } = result[0];
    res.json(profile);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.post('/api/profile', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });
    const { desa, kecamatan, kabupaten, nama, role } = req.body;

    const existing = await db.select({ id: users.id, email: users.email }).from(users).where(eq(users.id, userId)).limit(1);
    if (existing.length > 0) {
      const updateData: any = { 
        desa: desa || '', 
        kecamatan: kecamatan || '', 
        kabupaten: kabupaten || '', 
        updatedAt: new Date() 
      };
      if (nama !== undefined) updateData.nama = nama;
      if (role !== undefined) updateData.role = role;

      await db.update(users)
        .set(updateData)
        .where(eq(users.id, userId));
      res.json({ message: 'Profile updated successfully' });
    } else {
      const email = req.user?.email || '';
      const emailPrefix = email.split('@')[0] || '';
      const nameParts = emailPrefix.split('.');
      const defaultNama = nameParts
        .map((p: string) => p.length === 0 ? '' : p[0].toUpperCase() + p.substring(1))
        .join(' ');

      await db.insert(users).values({
        id: userId,
        email: email,
        password: '',
        desa: desa || '',
        kecamatan: kecamatan || '',
        kabupaten: kabupaten || '',
        nama: nama || defaultNama,
        role: role || 'Pencacah',
      });
      res.status(201).json({ message: 'Profile created successfully' });
    }
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.get('/api/wilayah', async (req: AuthenticatedRequest, res) => {
  try {
    const list = await db.select().from(wilayahSangihe);
    res.json(list);
  } catch (error: any) {
    console.error('Error fetching wilayah:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.get('/api/surveys', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const userSurveys = await db.select().from(surveys).where(eq(surveys.userId, userId));

    const result = await Promise.all(
      userSurveys.map(async (survey) => {
        const members = await db
          .select()
          .from(familyMembers)
          .where(eq(familyMembers.surveyId, survey.id))
          .orderBy(asc(familyMembers.noUrut));
        return { ...survey, familyMembers: members };
      })
    );

    res.json(result);
  } catch (error: any) {
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.post('/api/surveys', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const { familyMembers: membersData, ...surveyData } = req.body;
    const surveyId = surveyData.id || crypto.randomUUID();

    await db.insert(surveys).values({ ...surveyData, id: surveyId, userId });

    if (Array.isArray(membersData) && membersData.length > 0) {
      await db.insert(familyMembers).values(
        membersData.map((m: any) => ({ ...m, id: m.id || crypto.randomUUID(), surveyId }))
      );
    }

    res.status(201).json({ message: 'Survey created successfully', id: surveyId });
  } catch (error: any) {
    console.error('Error creating survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.put('/api/surveys/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const surveyId = req.params.id;
    const { familyMembers: membersData, ...surveyData } = req.body;

    const existing = await db.select({ userId: surveys.userId }).from(surveys).where(eq(surveys.id, surveyId)).limit(1);
    if (existing.length === 0) return res.status(404).json({ error: 'Survey not found' });
    if (existing[0].userId !== userId) return res.status(403).json({ error: 'Forbidden' });

    await db.update(surveys).set({ ...surveyData, updatedAt: new Date() }).where(eq(surveys.id, surveyId));
    await db.delete(familyMembers).where(eq(familyMembers.surveyId, surveyId));

    if (Array.isArray(membersData) && membersData.length > 0) {
      await db.insert(familyMembers).values(
        membersData.map((m: any) => ({ ...m, id: m.id || crypto.randomUUID(), surveyId }))
      );
    }

    res.json({ message: 'Survey updated successfully', id: surveyId });
  } catch (error: any) {
    console.error('Error updating survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.delete('/api/surveys/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const surveyId = req.params.id;

    const existing = await db.select({ userId: surveys.userId }).from(surveys).where(eq(surveys.id, surveyId)).limit(1);
    if (existing.length === 0) return res.status(404).json({ error: 'Survey not found' });
    if (existing[0].userId !== userId) return res.status(403).json({ error: 'Forbidden' });

    await db.delete(familyMembers).where(eq(familyMembers.surveyId, surveyId));
    await db.delete(surveys).where(eq(surveys.id, surveyId));

    res.json({ message: 'Survey deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.listen(Number(port), '0.0.0.0', () => {
  console.log(`Server running on port ${port} (Listening on all interfaces)`);
});
