import { db } from './db/drizzle.js';
import { users } from './db/schema.js';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { eq } from 'drizzle-orm';
import dotenv from 'dotenv';
dotenv.config();

async function seed() {
  console.log('=============================================');
  console.log('Seeding Database with Test User...');
  console.log('=============================================');

  try {
    const email = 'test@bps.go.id';
    const password = 'password123';
    
    // Check if user already exists
    const existing = await db.select().from(users).where(eq(users.email, email)).limit(1);
    
    if (existing.length > 0) {
      console.log(`User ${email} already exists. Updating credentials and region...`);
      const hashedPassword = await bcrypt.hash(password, 10);
      await db.update(users)
        .set({ 
          password: hashedPassword,
          desa: 'APENG SEMBEKA',
          kecamatan: 'TAHUNA',
          kabupaten: 'KEPULAUAN SANGIHE',
          nama: 'Test User',
          role: 'Pencacah'
        })
        .where(eq(users.email, email));
      console.log(`✓ Password updated to: ${password}`);
      console.log(`✓ Region updated to: KEPULAUAN SANGIHE, TAHUNA, APENG SEMBEKA`);
    } else {
      const hashedPassword = await bcrypt.hash(password, 10);
      const userId = crypto.randomUUID();
      
      await db.insert(users).values({
        id: userId,
        email,
        password: hashedPassword,
        desa: 'APENG SEMBEKA',
        kecamatan: 'TAHUNA',
        kabupaten: 'KEPULAUAN SANGIHE',
        nama: 'Test User',
        role: 'Pencacah',
      });
      console.log(`✓ Test user created successfully!`);
      console.log(`  Email: ${email}`);
      console.log(`  Password: ${password}`);
      console.log(`  Region: KEPULAUAN SANGIHE, TAHUNA, APENG SEMBEKA`);
      console.log(`  Nama: Test User`);
      console.log(`  Role: Pencacah`);
    }
    
    console.log('=============================================');
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Seeding failed!');
    console.error(error);
    console.log('=============================================');
    process.exit(1);
  }
}

seed();
