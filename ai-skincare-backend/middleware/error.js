/**
 * Global error handler middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  
  // Default error status and message
  let statusCode = err.statusCode || 500;
  let errorCode = err.code || 'SERVER_ERROR';
  let message = err.message || 'An unexpected error occurred';
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    errorCode = 'VALIDATION_ERROR';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    errorCode = 'AUTHENTICATION_ERROR';
  } else if (err.name === 'ForbiddenError') {
    statusCode = 403;
    errorCode = 'PERMISSION_DENIED';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    errorCode = 'RESOURCE_NOT_FOUND';
  }
  
  // Return standardized error response
  res.status(statusCode).json({
    success: false,
    error: {
      code: errorCode,
      message: message
    }
  });
};

/**
 * Custom error classes
 */
class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.code = 'VALIDATION_ERROR';
  }
}

class UnauthorizedError extends Error {
  constructor(message) {
    super(message || 'Authentication required');
    this.name = 'UnauthorizedError';
    this.statusCode = 401;
    this.code = 'AUTHENTICATION_ERROR';
  }
}

class ForbiddenError extends Error {
  constructor(message) {
    super(message || 'Permission denied');
    this.name = 'ForbiddenError';
    this.statusCode = 403;
    this.code = 'PERMISSION_DENIED';
  }
}

class NotFoundError extends Error {
  constructor(message) {
    super(message || 'Resource not found');
    this.name = 'NotFoundError';
    this.statusCode = 404;
    this.code = 'RESOURCE_NOT_FOUND';
  }
}

class ServerError extends Error {
  constructor(message) {
    super(message || 'Internal server error');
    this.name = 'ServerError';
    this.statusCode = 500;
    this.code = 'SERVER_ERROR';
  }
}

module.exports = {
  errorHandler,
  ValidationError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ServerError
}; 