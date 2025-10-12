
'use client'

import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { Play, Trophy, Clock, Star } from 'lucide-react'
import { CATEGORIES } from '@/lib/constants'
import { ChallengeCategory } from '@/lib/types'

interface ChallengeCardProps {
  category: ChallengeCategory
  onStart: (category: ChallengeCategory) => void
  bestScore?: number
  isPopular?: boolean
  delay?: number
}

export default function ChallengeCard({ 
  category, 
  onStart, 
  bestScore, 
  isPopular,
  delay = 0 
}: ChallengeCardProps) {
  const categoryInfo = CATEGORIES[category]
  
  const getColorClasses = (color: string) => {
    switch (color) {
      case 'blue':
        return {
          bg: 'bg-gradient-to-br from-blue-400 to-blue-600',
          accent: 'bg-blue-500',
          text: 'text-blue-600'
        }
      case 'green':
        return {
          bg: 'bg-gradient-to-br from-green-400 to-green-600',
          accent: 'bg-green-500',
          text: 'text-green-600'
        }
      case 'purple':
        return {
          bg: 'bg-gradient-to-br from-purple-400 to-purple-600',
          accent: 'bg-purple-500',
          text: 'text-purple-600'
        }
      default:
        return {
          bg: 'bg-gradient-to-br from-gray-400 to-gray-600',
          accent: 'bg-gray-500',
          text: 'text-gray-600'
        }
    }
  }

  const colors = getColorClasses(categoryInfo.color)

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      className="relative overflow-hidden rounded-2xl shadow-lg"
    >
      {/* Popular badge */}
      {isPopular && (
        <div className="absolute top-3 right-3 z-10">
          <div className="bg-yellow-400 text-yellow-900 px-2 py-1 rounded-full text-xs font-bold flex items-center">
            <Star className="h-3 w-3 mr-1" />
            Beliebt
          </div>
        </div>
      )}

      <div className={`${colors.bg} p-6 text-white h-full`}>
        {/* Icon and Title */}
        <div className="flex items-start justify-between mb-4">
          <div>
            <div className="text-4xl mb-2">{categoryInfo.icon}</div>
            <h3 className="text-xl font-bold mb-1">
              {categoryInfo.name}
            </h3>
            <p className="text-white/80 text-sm">
              {categoryInfo.description}
            </p>
          </div>
        </div>

        {/* Criteria */}
        <div className="mb-6">
          <div className="text-sm text-white/70 mb-2">Bewertungskriterien:</div>
          <div className="flex flex-wrap gap-2">
            {categoryInfo.criteria.map((criterion, index) => (
              <span
                key={index}
                className="bg-white/20 px-2 py-1 rounded-full text-xs"
              >
                {criterion}
              </span>
            ))}
          </div>
        </div>

        {/* Stats */}
        <div className="flex items-center justify-between mb-6">
          {bestScore ? (
            <div className="flex items-center space-x-2">
              <Trophy className="h-4 w-4 text-yellow-300" />
              <span className="text-sm font-medium">
                Bester Score: {bestScore}
              </span>
            </div>
          ) : (
            <div className="flex items-center space-x-2 text-white/60">
              <Clock className="h-4 w-4" />
              <span className="text-sm">
                Noch nicht versucht
              </span>
            </div>
          )}
        </div>

        {/* Action Button */}
        <Button
          onClick={() => onStart(category)}
          size="lg"
          className="w-full bg-white text-gray-900 hover:bg-gray-100 font-semibold shadow-lg"
        >
          <Play className="h-5 w-5 mr-2" />
          Challenge starten
        </Button>
      </div>
    </motion.div>
  )
}
