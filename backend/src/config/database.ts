// ============================================
// Database Configuration
// ============================================

import { PrismaClient } from '@prisma/client';

// Create Prisma Client instance with logging
const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development'
    ? ['query', 'info', 'warn', 'error']
    : ['error'],
});

// Graceful shutdown handling
process.on('beforeExit', async () => {
  await prisma.$disconnect();
});

export default prisma;
