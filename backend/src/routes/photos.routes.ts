// ============================================
// Photos Routes
// ============================================

import { Router } from 'express';
import multer from 'multer';
import photosController from '../controllers/photos.controller';
import { authenticate } from '../middleware/auth';
import { validate } from '../middleware/validation';
import { getPhotoByIdSchema, deletePhotoSchema } from '../validators/schemas';
import config from '../config';

const router = Router();

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: config.upload.maxSize,
  },
  fileFilter: (req, file, cb) => {
    if (config.upload.allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  },
});

// All photo routes require authentication
router.use(authenticate);

/**
 * POST /photos/upload
 * Upload photo
 */
router.post('/upload', upload.single('photo'), photosController.uploadPhoto);

/**
 * GET /photos/stats
 * Get storage statistics
 */
router.get('/stats', photosController.getStats);

/**
 * GET /photos/:id
 * Get photo by ID
 * Query params: download=true to get file instead of metadata
 */
router.get('/:id', validate(getPhotoByIdSchema), photosController.getPhoto);

/**
 * DELETE /photos/:id
 * Delete photo
 */
router.delete(
  '/:id',
  validate(deletePhotoSchema),
  photosController.deletePhoto
);

export default router;
