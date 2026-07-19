import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from './schema.js';
import dotenv from 'dotenv';
dotenv.config();

const connectionString = process.env.DATABASE_URL || '';

if (!connectionString) {
  console.warn('WARNING: DATABASE_URL is not set in environment variables.');
}

// Disable ssl if connecting locally, inside docker network (host 'db'), or explicitly requested via DB_SSL=false
const isLocalOrDocker = 
  connectionString.includes('localhost') || 
  connectionString.includes('127.0.0.1') || 
  connectionString.includes('@db:') || 
  process.env.DB_SSL === 'false';

const client = postgres(connectionString, {
  ssl: isLocalOrDocker ? false : { rejectUnauthorized: false }
});

export const db = drizzle(client, { schema });
export default db;
