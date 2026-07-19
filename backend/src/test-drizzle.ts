import { db } from './db/drizzle.js';
import { users } from './db/schema.js';
import dotenv from 'dotenv';
dotenv.config();

async function testDrizzle() {
  console.log('=============================================');
  console.log('Testing Drizzle ORM PostgreSQL connection...');
  // Redact the password in the output
  const dbUrl = process.env.DATABASE_URL || '';
  const redactedUrl = dbUrl.replace(/:([^:@]+)@/, ':******@');
  console.log('DATABASE_URL:', redactedUrl);
  console.log('=============================================');

  try {
    // Try to query the users table using Drizzle
    const result = await db.select().from(users).limit(1);
    console.log('✓ Drizzle DB connection successful!');
    console.log('Result:', result);
    console.log('=============================================');
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Drizzle DB connection failed!');
    console.error(error);
    console.log('=============================================');
    process.exit(1);
  }
}

testDrizzle();
