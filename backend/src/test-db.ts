import { supabase } from './db/supabase.js';
import dotenv from 'dotenv';
dotenv.config();

async function testConnection() {
  console.log('=============================================');
  console.log('Testing connection to Supabase via HTTPS...');
  console.log('SUPABASE_URL:', process.env.SUPABASE_URL);
  console.log('=============================================');
  
  try {
    // Try to query the form-descan-users table
    const { data, error, status } = await supabase
      .from('form-descan-users')
      .select('id')
      .limit(1);

    if (error) {
      // Check if it's just a missing relation (table not created yet)
      const isMissingRelation = error.message && (
        error.message.includes('relation') && error.message.includes('does not exist') ||
        error.code === '42P01' ||
        error.code === 'PGRST205' ||
        error.message.includes('Could not find the table')
      );
      
      if (isMissingRelation) {
        console.log('✓ API Connection successful (HTTPS Port 443)!');
        console.log('⚠️  Note: The table "form-descan-users" does not exist yet.');
        console.log('Please run the SQL DDL script in your Supabase Dashboard SQL Editor.');
        console.log('=============================================');
        process.exit(0);
      }
      throw error;
    }

    console.log('✓ Database connection and table check successful!');
    console.log('Result status:', status);
    console.log('=============================================');
    process.exit(0);
  } catch (error: any) {
    console.error('✗ Database connection failed!');
    console.error(error);
    console.log('=============================================');
    process.exit(1);
  }
}

testConnection();
