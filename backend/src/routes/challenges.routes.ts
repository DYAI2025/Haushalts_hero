// ============================================
// Challenges Routes
// ============================================

import { Router } from 'express';
import challengesController from '../controllers/challenges.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import {
  createChallengeSchema,
  getChallengesSchema,
  getChallengeByIdSchema,
  deleteChallengeSchema,
} from '../validators/schemas';

const router = Router();

// All challenge routes require authentication
router.use(authenticate);

/**
 * GET /challenges
 * Get challenge history with pagination
 */
router.get(
  '/',
  validate(getChallengesSchema),
  challengesController.getChallenges
);

/**
 * POST /challenges
 * Create new challenge
 */
router.post(
  '/',
  validate(createChallengeSchema),
  challengesController.createChallenge
);

/**
 * GET /challenges/:id
 * Get challenge by ID
 */
router.get(
  '/:id',
  validate(getChallengeByIdSchema),
  challengesController.getChallengeById
);

/**
 * DELETE /challenges/:id
 * Delete challenge
 */
router.delete(
  '/:id',
  validate(deleteChallengeSchema),
  challengesController.deleteChallenge
);

export default router;
