require('dotenv').config();
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const cron = require('node-cron');

const logger = require('./utils/logger');
const db = require('./database');
const { resetMonthlyQuotas } = require('./services/quotaService');
const { setupSocketHandlers } = require('./sockets');
const workoutTemplateService = require('./services/workoutTemplateService');
const injuryMappingService = require('./services/injuryMappingService');

// Import routes
const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const intakeRoutes = require('./routes/intake');
const workoutRoutes = require('./routes/workouts');
const nutritionRoutes = require('./routes/nutrition');
const messageRoutes = require('./routes/messages');
const bookingRoutes = require('./routes/bookings');
const exerciseRoutes = require('./routes/exercises');
const productRoutes = require('./routes/products');
const storeRoutes = require('./routes/store');
const orderRoutes = require('./routes/orders');
const subscriptionRoutes = require('./routes/subscriptions');
const coachRoutes = require('./routes/coaches');
const adminRoutes = require('./routes/admin');
const progressRoutes = require('./routes/progress');
const ratingRoutes = require('./routes/ratings');
const paymentRoutes = require('./routes/payments');
const notificationRoutes = require('./routes/notifications');
const inbodyRoutes = require('./routes/inbody');
const videoCallRoutes = require('./routes/videoCalls');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.SOCKET_CORS_ORIGIN || '*',
    methods: ['GET', 'POST']
  }
});

// ============================================
// MIDDLEWARE
// ============================================

// Security
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.FRONTEND_URL || '*',
  credentials: true
}));

// Compression
app.use(compression());

// Body parsers
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined', { stream: logger.stream }));
}

// ============================================
// ROUTES
// ============================================

const API_VERSION = process.env.API_VERSION || 'v2';

app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'FitCoach+ API v2.0 - عاش',
    version: '2.0.0',
    endpoints: {
      auth: `/${API_VERSION}/auth`,
      users: `/${API_VERSION}/users`,
      intake: `/${API_VERSION}/intake`,
      workouts: `/${API_VERSION}/workouts`,
      nutrition: `/${API_VERSION}/nutrition`,
      messages: `/${API_VERSION}/messages`,
      bookings: `/${API_VERSION}/bookings`,
      exercises: `/${API_VERSION}/exercises`,
      products: `/${API_VERSION}/products`,
      store: `/${API_VERSION}/store`,
      orders: `/${API_VERSION}/orders`,
      coaches: `/${API_VERSION}/coaches`,
      admin: `/${API_VERSION}/admin`,
      subscriptions: `/${API_VERSION}/subscriptions`,
      progress: `/${API_VERSION}/progress`,
      ratings: `/${API_VERSION}/ratings`,
      payments: `/${API_VERSION}/payments`,
      notifications: `/${API_VERSION}/notifications`,
      inbody: `/${API_VERSION}/inbody`,
      videoCalls: `/${API_VERSION}/video-calls`
    }
  });
});

// Health check
app.get('/health', async (req, res) => {
  try {
    await db.query('SELECT 1');
    res.json({
      success: true,
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({
      success: false,
      status: 'unhealthy',
      database: 'disconnected',
      error: error.message
    });
  }
});

// API Routes
app.use(`/${API_VERSION}/auth`, authRoutes);
app.use(`/${API_VERSION}/users`, userRoutes);
app.use(`/${API_VERSION}/settings`, require('./routes/settings'));
app.use(`/${API_VERSION}/intake`, intakeRoutes);
app.use(`/${API_VERSION}/workouts`, workoutRoutes);
app.use(`/${API_VERSION}/nutrition`, nutritionRoutes);
app.use(`/${API_VERSION}/coaches`, coachRoutes);
app.use(`/${API_VERSION}/admin`, require('./routes/admin'));
app.use(`/${API_VERSION}/subscriptions`, subscriptionRoutes);
app.use(`/${API_VERSION}/messages`, messageRoutes);
app.use(`/${API_VERSION}/bookings`, bookingRoutes);
app.use(`/${API_VERSION}/exercises`, exerciseRoutes);
app.use(`/${API_VERSION}/products`, productRoutes);
app.use(`/${API_VERSION}/store`, storeRoutes);
app.use(`/${API_VERSION}/orders`, orderRoutes);
app.use(`/${API_VERSION}/progress`, progressRoutes);
app.use(`/${API_VERSION}/ratings`, ratingRoutes);
app.use(`/${API_VERSION}/payments`, paymentRoutes);
app.use(`/${API_VERSION}/notifications`, notificationRoutes);
app.use(`/${API_VERSION}/inbody`, inbodyRoutes);
app.use(`/${API_VERSION}/video-calls`, videoCallRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  logger.error('Error:', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method
  });

  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// ============================================
// SOCKET.IO
// ============================================

setupSocketHandlers(io);

// ============================================
// CRON JOBS
// ============================================

// Reset monthly quotas on the 1st of each month at midnight
cron.schedule('0 0 1 * *', async () => {
  logger.info('Running monthly quota reset...');
  try {
    await resetMonthlyQuotas();
    logger.info('Monthly quota reset completed successfully');
  } catch (error) {
    logger.error('Monthly quota reset failed:', error);
  }
});

// Check for expired nutrition trials daily at 1 AM
cron.schedule('0 1 * * *', async () => {
  logger.info('Checking for expired nutrition trials...');
  try {
    const { rows } = await db.query(`
      UPDATE users
      SET nutrition_trial_active = FALSE
      WHERE subscription_tier = 'freemium'
        AND nutrition_trial_active = TRUE
        AND nutrition_trial_start_date IS NOT NULL
        AND (CURRENT_TIMESTAMP - nutrition_trial_start_date) > INTERVAL '14 days'
      RETURNING id, full_name
    `);
    
    if (rows.length > 0) {
      logger.info(`Expired ${rows.length} nutrition trials`);
    }
  } catch (error) {
    logger.error('Trial expiry check failed:', error);
  }
});

// ============================================
// STARTUP
// ============================================

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    // Test database connection
    await db.query('SELECT NOW()');
    logger.info('Database connected successfully');

    // Load injury mappings
    try {
      await injuryMappingService.loadMappings();
      const injuryTypes = await injuryMappingService.getInjuryTypes();
      logger.info(`Loaded ${injuryTypes.length} injury mapping types`);
    } catch (error) {
      logger.warn('Failed to load injury mappings:', error.message);
      logger.warn('Server will continue without injury mappings');
    }

    // Load workout templates
    try {
      const templateCount = await workoutTemplateService.loadTemplates();
      logger.info(`Loaded ${templateCount} workout templates`);
    } catch (error) {
      logger.warn('Failed to load workout templates:', error.message);
      logger.warn('Server will continue without templates');
    }

    // Start server
    server.listen(PORT, () => {
      logger.info(`🚀 FitCoach+ API v2.0 running on port ${PORT}`);
      logger.info(`📝 Environment: ${process.env.NODE_ENV}`);
      logger.info(`🌐 API Base URL: http://localhost:${PORT}/${API_VERSION}`);
      logger.info(`💬 Socket.IO ready for real-time messaging`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM signal received: closing HTTP server');
  server.close(async () => {
    logger.info('HTTP server closed');
    await db.end();
    logger.info('Database connection closed');
    process.exit(0);
  });
});

process.on('SIGINT', async () => {
  logger.info('SIGINT signal received: closing HTTP server');
  server.close(async () => {
    logger.info('HTTP server closed');
    await db.end();
    logger.info('Database connection closed');
    process.exit(0);
  });
});

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled Rejection at:', promise, 'reason:', reason);
  process.exit(1);
});

if (require.main === module) {
  startServer();
}

module.exports = app;
module.exports.server = server;
module.exports.io = io;
