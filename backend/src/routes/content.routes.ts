// ============================================
// Content Routes
// ============================================

import { Router } from 'express';
import contentController from '../controllers/content.controller';

const router = Router();

/**
 * GET /content/coaching-tips
 * Get coaching tips (public endpoint)
 */
router.get('/coaching-tips', contentController.getCoachingTips);

/**
 * GET /content/micro-learning
 * Get micro-learning modules (public endpoint)
 */
router.get('/micro-learning', contentController.getMicroLearning);

/**
 * GET /content/seasons/active
 * Get active season (public endpoint)
 */
router.get('/seasons/active', contentController.getActiveSeason);

/**
 * GET /content/seasons
 * Get all seasons (public endpoint)
 */
router.get('/seasons', contentController.getSeasons);

export default router;
