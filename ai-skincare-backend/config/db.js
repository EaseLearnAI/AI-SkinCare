require('dotenv').config();
const { Pool } = require('pg');

// Create a new Pool instance to connect to the Neon database
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

// Test the connection
pool.connect()
  .then(() => console.log('Successfully connected to Neon database'))
  .catch(err => console.error('Error connecting to Neon database', err));

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
}; 