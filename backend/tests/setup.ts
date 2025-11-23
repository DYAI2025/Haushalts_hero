// ============================================
// Test Setup
// ============================================

import prisma from '../src/config/database';

// Cleanup database after each test
afterEach(async () => {
  // Clear all tables in reverse order of dependencies
  await prisma.refreshToken.deleteMany();
  await prisma.photo.deleteMany();
  await prisma.userSettings.deleteMany();
  await prisma.weeklyStats.deleteMany();
  await prisma.goal.deleteMany();
  await prisma.quest.deleteMany();
  await prisma.challenge.deleteMany();
  await prisma.user.deleteMany();
});

// Close Prisma connection after all tests
afterAll(async () => {
  await prisma.$disconnect();
});
