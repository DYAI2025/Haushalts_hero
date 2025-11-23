// ============================================
// Stats Routes
// ============================================

import { Router } from 'express';
import statsController from '../controllers/stats.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import {
  getWeeklyStatsSchema,
  getMonthlyStatsSchema,
  updateWeeklyStatsSchema,
} from '../validators/schemas';

const router = Router();

// All stats routes require authentication
router.use(authenticate);

/**
 * GET /stats/weekly
 * Get weekly stats
 */
router.get(
  '/weekly',
  validate(getWeeklyStatsSchema),
  statsController.getWeeklyStats
);

/**
 * GET /stats/monthly
 * Get monthly stats
 */
router.get(
  '/monthly',
  validate(getMonthlyStatsSchema),
  statsController.getMonthlyStats
);

/**
 * PUT /stats/weekly
 * Update weekly stats
 */
router.put(
  '/weekly',
  validate(updateWeeklyStatsSchema),
  statsController.updateWeeklyStats
);

export default router;
