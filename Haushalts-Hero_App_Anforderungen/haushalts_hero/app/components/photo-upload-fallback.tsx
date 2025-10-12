

'use client'

import { useState, useRef } from 'react'
import { Button } from '@/components/ui/button'
import { Card } from '@/components/ui/card'
import { Upload, X, RotateCcw, Check, AlertTriangle } from 'lucide-react'
import { motion } from 'framer-motion'

interface PhotoUploadFallbackProps {
  title: string
  description: string
  onUpload: (photo: string) => void
  onCancel: () => void
  onTryCamera?: () => void
}

export default function PhotoUploadFallback({
  title,
  description,
  onUpload,
  onCancel,
  onTryCamera
}: PhotoUploadFallbackProps) {
  const [uploadedPhoto, setUploadedPhoto] = useState<string>('')
  const [isDragging, setIsDragging] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (file: File) => {
    if (file && file.type.startsWith('image/')) {
      const reader = new FileReader()
      reader.onload = (e) => {
        const result = e.target?.result as string
        setUploadedPhoto(result)
      }
      reader.readAsDataURL(file)
    }
  }

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      handleFileSelect(file)
    }
  }

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    setIsDragging(false)
    
    const file = e.dataTransfer.files[0]
    if (file) {
      handleFileSelect(file)
    }
  }

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = () => {
    setIsDragging(false)
  }

  const handleConfirm = () => {
    if (uploadedPhoto) {
      onUpload(uploadedPhoto)
    }
  }

  const resetPhoto = () => {
    setUploadedPhoto('')
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  return (
    <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <motion.div
        initial={{ scale: 0.9, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        className="bg-white rounded-2xl p-6 max-w-md w-full max-h-[90vh] overflow-y-auto"
      >
        {/* Header */}
        <div className="flex justify-between items-start mb-4">
          <div>
            <h2 className="text-xl font-bold text-gray-900">{title}</h2>
            <p className="text-gray-600 text-sm mt-1">{description}</p>
          </div>
          <Button onClick={onCancel} size="sm" variant="ghost">
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Camera Problem Notice */}
        <Card className="p-4 mb-6 bg-yellow-50 border-yellow-200">
          <div className="flex items-start space-x-3">
            <AlertTriangle className="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" />
            <div>
              <h3 className="font-medium text-yellow-900 mb-1">
                Kamera nicht verfügbar
              </h3>
              <p className="text-sm text-yellow-800 mb-3">
                Die Kamera kann nicht gestartet werden. Du kannst stattdessen 
                ein Foto von deinem Gerät hochladen.
              </p>
              {onTryCamera && (
                <Button
                  onClick={onTryCamera}
                  size="sm"
                  variant="outline"
                  className="border-yellow-300 text-yellow-700 hover:bg-yellow-100"
                >
                  Kamera erneut versuchen
                </Button>
              )}
            </div>
          </div>
        </Card>

        {/* Upload Area */}
        {!uploadedPhoto ? (
          <div
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            className={`border-2 border-dashed rounded-xl p-8 text-center transition-all ${
              isDragging
                ? 'border-blue-400 bg-blue-50'
                : 'border-gray-300 hover:border-gray-400'
            }`}
          >
            <div className="space-y-4">
              <div className="text-6xl">📷</div>
              <div>
                <h3 className="font-medium text-gray-900 mb-2">
                  Foto hochladen
                </h3>
                <p className="text-sm text-gray-600 mb-4">
                  Wähle eine Bilddatei oder ziehe sie hierher
                </p>
                
                <Button
                  onClick={() => fileInputRef.current?.click()}
                  className="bg-blue-600 hover:bg-blue-700"
                >
                  <Upload className="h-4 w-4 mr-2" />
                  Datei auswählen
                </Button>
                
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleFileUpload}
                />
              </div>
              
              <div className="text-xs text-gray-500">
                Unterstützte Formate: JPG, PNG, WEBP
              </div>
            </div>
          </div>
        ) : (
          /* Preview */
          <div className="space-y-4">
            <div className="relative">
              <img
                src={uploadedPhoto}
                alt="Hochgeladenes Foto"
                className="w-full h-64 object-cover rounded-lg border-2 border-green-200"
              />
              <div className="absolute top-2 right-2">
                <div className="bg-green-500 text-white rounded-full p-2">
                  <Check className="h-4 w-4" />
                </div>
              </div>
            </div>
            
            <div className="flex space-x-3">
              <Button
                onClick={handleConfirm}
                size="lg"
                className="flex-1 bg-green-600 hover:bg-green-700"
              >
                <Check className="h-4 w-4 mr-2" />
                Foto verwenden
              </Button>
              
              <Button
                onClick={resetPhoto}
                size="lg"
                variant="outline"
                className="flex-1"
              >
                <RotateCcw className="h-4 w-4 mr-2" />
                Ersetzen
              </Button>
            </div>
          </div>
        )}

        {/* Tips */}
        <div className="mt-6 bg-gray-50 rounded-lg p-4">
          <h4 className="font-medium text-gray-900 mb-2 text-sm">
            💡 Tipps für bessere Fotos:
          </h4>
          <ul className="text-xs text-gray-700 space-y-1">
            <li>• Gute Beleuchtung verwenden</li>
            <li>• Foto aus ähnlichem Winkel wie Referenzfotos</li>
            <li>• Scharfes, nicht verwackeltes Bild</li>
            <li>• Den relevanten Bereich komplett erfassen</li>
          </ul>
        </div>
      </motion.div>
    </div>
  )
}

