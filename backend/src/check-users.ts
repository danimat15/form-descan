import { db } from './db/drizzle.js';
import { users } from './db/schema.js';
import dotenv from 'dotenv';
dotenv.config();

async function checkUsers() {
  try {
    const list = await db.select({ email: users.email }).from(users);
    console.log('=== Registered Users ===');
    console.log(list);
    console.log('========================');
    process.exit(0);
  } catch (e) {
    console.error('Error querying users:', e);
    process.exit(1);
  }
}

checkUsers();
