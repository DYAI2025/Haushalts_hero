// ============================================
// Database Seeding Script
// ============================================

import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create demo user
  const passwordHash = await bcrypt.hash('demo123', 10);
  const demoUser = await prisma.user.create({
    data: {
      id: uuidv4(),
      email: 'demo@haushalts-hero.com',
      passwordHash,
    },
  });

  console.log('✅ Created demo user:', demoUser.email);

  // Create user settings
  await prisma.userSettings.create({
    data: {
      id: uuidv4(),
      userId: demoUser.id,
      enableHapticFeedback: true,
      enableSoundEffects: true,
      showHeatmapByDefault: false,
    },
  });

  console.log('✅ Created user settings');

  // Create sample challenges
  const categories = ['mirror', 'toilet', 'room'];
  for (let i = 0; i < 10; i++) {
    const category = categories[i % 3];
    const score = 60 + Math.floor(Math.random() * 40); // 60-100

    await prisma.challenge.create({
      data: {
        id: uuidv4(),
        userId: demoUser.id,
        category,
        beforePhotoUrl: `https://example.com/before-${i}.jpg`,
        afterPhotoUrl: `https://example.com/after-${i}.jpg`,
        timestamp: new Date(Date.now() - i * 24 * 60 * 60 * 1000), // Last 10 days
        overallScore: score,
        subscores: JSON.stringify([
          { name: 'Cleanliness', value: score + 5, weight: 0.5 },
          { name: 'Organization', value: score - 5, weight: 0.5 },
        ]),
        confidence: 0.8 + Math.random() * 0.2,
        explanation: `Good job! Score: ${score}`,
      },
    });
  }

  console.log('✅ Created 10 sample challenges');

  // Create weekly quests
  const weekStart = new Date();
  weekStart.setDate(weekStart.getDate() - weekStart.getDay() + 1);
  weekStart.setHours(0, 0, 0, 0);

  const quests = [
    {
      title: 'Spiegel-Meister',
      description: 'Putze 3 Spiegel diese Woche',
      category: 'mirror',
      targetCount: 3,
      currentProgress: 1,
      rewardPoints: 150,
    },
    {
      title: 'Toiletten-Champion',
      description: 'Reinige 5 Toiletten diese Woche',
      category: 'toilet',
      targetCount: 5,
      currentProgress: 2,
      rewardPoints: 250,
    },
    {
      title: 'Raum-Organisator',
      description: 'Räume 4 Zimmer auf diese Woche',
      category: 'room',
      targetCount: 4,
      currentProgress: 1,
      rewardPoints: 200,
    },
  ];

  for (const quest of quests) {
    await prisma.quest.create({
      data: {
        id: uuidv4(),
        userId: demoUser.id,
        weekStart,
        ...quest,
      },
    });
  }

  console.log('✅ Created 3 weekly quests');

  // Create weekly goal
  await prisma.goal.create({
    data: {
      id: uuidv4(),
      userId: demoUser.id,
      title: 'Wochenziel',
      targetPoints: 1000,
      currentPoints: 450,
      weekStart,
    },
  });

  console.log('✅ Created weekly goal');

  // Create weekly stats
  await prisma.weeklyStats.create({
    data: {
      id: uuidv4(),
      userId: demoUser.id,
      weekStart,
      challengesCompleted: 10,
      averageScore: 78.5,
      categoryCounts: JSON.stringify({
        mirror: 4,
        toilet: 3,
        room: 3,
      }),
      totalPoints: 785,
    },
  });

  console.log('✅ Created weekly stats');

  console.log('');
  console.log('🎉 Seeding completed!');
  console.log('');
  console.log('📝 Demo credentials:');
  console.log('   Email:    demo@haushalts-hero.com');
  console.log('   Password: demo123');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
