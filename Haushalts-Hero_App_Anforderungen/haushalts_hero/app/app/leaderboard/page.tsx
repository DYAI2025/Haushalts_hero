
'use client'

import { useState, useEffect } from 'react'
import { useSession } from 'next-auth/react'
import { useRouter } from 'next/navigation'
import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { ArrowLeft, Trophy, Medal, Award, Crown, Star, Zap } from 'lucide-react'
import { LeaderboardEntry } from '@/lib/types'

interface LeaderboardData {
  leaderboard: LeaderboardEntry[]
  currentUserPosition: number
}

export default function LeaderboardPage() {
  const { data: session } = useSession()
  const router = useRouter()
  const [data, setData] = useState<LeaderboardData | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!session) {
      router.push('/auth/signin')
      return
    }
    
    loadLeaderboard()
  }, [session, router])

  const loadLeaderboard = async () => {
    try {
      const response = await fetch('/api/leaderboard')
      if (response.ok) {
        const leaderboardData = await response.json()
        setData(leaderboardData)
      }
    } catch (error) {
      console.error('Error loading leaderboard:', error)
    } finally {
      setLoading(false)
    }
  }

  const getPositionIcon = (position: number) => {
    switch (position) {
      case 1:
        return <Crown className="h-6 w-6 text-yellow-500" />
      case 2:
        return <Medal className="h-6 w-6 text-gray-400" />
      case 3:
        return <Award className="h-6 w-6 text-orange-500" />
      default:
        return <span className="text-lg font-bold text-gray-500">#{position}</span>
    }
  }

  const getPositionBadge = (position: number) => {
    switch (position) {
      case 1:
        return 'bg-gradient-to-r from-yellow-400 to-orange-500 text-white'
      case 2:
        return 'bg-gradient-to-r from-gray-300 to-gray-500 text-white'
      case 3:
        return 'bg-gradient-to-r from-orange-400 to-red-500 text-white'
      default:
        return 'bg-gray-100 text-gray-700'
    }
  }

  if (!session || loading) {
    return (
      <div className="mobile-container flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">Lade Leaderboard...</p>
        </div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="mobile-container flex items-center justify-center">
        <div className="text-center">
          <Trophy className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <p className="text-gray-600">Leaderboard konnte nicht geladen werden</p>
        </div>
      </div>
    )
  }

  return (
    <div className="mobile-container">
      {/* Header */}
      <div className="hero-gradient p-6 text-white">
        <div className="flex items-center mb-6">
          <Button
            onClick={() => router.push('/')}
            size="sm"
            variant="ghost"
            className="text-white hover:bg-white/20 mr-3"
          >
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <h1 className="text-2xl font-bold">Leaderboard</h1>
        </div>

        {/* User Position */}
        {data.currentUserPosition > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white/20 backdrop-blur-sm rounded-lg p-4"
          >
            <div className="flex items-center justify-between">
              <div>
                <p className="text-white/80 text-sm">Deine Position</p>
                <p className="text-2xl font-bold">#{data.currentUserPosition}</p>
              </div>
              <div className="text-right">
                <p className="text-white/80 text-sm">Deine Punkte</p>
                <p className="text-xl font-bold">
                  {data.leaderboard.find(entry => entry.userId === session?.user?.id)?.totalScore || 0}
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </div>

      {/* Leaderboard */}
      <div className="p-6">
        {data.leaderboard.length === 0 ? (
          <div className="text-center py-12">
            <Trophy className="h-16 w-16 text-gray-300 mx-auto mb-4" />
            <h2 className="text-xl font-semibold text-gray-600 mb-2">
              Noch keine Einträge
            </h2>
            <p className="text-gray-500">
              Sei der Erste im Leaderboard!
            </p>
          </div>
        ) : (
          <div className="space-y-3">
            {data.leaderboard.map((entry, index) => (
              <motion.div
                key={entry.userId}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.05 }}
              >
                <Card className={`p-4 ${
                  entry.userId === session?.user?.id 
                    ? 'ring-2 ring-blue-500 bg-blue-50' 
                    : ''
                }`}>
                  <div className="flex items-center space-x-4">
                    {/* Position */}
                    <div className={`
                      w-12 h-12 rounded-full flex items-center justify-center font-bold
                      ${getPositionBadge(index + 1)}
                    `}>
                      {index < 3 ? (
                        getPositionIcon(index + 1)
                      ) : (
                        <span>#{index + 1}</span>
                      )}
                    </div>

                    {/* Avatar */}
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-bold">
                      {entry.avatar ? (
                        <img 
                          src={entry.avatar} 
                          alt={entry.displayName} 
                          className="w-full h-full rounded-full object-cover"
                        />
                      ) : (
                        entry.displayName.charAt(0).toUpperCase()
                      )}
                    </div>

                    {/* User Info */}
                    <div className="flex-1">
                      <div className="flex items-center space-x-2">
                        <h3 className="font-semibold text-gray-900">
                          {entry.displayName}
                        </h3>
                        {entry.userId === session?.user?.id && (
                          <span className="bg-blue-100 text-blue-800 px-2 py-1 rounded-full text-xs font-medium">
                            Du
                          </span>
                        )}
                      </div>
                      <div className="flex items-center space-x-4 text-sm text-gray-600 mt-1">
                        <span className="flex items-center">
                          <Trophy className="h-3 w-3 mr-1" />
                          {entry.totalScore}
                        </span>
                        <span className="flex items-center">
                          <Star className="h-3 w-3 mr-1" />
                          Ø {entry.averageScore}
                        </span>
                        {entry.currentStreak > 0 && (
                          <span className="flex items-center">
                            <Zap className="h-3 w-3 mr-1 text-yellow-500" />
                            {entry.currentStreak}
                          </span>
                        )}
                      </div>
                    </div>

                    {/* Level */}
                    <div className="text-right">
                      <div className="text-lg font-bold text-gray-900">
                        Lv.{entry.level}
                      </div>
                      <div className="text-xs text-gray-500">
                        {entry.challengesCompleted} Challenges
                      </div>
                    </div>
                  </div>
                </Card>
              </motion.div>
            ))}
          </div>
        )}

        {/* Footer */}
        <div className="text-center mt-8 py-4 text-gray-500 text-sm">
          <p>Sammle Punkte durch erfolgreiche Challenges!</p>
          <p>🏆 75+ Punkte = Sieg • ⚡ Streak-Bonus verfügbar</p>
        </div>
      </div>
    </div>
  )
}
