// ============================================
// Goals Routes
// ============================================

import { Router } from 'express';
import goalsController from '../controllers/goals.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { updateGoalProgressSchema } from '../validators/schemas';

const router = Router();

// All goal routes require authentication
router.use(authenticate);

/**
 * GET /goals/active
 * Get active goals for current week
 */
router.get('/active', goalsController.getActiveGoals);

/**
 * PATCH /goals/progress
 * Update goal progress
 */
router.patch(
  '/progress',
  validate(updateGoalProgressSchema),
  goalsController.updateProgress
);

export default router;
