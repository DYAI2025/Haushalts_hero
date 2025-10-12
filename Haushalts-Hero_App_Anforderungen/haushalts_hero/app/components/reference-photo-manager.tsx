

'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Camera, Upload, X, RotateCcw, Check } from 'lucide-react'
import { ChallengeCategory } from '@/lib/types'
import { CATEGORIES } from '@/lib/constants'
import { motion, AnimatePresence } from 'framer-motion'

interface ReferencePhoto {
  id: string
  category: ChallengeCategory
  type: 'clean' | 'dirty'
  imageUrl: string
  timestamp: string
}

interface ReferencePhotoManagerProps {
  category: ChallengeCategory
  onPhotosReady: (cleanRef: string, dirtyRef: string) => void
  onCancel: () => void
}

export default function ReferencePhotoManager({ 
  category, 
  onPhotosReady, 
  onCancel 
}: ReferencePhotoManagerProps) {
  const [cleanPhoto, setCleanPhoto] = useState<string>('')
  const [dirtyPhoto, setDirtyPhoto] = useState<string>('')
  const [currentMode, setCurrentMode] = useState<'clean' | 'dirty' | null>(null)
  const [isCapturing, setIsCapturing] = useState(false)
  
  const categoryInfo = CATEGORIES[category]

  useEffect(() => {
    // Lade gespeicherte Referenzfotos
    loadSavedReferencePhotos()
  }, [category])

  const loadSavedReferencePhotos = () => {
    try {
      const saved = localStorage.getItem(`reference-photos-${category}`)
      if (saved) {
        const photos = JSON.parse(saved)
        if (photos.clean) setCleanPhoto(photos.clean)
        if (photos.dirty) setDirtyPhoto(photos.dirty)
      }
    } catch (error) {
      console.error('Fehler beim Laden der Referenzfotos:', error)
    }
  }

  const saveReferencePhotos = (clean: string, dirty: string) => {
    try {
      localStorage.setItem(`reference-photos-${category}`, JSON.stringify({
        clean,
        dirty,
        timestamp: Date.now()
      }))
    } catch (error) {
      console.error('Fehler beim Speichern der Referenzfotos:', error)
    }
  }

  const handlePhotoCapture = (photoUrl: string) => {
    if (currentMode === 'clean') {
      setCleanPhoto(photoUrl)
    } else if (currentMode === 'dirty') {
      setDirtyPhoto(photoUrl)
    }
    setCurrentMode(null)
    setIsCapturing(false)
  }

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>, type: 'clean' | 'dirty') => {
    const file = event.target.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        const result = e.target?.result as string
        if (type === 'clean') {
          setCleanPhoto(result)
        } else {
          setDirtyPhoto(result)
        }
      }
      reader.readAsDataURL(file)
    }
  }

  const handleContinue = () => {
    if (cleanPhoto && dirtyPhoto) {
      saveReferencePhotos(cleanPhoto, dirtyPhoto)
      onPhotosReady(cleanPhoto, dirtyPhoto)
    }
  }

  const resetPhoto = (type: 'clean' | 'dirty') => {
    if (type === 'clean') {
      setCleanPhoto('')
    } else {
      setDirtyPhoto('')
    }
  }

  if (isCapturing) {
    return (
      <div className="fixed inset-0 bg-black z-50">
        <div className="p-4 text-white">
          <div className="flex justify-between items-center mb-4">
            <Button
              onClick={() => {
                setIsCapturing(false)
                setCurrentMode(null)
              }}
              size="sm"
              variant="ghost"
              className="text-white"
            >
              <X className="h-4 w-4" />
            </Button>
            <h2 className="font-medium">
              {currentMode === 'clean' ? 'Sauberes Referenzfoto' : 'Schmutziges Referenzfoto'}
            </h2>
            <div className="w-8" />
          </div>
        </div>
        
        {/* Hier würde die Kamera-Komponente eingebunden */}
        <div className="flex-1 bg-gray-800 flex items-center justify-center">
          <div className="text-center text-white p-6">
            <Camera className="h-16 w-16 mx-auto mb-4" />
            <p className="mb-4">Kamera nicht verfügbar in dieser Demo</p>
            <Button 
              onClick={() => {
                // Demo: Erstelle ein Platzhalter-Foto
                const canvas = document.createElement('canvas')
                canvas.width = 300
                canvas.height = 200
                const ctx = canvas.getContext('2d')!
                ctx.fillStyle = currentMode === 'clean' ? '#e5f7ff' : '#d4d4d8'
                ctx.fillRect(0, 0, 300, 200)
                ctx.fillStyle = currentMode === 'clean' ? '#0284c7' : '#71717a'
                ctx.font = '20px Arial'
                ctx.textAlign = 'center'
                ctx.fillText(
                  currentMode === 'clean' ? 'SAUBER' : 'SCHMUTZIG', 
                  150, 100
                )
                const photoUrl = canvas.toDataURL()
                handlePhotoCapture(photoUrl)
              }}
              className="bg-white text-black"
            >
              Demo-Foto erstellen
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="mobile-container p-6">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Referenzfotos
          </h1>
          <p className="text-gray-600 text-sm">
            {categoryInfo.name}
          </p>
        </div>
        <Button onClick={onCancel} size="sm" variant="ghost">
          <X className="h-4 w-4" />
        </Button>
      </div>

      {/* Erklärung */}
      <Card className="p-4 mb-6 bg-blue-50">
        <h3 className="font-medium text-blue-900 mb-2">
          🎯 Warum Referenzfotos?
        </h3>
        <p className="text-sm text-blue-800">
          Referenzfotos helfen bei der präzisen Bewertung. Die KI vergleicht deine 
          Fotos mit diesen Standards und kann so den Verschmutzungsgrad besser einschätzen.
        </p>
      </Card>

      {/* Photo Sections */}
      <div className="space-y-6">
        {/* Clean Reference */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center space-x-2">
              <h3 className="font-medium text-gray-900">Sauberer Zustand</h3>
              <Badge variant={cleanPhoto ? 'default' : 'secondary'}>
                {cleanPhoto ? '✓' : 'Erforderlich'}
              </Badge>
            </div>
            {cleanPhoto && (
              <Button
                onClick={() => resetPhoto('clean')}
                size="sm"
                variant="ghost"
              >
                <RotateCcw className="h-4 w-4" />
              </Button>
            )}
          </div>

          <AnimatePresence>
            {cleanPhoto ? (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="relative"
              >
                <img
                  src={cleanPhoto}
                  alt="Sauberer Zustand"
                  className="w-full h-48 object-cover rounded-lg border-2 border-green-200"
                />
                <div className="absolute top-2 right-2">
                  <div className="bg-green-500 text-white rounded-full p-1">
                    <Check className="h-4 w-4" />
                  </div>
                </div>
              </motion.div>
            ) : (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center"
              >
                <div className="space-y-3">
                  <div className="text-4xl">✨</div>
                  <p className="text-sm text-gray-600 mb-4">
                    Zeige wie es aussieht, wenn es perfekt sauber ist
                  </p>
                  <div className="flex flex-col space-y-2">
                    <Button
                      onClick={() => {
                        setCurrentMode('clean')
                        setIsCapturing(true)
                      }}
                      size="sm"
                    >
                      <Camera className="h-4 w-4 mr-2" />
                      Foto aufnehmen
                    </Button>
                    <label className="cursor-pointer">
                      <span className="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input bg-background hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 w-full">
                        <Upload className="h-4 w-4 mr-2" />
                        Datei hochladen
                      </span>
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={(e) => handleFileUpload(e, 'clean')}
                      />
                    </label>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Dirty Reference */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center space-x-2">
              <h3 className="font-medium text-gray-900">Schmutziger Zustand</h3>
              <Badge variant={dirtyPhoto ? 'default' : 'secondary'}>
                {dirtyPhoto ? '✓' : 'Erforderlich'}
              </Badge>
            </div>
            {dirtyPhoto && (
              <Button
                onClick={() => resetPhoto('dirty')}
                size="sm"
                variant="ghost"
              >
                <RotateCcw className="h-4 w-4" />
              </Button>
            )}
          </div>

          <AnimatePresence>
            {dirtyPhoto ? (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="relative"
              >
                <img
                  src={dirtyPhoto}
                  alt="Schmutziger Zustand"
                  className="w-full h-48 object-cover rounded-lg border-2 border-orange-200"
                />
                <div className="absolute top-2 right-2">
                  <div className="bg-orange-500 text-white rounded-full p-1">
                    <Check className="h-4 w-4" />
                  </div>
                </div>
              </motion.div>
            ) : (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center"
              >
                <div className="space-y-3">
                  <div className="text-4xl">💩</div>
                  <p className="text-sm text-gray-600 mb-4">
                    Zeige einen typisch schmutzigen Zustand
                  </p>
                  <div className="flex flex-col space-y-2">
                    <Button
                      onClick={() => {
                        setCurrentMode('dirty')
                        setIsCapturing(true)
                      }}
                      size="sm"
                      variant="outline"
                    >
                      <Camera className="h-4 w-4 mr-2" />
                      Foto aufnehmen
                    </Button>
                    <label className="cursor-pointer">
                      <span className="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 border border-input bg-background hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 w-full">
                        <Upload className="h-4 w-4 mr-2" />
                        Datei hochladen
                      </span>
                      <input
                        type="file"
                        accept="image/*"
                        className="hidden"
                        onChange={(e) => handleFileUpload(e, 'dirty')}
                      />
                    </label>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* Action Button */}
      <div className="mt-8">
        <Button
          onClick={handleContinue}
          disabled={!cleanPhoto || !dirtyPhoto}
          size="lg"
          className="w-full"
        >
          {cleanPhoto && dirtyPhoto ? (
            <>
              <Check className="h-5 w-5 mr-2" />
              Weiter zur Challenge
            </>
          ) : (
            `Noch ${!cleanPhoto && !dirtyPhoto ? '2' : '1'} Foto${!cleanPhoto && !dirtyPhoto ? 's' : ''} benötigt`
          )}
        </Button>
      </div>
    </div>
  )
}

