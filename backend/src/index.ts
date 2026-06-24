import express from 'express';
import cors from 'cors';
import crypto from 'crypto';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { supabase } from './db/supabase.js';
import { requireAuth, AuthenticatedRequest } from './middleware/auth.js';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || process.env.SUPABASE_JWT_SECRET || '';

app.use(cors());
app.use(express.json({ limit: '10mb' })); // Support base64 image strings if needed

// Handle cPanel subpath passenger proxying (e.g. /backend-form prefix)
app.use((req, res, next) => {
  if (req.url.startsWith('/backend-form')) {
    req.url = req.url.substring('/backend-form'.length);
    if (req.url === '') req.url = '/';
  }
  next();
});

// Helper functions for mapping JSON keys between camelCase (Flutter) and snake_case (Postgres DB)
function camelToSnake(str: string): string {
  return str
    .replace(/([a-z0-9])([A-Z])/g, '$1_$2')
    .replace(/([a-zA-Z])([0-9])/g, '$1_$2')
    .toLowerCase();
}

function snakeToCamel(str: string): string {
  return str.replace(/_([a-zA-Z0-9])/g, (_, letter) => letter.toUpperCase());
}

function mapKeys(obj: any, fn: (str: string) => string): any {
  if (obj === null || obj === undefined) return obj;
  if (Array.isArray(obj)) {
    return obj.map(item => mapKeys(item, fn));
  }
  if (typeof obj === 'object') {
    return Object.keys(obj).reduce((acc: any, key) => {
      const val = obj[key];
      const newKey = fn(key);
      acc[newKey] = mapKeys(val, fn);
      return acc;
    }, {});
  }
  return obj;
}

// Healthcheck
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date() });
});

// Public Auth Endpoints
app.post('/api/auth/register', async (req, res) => {
  try {
    const { email, password, desa, kecamatan, kabupaten } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Check if user already exists
    const { data: existing, error: selectError } = await supabase
      .from('form-descan-users')
      .select('id')
      .eq('email', email)
      .limit(1);

    if (selectError) throw selectError;

    if (existing && existing.length > 0) {
      return res.status(400).json({ error: 'User with this email already exists' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    const userId = crypto.randomUUID();

    // Insert user
    const { error: insertError } = await supabase
      .from('form-descan-users')
      .insert({
        id: userId,
        email,
        password: hashedPassword,
        desa: desa || '',
        kecamatan: kecamatan || '',
        kabupaten: kabupaten || '',
      });

    if (insertError) throw insertError;

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

    // Find user
    const { data: existing, error: selectError } = await supabase
      .from('form-descan-users')
      .select('*')
      .eq('email', email)
      .limit(1);

    if (selectError) throw selectError;

    if (!existing || existing.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = existing[0];

    // Check password
    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    if (!JWT_SECRET) {
      console.error('ERROR: JWT_SECRET or SUPABASE_JWT_SECRET is not configured on the server.');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    // Sign JWT
    const token = jwt.sign(
      {
        sub: user.id,
        email: user.email,
        desa: user.desa,
        kecamatan: user.kecamatan,
        kabupaten: user.kabupaten,
      },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        desa: user.desa,
        kecamatan: user.kecamatan,
        kabupaten: user.kabupaten,
      }
    });
  } catch (error: any) {
    console.error('Login Error:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// Secure Survey Endpoints
app.use('/api', requireAuth);

// 0. Get user profile details
app.get('/api/profile', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const { data: result, error: selectError } = await supabase
      .from('form-descan-users')
      .select('*')
      .eq('id', userId)
      .limit(1);

    if (selectError) throw selectError;

    if (!result || result.length === 0) {
      return res.status(404).json({ error: 'Profile not found' });
    }
    
    // Map back to camelCase for client
    res.json(mapKeys(result[0], snakeToCamel));
  } catch (error: any) {
    console.error('Error fetching profile:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// Update/Create user profile
app.post('/api/profile', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const { email, desa, kecamatan, kabupaten } = req.body;

    const { data: existing, error: selectError } = await supabase
      .from('form-descan-users')
      .select('id')
      .eq('id', userId)
      .limit(1);

    if (selectError) throw selectError;

    if (existing && existing.length > 0) {
      const { error: updateError } = await supabase
        .from('form-descan-users')
        .update({
          desa: desa || '',
          kecamatan: kecamatan || '',
          kabupaten: kabupaten || '',
          updated_at: new Date().toISOString()
        })
        .eq('id', userId);

      if (updateError) throw updateError;
      res.json({ message: 'Profile updated successfully' });
    } else {
      const { error: insertError } = await supabase
        .from('form-descan-users')
        .insert({
          id: userId,
          email: email || req.user?.email || '',
          password: '', // Placeholder password, not usable for login
          desa: desa || '',
          kecamatan: kecamatan || '',
          kabupaten: kabupaten || '',
        });

      if (insertError) throw insertError;
      res.status(201).json({ message: 'Profile created successfully' });
    }
  } catch (error: any) {
    console.error('Error saving profile:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// 1. Get all surveys for user
app.get('/api/surveys', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    // Fetch surveys
    const { data: userSurveys, error: surveysError } = await supabase
      .from('form-descan-surveys')
      .select('*')
      .eq('user_id', userId);

    if (surveysError) throw surveysError;

    // Fetch family members for each survey
    const result = [];
    if (userSurveys) {
      for (const survey of userSurveys) {
        const { data: members, error: membersError } = await supabase
          .from('form-descan-family_members')
          .select('*')
          .eq('survey_id', survey.id)
          .order('no_urut', { ascending: true });

        if (membersError) throw membersError;

        result.push(
          mapKeys({
            ...survey,
            familyMembers: members || [],
          }, snakeToCamel)
        );
      }
    }

    res.json(result);
  } catch (error: any) {
    console.error('Error fetching surveys:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// 2. Create survey with family members
app.post('/api/surveys', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const { familyMembers: membersData, ...surveyData } = req.body;
    const surveyId = surveyData.id || crypto.randomUUID();

    // Map keys to snake_case
    const dbSurveyData = mapKeys({
      ...surveyData,
      id: surveyId,
      userId: userId,
    }, camelToSnake);

    // 1. Insert survey
    const { error: surveyError } = await supabase
      .from('form-descan-surveys')
      .insert(dbSurveyData);

    if (surveyError) throw surveyError;

    // 2. Insert family members
    if (membersData && Array.isArray(membersData) && membersData.length > 0) {
      const dbMembersData = membersData.map((member) => mapKeys({
        ...member,
        id: member.id || crypto.randomUUID(),
        surveyId: surveyId,
      }, camelToSnake));

      const { error: membersError } = await supabase
        .from('form-descan-family_members')
        .insert(dbMembersData);

      if (membersError) {
        // Rollback survey insert to keep DB consistent
        await supabase.from('form-descan-surveys').delete().eq('id', surveyId);
        throw membersError;
      }
    }

    res.status(201).json({ message: 'Survey created successfully', id: surveyId });
  } catch (error: any) {
    console.error('Error creating survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// 3. Update survey
app.put('/api/surveys/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const surveyId = req.params.id;
    const { familyMembers: membersData, ...surveyData } = req.body;

    // Verify ownership
    const { data: existing, error: selectError } = await supabase
      .from('form-descan-surveys')
      .select('user_id')
      .eq('id', surveyId)
      .limit(1);

    if (selectError) throw selectError;

    if (!existing || existing.length === 0) {
      return res.status(404).json({ error: 'Survey not found' });
    }
    if (existing[0].user_id !== userId) {
      return res.status(403).json({ error: 'Forbidden: You do not own this survey' });
    }

    // Map survey fields to snake_case
    const dbSurveyData = mapKeys({
      ...surveyData,
      updatedAt: new Date().toISOString(),
    }, camelToSnake);

    // 1. Update survey fields
    const { error: updateSurveyError } = await supabase
      .from('form-descan-surveys')
      .update(dbSurveyData)
      .eq('id', surveyId);

    if (updateSurveyError) throw updateSurveyError;

    // 2. Delete existing members
    const { error: deleteMembersError } = await supabase
      .from('form-descan-family_members')
      .delete()
      .eq('survey_id', surveyId);

    if (deleteMembersError) throw deleteMembersError;

    // 3. Insert new member records
    if (membersData && Array.isArray(membersData) && membersData.length > 0) {
      const dbMembersData = membersData.map((member) => mapKeys({
        ...member,
        id: member.id || crypto.randomUUID(),
        surveyId: surveyId,
      }, camelToSnake));

      const { error: insertMembersError } = await supabase
        .from('form-descan-family_members')
        .insert(dbMembersData);

      if (insertMembersError) throw insertMembersError;
    }

    res.json({ message: 'Survey updated successfully', id: surveyId });
  } catch (error: any) {
    console.error('Error updating survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

// 4. Delete survey
app.delete('/api/surveys/:id', async (req: AuthenticatedRequest, res) => {
  try {
    const userId = req.user?.sub;
    if (!userId) return res.status(401).json({ error: 'User ID missing from token' });

    const surveyId = req.params.id;

    // Verify ownership
    const { data: existing, error: selectError } = await supabase
      .from('form-descan-surveys')
      .select('user_id')
      .eq('id', surveyId)
      .limit(1);

    if (selectError) throw selectError;

    if (!existing || existing.length === 0) {
      return res.status(404).json({ error: 'Survey not found' });
    }
    if (existing[0].user_id !== userId) {
      return res.status(403).json({ error: 'Forbidden: You do not own this survey' });
    }

    // Delete members first
    const { error: deleteMembersError } = await supabase
      .from('form-descan-family_members')
      .delete()
      .eq('survey_id', surveyId);

    if (deleteMembersError) throw deleteMembersError;

    // Delete survey
    const { error: deleteSurveyError } = await supabase
      .from('form-descan-surveys')
      .delete()
      .eq('id', surveyId);

    if (deleteSurveyError) throw deleteSurveyError;

    res.json({ message: 'Survey deleted successfully' });
  } catch (error: any) {
    console.error('Error deleting survey:', error);
    res.status(500).json({ error: error.message || 'Internal Server Error' });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
