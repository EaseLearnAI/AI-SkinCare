require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

// Create a new Supabase client
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Bucket for file storage
const bucketName = process.env.SUPABASE_STORAGE_BUCKET || 'ai-skincare-images';

// Create the bucket if it doesn't exist
async function ensureBucketExists() {
  try {
    const { data, error } = await supabase.storage.getBucket(bucketName);
    
    if (error && error.message.includes('does not exist')) {
      console.log(`Creating storage bucket: ${bucketName}`);
      const { data, error } = await supabase.storage.createBucket(bucketName, {
        public: true,
        fileSizeLimit: 10 * 1024 * 1024 // 10MB limit
      });
      
      if (error) {
        console.error('Error creating bucket:', error);
      } else {
        console.log(`Bucket '${bucketName}' created successfully`);
      }
    } else if (error) {
      console.error('Error checking bucket:', error);
    } else {
      console.log(`Using existing bucket: ${bucketName}`);
    }
  } catch (err) {
    console.error('Supabase bucket setup error:', err);
  }
}

// Initialize when the server starts
ensureBucketExists();

module.exports = {
  supabase,
  bucketName
}; 