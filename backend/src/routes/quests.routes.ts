// ============================================
// Quests Routes
// ============================================

import { Router } from 'express';
import questsController from '../controllers/quests.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { updateQuestProgressSchema } from '../validators/schemas';

const router = Router();

// All quest routes require authentication
router.use(authenticate);

/**
 * GET /quests/active
 * Get active quests for current week
 */
router.get('/active', questsController.getActiveQuests);

/**
 * PATCH /quests/:id/progress
 * Update quest progress
 */
router.patch(
  '/:id/progress',
  validate(updateQuestProgressSchema),
  questsController.updateProgress
);

/**
 * POST /quests/reset
 * Reset quests for new week
 */
router.post('/reset', questsController.resetQuests);

export default router;
