
'use client'

import { useState, useRef, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Camera, SwitchCamera, X, Circle, RotateCcw, Upload } from 'lucide-react'
import { cameraManager } from '@/lib/camera'
import { ROI_PRESETS } from '@/lib/constants'
import { ChallengeCategory } from '@/lib/types'
import PhotoUploadFallback from './photo-upload-fallback'

interface CameraCaptureProps {
  category: ChallengeCategory
  onCapture: (photo: string) => void
  onCancel: () => void
  isAfterPhoto?: boolean
}

export default function CameraCapture({ 
  category, 
  onCapture, 
  onCancel, 
  isAfterPhoto = false 
}: CameraCaptureProps) {
  const [stream, setStream] = useState<MediaStream | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [showROI, setShowROI] = useState(true)
  const [showUploadFallback, setShowUploadFallback] = useState(false)
  const videoRef = useRef<HTMLVideoElement>(null)

  const roiConfig = ROI_PRESETS[category]

  useEffect(() => {
    startCamera()
    return () => {
      cameraManager.stopCamera()
    }
  }, [])

  const startCamera = async () => {
    setIsLoading(true)
    const result = await cameraManager.startCamera()
    
    if (result.stream && videoRef.current) {
      setStream(result.stream)
      videoRef.current.srcObject = result.stream
      setError(null)
    } else {
      setError(result.error)
    }
    setIsLoading(false)
  }

  const handleCapture = async () => {
    if (!videoRef.current) return
    
    try {
      const photo = await cameraManager.capturePhoto(videoRef.current)
      onCapture(photo)
    } catch (err) {
      setError('Foto konnte nicht aufgenommen werden')
    }
  }

  const handleSwitchCamera = async () => {
    setIsLoading(true)
    const result = await cameraManager.switchCamera()
    
    if (result.stream && videoRef.current) {
      setStream(result.stream)
      videoRef.current.srcObject = result.stream
      setError(null)
    } else {
      setError(result.error)
    }
    setIsLoading(false)
  }

  const toggleROI = () => {
    setShowROI(!showROI)
  }

  if (isLoading) {
    return (
      <div className="fixed inset-0 bg-black flex items-center justify-center z-50">
        <div className="text-white text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-white mx-auto mb-4"></div>
          <p>Kamera wird gestartet...</p>
        </div>
      </div>
    )
  }

  if (showUploadFallback) {
    return (
      <PhotoUploadFallback
        title={isAfterPhoto ? 'Nachher-Foto' : 'Vorher-Foto'}
        description="Lade ein Foto hoch, da die Kamera nicht verfügbar ist"
        onUpload={onCapture}
        onCancel={onCancel}
        onTryCamera={() => {
          setShowUploadFallback(false)
          setError(null)
          startCamera()
        }}
      />
    )
  }

  if (error) {
    return (
      <div className="fixed inset-0 bg-black flex items-center justify-center z-50">
        <div className="text-white text-center max-w-sm mx-auto p-6">
          <Camera className="h-16 w-16 mx-auto mb-4 text-red-400" />
          <p className="mb-4">{error}</p>
          <div className="space-y-2">
            <Button 
              onClick={startCamera} 
              variant="outline" 
              className="w-full text-black"
            >
              <RotateCcw className="h-4 w-4 mr-2" />
              Erneut versuchen
            </Button>
            <Button 
              onClick={() => setShowUploadFallback(true)}
              variant="outline" 
              className="w-full text-black"
            >
              <Upload className="h-4 w-4 mr-2" />
              Foto hochladen
            </Button>
            <Button 
              onClick={onCancel} 
              variant="ghost" 
              className="w-full text-white hover:text-black"
            >
              Abbrechen
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="fixed inset-0 bg-black z-50">
      {/* Header */}
      <div className="absolute top-0 left-0 right-0 z-10 p-4 bg-gradient-to-b from-black/50 to-transparent">
        <div className="flex justify-between items-center">
          <Button
            onClick={onCancel}
            size="sm"
            variant="ghost"
            className="text-white hover:text-black"
          >
            <X className="h-5 w-5" />
          </Button>
          <div className="text-white text-sm font-medium">
            {isAfterPhoto ? 'Nachher-Foto' : 'Vorher-Foto'}
          </div>
          <Button
            onClick={toggleROI}
            size="sm"
            variant="ghost"
            className="text-white hover:text-black text-xs"
          >
            ROI {showROI ? 'Aus' : 'Ein'}
          </Button>
        </div>
      </div>

      {/* Video */}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className="w-full h-full object-cover"
      />

      {/* ROI Overlay */}
      {showROI && (
        <div
          className="absolute roi-overlay"
          style={{
            left: `${roiConfig.x * 100}%`,
            top: `${roiConfig.y * 100}%`,
            width: `${roiConfig.width * 100}%`,
            height: `${roiConfig.height * 100}%`,
          }}
        >
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="bg-blue-500/20 backdrop-blur-sm px-3 py-1 rounded-full">
              <span className="text-white text-sm font-medium">
                Fokusbereich
              </span>
            </div>
          </div>
        </div>
      )}

      {/* Controls */}
      <div className="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/50 to-transparent">
        <div className="flex items-center justify-between">
          <Button
            onClick={handleSwitchCamera}
            size="lg"
            variant="ghost"
            className="text-white hover:text-black"
          >
            <SwitchCamera className="h-6 w-6" />
          </Button>

          <Button
            onClick={handleCapture}
            size="lg"
            className="bg-white text-black hover:bg-gray-200 rounded-full p-6"
          >
            <Circle className="h-8 w-8 fill-current" />
          </Button>

          <div className="w-14"></div> {/* Spacer for centering */}
        </div>
      </div>

      {/* Instructions */}
      <div className="absolute bottom-20 left-0 right-0 text-center">
        <p className="text-white text-sm bg-black/30 backdrop-blur-sm px-4 py-2 rounded-full mx-auto max-w-xs">
          {isAfterPhoto 
            ? 'Zeige das gereinigte Ergebnis'
            : 'Zeige den aktuellen Zustand'
          }
        </p>
      </div>
    </div>
  )
}
