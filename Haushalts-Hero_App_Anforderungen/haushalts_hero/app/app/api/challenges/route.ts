
import { NextRequest, NextResponse } from 'next/server'
import { getServerSession } from 'next-auth/next'
import { authOptions } from '@/lib/auth'
import { prisma } from '@/lib/db'

export const dynamic = 'force-dynamic'

export async function POST(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const userId = session.user.id
    const body = await request.json()
    const { category, beforePhoto, afterPhoto, score, breakdown } = body

    if (!category || !beforePhoto || !afterPhoto || score === undefined) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
    }

    // Create challenge
    const challenge = await prisma.challenge.create({
      data: {
        userId,
        category,
        beforePhoto,
        afterPhoto,
        status: 'COMPLETED',
        completedAt: new Date()
      }
    })

    // Calculate combo for score multiplier
    const recentScores = await prisma.score.findMany({
      where: { 
        userId,
        scoreValue: { gte: 75 }
      },
      orderBy: { createdAt: 'desc' },
      take: 10
    })

    let combo = 1
    if (score >= 75) {
      combo = Math.min(recentScores.length + 1, 10)
    }

    // Create score record
    const scoreRecord = await prisma.score.create({
      data: {
        userId,
        challengeId: challenge.id,
        category,
        scoreValue: score,
        breakdown: breakdown || {},
        combo
      }
    })

    return NextResponse.json({
      challenge,
      score: scoreRecord,
      message: 'Challenge completed successfully'
    }, { status: 201 })
  } catch (error) {
    console.error('Error creating challenge:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    const session = await getServerSession(authOptions)
    
    if (!session?.user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const userId = session.user.id
    const { searchParams } = new URL(request.url)
    const limit = parseInt(searchParams.get('limit') || '10')

    const challenges = await prisma.challenge.findMany({
      where: { userId },
      include: {
        scores: true
      },
      orderBy: { createdAt: 'desc' },
      take: limit
    })

    return NextResponse.json(challenges)
  } catch (error) {
    console.error('Error fetching challenges:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
