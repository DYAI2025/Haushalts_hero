// ============================================
// Haushalts-Hero Backend Server
// ============================================

import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import config from './config';
import { errorHandler, notFoundHandler } from './middleware/errorHandler';

// Import routes
import authRoutes from './routes/auth.routes';
import userRoutes from './routes/users.routes';
import challengeRoutes from './routes/challenges.routes';
import questRoutes from './routes/quests.routes';
import goalRoutes from './routes/goals.routes';
import statsRoutes from './routes/stats.routes';
import contentRoutes from './routes/content.routes';
import photoRoutes from './routes/photos.routes';

const app = express();

// ============================================
// Middleware
// ============================================

// Security
app.use(helmet());

// CORS
app.use(
  cors({
    origin: config.cors.origin,
    credentials: true,
  })
);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (config.env === 'development') {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// ============================================
// Health Check
// ============================================

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    environment: config.env,
    version: config.apiVersion,
  });
});

// ============================================
// API Routes
// ============================================

const apiRouter = express.Router();

// Mount routes
apiRouter.use('/auth', authRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/challenges', challengeRoutes);
apiRouter.use('/quests', questRoutes);
apiRouter.use('/goals', goalRoutes);
apiRouter.use('/stats', statsRoutes);
apiRouter.use('/content', contentRoutes);
apiRouter.use('/photos', photoRoutes);

app.use(`/api/${config.apiVersion}`, apiRouter);

// ============================================
// Error Handling
// ============================================

app.use(notFoundHandler);
app.use(errorHandler);

// ============================================
// Start Server
// ============================================

const startServer = async () => {
  try {
    app.listen(config.port, () => {
      console.log(`
╔════════════════════════════════════════════════╗
║     🏠 Haushalts-Hero Backend API Server      ║
╚════════════════════════════════════════════════╝

Environment:  ${config.env}
Port:         ${config.port}
API Version:  ${config.apiVersion}
Base URL:     http://localhost:${config.port}/api/${config.apiVersion}

Health Check: http://localhost:${config.port}/health

Server started successfully! 🚀
      `);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Handle uncaught errors
process.on('unhandledRejection', (reason: Error) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1);
});

process.on('uncaughtException', (error: Error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1);
});

// Start the server
startServer();

export default app;
