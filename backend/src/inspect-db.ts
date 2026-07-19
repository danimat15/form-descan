import { supabase } from './db/supabase.js';

async function inspect() {
  console.log('Fetching sample records from Supabase...');
  try {
    const { data: userData, error: userError } = await supabase
      .from('form-descan-users')
      .select('*')
      .limit(1);
    
    if (userError) {
      console.error('Error fetching users:', userError);
    } else {
      console.log('=============================================');
      console.log('form-descan-users columns:');
      console.log(userData && userData[0] ? Object.keys(userData[0]) : 'No records found');
      console.log('Sample record:', userData && userData[0] ? userData[0] : 'None');
    }

    const { data: surveyData, error: surveyError } = await supabase
      .from('form-descan-surveys')
      .select('*')
      .limit(1);
    
    if (surveyError) {
      console.error('Error fetching surveys:', surveyError);
    } else {
      console.log('=============================================');
      console.log('form-descan-surveys columns:');
      console.log(surveyData && surveyData[0] ? Object.keys(surveyData[0]) : 'No records found');
      console.log('Sample record keys count:', surveyData && surveyData[0] ? Object.keys(surveyData[0]).length : 0);
      console.log('Sample record details:');
      if (surveyData && surveyData[0]) {
        // print keys and values (truncated if long)
        for (const [key, value] of Object.entries(surveyData[0])) {
          console.log(`  ${key}: ${typeof value} (${String(value).substring(0, 50)})`);
        }
      }
    }

    const { data: memberData, error: memberError } = await supabase
      .from('form-descan-family_members')
      .select('*')
      .limit(1);
    
    if (memberError) {
      console.error('Error fetching family members:', memberError);
    } else {
      console.log('=============================================');
      console.log('form-descan-family_members columns:');
      console.log(memberData && memberData[0] ? Object.keys(memberData[0]) : 'No records found');
      console.log('Sample record details:');
      if (memberData && memberData[0]) {
        for (const [key, value] of Object.entries(memberData[0])) {
          console.log(`  ${key}: ${typeof value} (${String(value).substring(0, 50)})`);
        }
      }
    }
    console.log('=============================================');
  } catch (e) {
    console.error('Inspection failed:', e);
  }
  process.exit(0);
}

inspect();
