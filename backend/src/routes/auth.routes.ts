// ============================================
// Authentication Routes
// ============================================

import { Router } from 'express';
import authController from '../controllers/auth.controller';
import { validate } from '../middleware/validation';
import { authenticate } from '../middleware/auth';
import {
  registerSchema,
  loginSchema,
  refreshTokenSchema,
} from '../validators/schemas';

const router = Router();

/**
 * POST /auth/register
 * Register new user
 */
router.post(
  '/register',
  validate(registerSchema),
  authController.register
);

/**
 * POST /auth/login
 * Login user
 */
router.post(
  '/login',
  validate(loginSchema),
  authController.login
);

/**
 * POST /auth/refresh
 * Refresh access token
 */
router.post(
  '/refresh',
  validate(refreshTokenSchema),
  authController.refresh
);

/**
 * POST /auth/logout
 * Logout user (revoke refresh token)
 */
router.post(
  '/logout',
  validate(refreshTokenSchema),
  authController.logout
);

/**
 * GET /auth/me
 * Get current user (protected route)
 */
router.get(
  '/me',
  authenticate,
  authController.me
);

export default router;
