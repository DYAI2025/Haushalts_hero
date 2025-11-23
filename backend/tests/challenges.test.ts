// ============================================
// Challenge Endpoint Tests
// ============================================

import request from 'supertest';
import app from '../src/index';

describe('Challenges', () => {
  let accessToken: string;

  const testUser = {
    email: 'test@example.com',
    password: 'password123',
  };

  const testChallenge = {
    category: 'mirror',
    beforePhotoUrl: 'https://example.com/before.jpg',
    afterPhotoUrl: 'https://example.com/after.jpg',
    score: {
      overallScore: 85,
      subscores: [
        { name: 'Cleanliness', value: 90, weight: 0.4 },
        { name: 'Streak-Free', value: 80, weight: 0.6 },
      ],
      confidence: 0.92,
      explanation: 'Great job! The mirror is very clean and mostly streak-free.',
    },
  };

  beforeEach(async () => {
    // Register and login
    const response = await request(app)
      .post('/api/v1/auth/register')
      .send(testUser);

    accessToken = response.body.accessToken;
  });

  describe('POST /challenges', () => {
    it('should create a challenge', async () => {
      const response = await request(app)
        .post('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(testChallenge)
        .expect(201);

      expect(response.body).toHaveProperty('id');
      expect(response.body.category).toBe('mirror');
      expect(response.body.overallScore).toBe(85);
      expect(response.body.subscores).toHaveLength(2);
    });

    it('should require authentication', async () => {
      await request(app)
        .post('/api/v1/challenges')
        .send(testChallenge)
        .expect(401);
    });

    it('should validate category', async () => {
      const invalidChallenge = {
        ...testChallenge,
        category: 'invalid',
      };

      const response = await request(app)
        .post('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(invalidChallenge)
        .expect(400);

      expect(response.body.error.code).toBe('VALIDATION_ERROR');
    });
  });

  describe('GET /challenges', () => {
    beforeEach(async () => {
      // Create some test challenges
      await request(app)
        .post('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(testChallenge);

      await request(app)
        .post('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ ...testChallenge, category: 'toilet' });
    });

    it('should get all challenges', async () => {
      const response = await request(app)
        .get('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.data).toHaveLength(2);
      expect(response.body.pagination).toBeDefined();
      expect(response.body.pagination.total).toBe(2);
    });

    it('should filter by category', async () => {
      const response = await request(app)
        .get('/api/v1/challenges?category=mirror')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.data).toHaveLength(1);
      expect(response.body.data[0].category).toBe('mirror');
    });

    it('should paginate results', async () => {
      const response = await request(app)
        .get('/api/v1/challenges?limit=1&offset=0')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      expect(response.body.data).toHaveLength(1);
      expect(response.body.pagination.hasMore).toBe(true);
    });
  });

  describe('DELETE /challenges/:id', () => {
    let challengeId: string;

    beforeEach(async () => {
      const response = await request(app)
        .post('/api/v1/challenges')
        .set('Authorization', `Bearer ${accessToken}`)
        .send(testChallenge);

      challengeId = response.body.id;
    });

    it('should delete a challenge', async () => {
      await request(app)
        .delete(`/api/v1/challenges/${challengeId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200);

      // Verify it's deleted
      await request(app)
        .get(`/api/v1/challenges/${challengeId}`)
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });

    it('should return 404 for non-existent challenge', async () => {
      await request(app)
        .delete('/api/v1/challenges/00000000-0000-0000-0000-000000000000')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(404);
    });
  });
});
