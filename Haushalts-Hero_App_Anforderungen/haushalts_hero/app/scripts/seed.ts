
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting seed...')

  // Create test user
  const hashedPassword = await bcrypt.hash('johndoe123', 12)
  
  const testUser = await prisma.user.upsert({
    where: { email: 'john@doe.com' },
    update: {},
    create: {
      email: 'john@doe.com',
      password: hashedPassword,
      name: 'John Doe',
      displayName: 'JohnD',
    },
  })

  console.log('✅ Created test user:', testUser.email)

  // Create some sample challenges and scores
  const challenges = await Promise.all([
    prisma.challenge.create({
      data: {
        userId: testUser.id,
        category: 'MIRROR_CLEANING',
        status: 'COMPLETED',
        beforePhoto: 'data:image/jpeg;base64,sample',
        afterPhoto: 'data:image/jpeg;base64,sample',
        completedAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // 1 day ago
        scores: {
          create: {
            userId: testUser.id,
            category: 'MIRROR_CLEANING',
            scoreValue: 85,
            breakdown: {
              edgeDetection: 80,
              reflectionQuality: 90,
              brightnessAnalysis: 85
            },
            combo: 1
          }
        }
      }
    }),
    prisma.challenge.create({
      data: {
        userId: testUser.id,
        category: 'TOILET_CLEANING',
        status: 'COMPLETED',
        beforePhoto: 'data:image/jpeg;base64,sample',
        afterPhoto: 'data:image/jpeg;base64,sample',
        completedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
        scores: {
          create: {
            userId: testUser.id,
            category: 'TOILET_CLEANING',
            scoreValue: 78,
            breakdown: {
              stainReduction: 75,
              cleanlinessScore: 82,
              brightnessAnalysis: 77
            },
            combo: 2
          }
        }
      }
    }),
    prisma.challenge.create({
      data: {
        userId: testUser.id,
        category: 'ROOM_TIDYING',
        status: 'COMPLETED',
        beforePhoto: 'data:image/jpeg;base64,sample',
        afterPhoto: 'data:image/jpeg;base64,sample',
        completedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3 days ago
        scores: {
          create: {
            userId: testUser.id,
            category: 'ROOM_TIDYING',
            scoreValue: 92,
            breakdown: {
              tidiness: 95,
              freeSpace: 88,
              edgeDetection: 93
            },
            combo: 1
          }
        }
      }
    })
  ])

  console.log('✅ Created sample challenges:', challenges.length)

  // Create or update user stats
  const stats = await prisma.userStats.upsert({
    where: { userId: testUser.id },
    update: {},
    create: {
      userId: testUser.id,
      totalChallenges: 3,
      completedChallenges: 3,
      averageScore: 85,
      bestScore: 92,
      currentStreak: 3,
      longestStreak: 3,
      totalPoints: 255,
      level: 1
    }
  })

  console.log('✅ Created user stats:', stats)

  console.log('🎉 Seed completed successfully!')
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
