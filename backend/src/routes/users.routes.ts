// ============================================
// Users Routes
// ============================================

import { Router } from 'express';
import usersController from '../controllers/users.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { updateUserSettingsSchema } from '../validators/schemas';

const router = Router();

// All user routes require authentication
router.use(authenticate);

/**
 * GET /users/me
 * Get current user with settings
 */
router.get('/me', usersController.getMe);

/**
 * PUT /users/me/settings
 * Update user settings
 */
router.put(
  '/me/settings',
  validate(updateUserSettingsSchema),
  usersController.updateSettings
);

export default router;
