require('dotenv').config();
const app = require('./app');
const db = require('./config/db');

// Set default port
const PORT = process.env.PORT || 3000;

// Test database connection before starting server
const startServer = async () => {
  try {
    // Test database connection
    const client = await db.connect();
    console.log('Database connection successful');
    client.release();
    
    // Start server
    app.listen(PORT, () => {
      console.log(`AI Skincare API server running on port ${PORT}`);
      console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
    });
  } catch (error) {
    console.error('Failed to connect to database:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('UNHANDLED REJECTION! Shutting down...');
  console.error(err);
  process.exit(1);
});

// Start server
startServer(); 