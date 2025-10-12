
import { ChallengeCategory, ScoringResult } from './types';

export class ScoringEngine {
  static async analyzeImages(
    beforeImage: string,
    afterImage: string,
    category: ChallengeCategory,
    roiData?: any
  ): Promise<ScoringResult> {
    // Convert data URLs to ImageData for analysis
    const beforeImageData = await this.getImageData(beforeImage);
    const afterImageData = await this.getImageData(afterImage);
    
    // Lade Referenzfotos falls verfügbar
    const referencePhotos = this.loadReferencePhotos(category);
    let cleanReference: ImageData | null = null;
    let dirtyReference: ImageData | null = null;
    
    if (referencePhotos?.clean) {
      cleanReference = await this.getImageData(referencePhotos.clean);
    }
    if (referencePhotos?.dirty) {
      dirtyReference = await this.getImageData(referencePhotos.dirty);
    }

    switch (category) {
      case ChallengeCategory.MIRROR_CLEANING:
        return this.analyzeMirrorCleaning(
          beforeImageData, 
          afterImageData, 
          roiData,
          cleanReference,
          dirtyReference
        );
      case ChallengeCategory.TOILET_CLEANING:
        return this.analyzeToiletCleaning(
          beforeImageData, 
          afterImageData, 
          roiData,
          cleanReference,
          dirtyReference
        );
      case ChallengeCategory.ROOM_TIDYING:
        return this.analyzeRoomTidying(
          beforeImageData, 
          afterImageData, 
          roiData,
          cleanReference,
          dirtyReference
        );
      default:
        throw new Error('Unbekannte Kategorie');
    }
  }

  private static loadReferencePhotos(category: ChallengeCategory) {
    try {
      const saved = localStorage.getItem(`reference-photos-${category}`);
      return saved ? JSON.parse(saved) : null;
    } catch {
      return null;
    }
  }

  private static async getImageData(dataUrl: string): Promise<ImageData> {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d')!;
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        resolve(ctx.getImageData(0, 0, img.width, img.height));
      };
      img.src = dataUrl;
    });
  }

  private static analyzeMirrorCleaning(
    before: ImageData,
    after: ImageData,
    roi?: any,
    cleanReference?: ImageData | null,
    dirtyReference?: ImageData | null
  ): ScoringResult {
    const edgeDetectionScore = this.calculateEdgeReduction(before, after, roi);
    const reflectionScore = this.calculateReflectionQuality(after, roi);
    const brightnessScore = this.calculateBrightnessImprovement(before, after, roi);
    
    // Referenz-basierte Bewertung
    let referenceScore = 0;
    let referenceBonus = 0;
    let contextualFeedback = '';
    
    if (cleanReference && dirtyReference) {
      // Berechne wie nah das "Before" am "Dirty Reference" ist
      const beforeDirtynessSimilarity = this.calculateImageSimilarity(before, dirtyReference);
      
      // Berechne wie nah das "After" am "Clean Reference" ist  
      const afterCleannessSimilarity = this.calculateImageSimilarity(after, cleanReference);
      
      // Bestimme den Verschmutzungsgrad vom Before-Foto
      const dirtinessLevel = Math.max(0, 100 - beforeDirtynessSimilarity);
      
      // Bonus basierend auf Ausgangs-Verschmutzungsgrad
      if (dirtinessLevel > 70) {
        referenceBonus = 20; // Sehr schmutzig → mehr Punkte möglich
        contextualFeedback = 'Wow! Das war richtig schmutzig und du hast es perfekt sauber bekommen! 🌟';
      } else if (dirtinessLevel > 40) {
        referenceBonus = 10; // Mäßig schmutzig → normale Punkte
        contextualFeedback = 'Gute Arbeit! Der Unterschied ist deutlich sichtbar! 👍';
      } else if (dirtinessLevel < 20) {
        referenceBonus = -15; // War schon sauber → weniger Punkte
        contextualFeedback = 'Es war bereits ziemlich sauber. Trotzdem gut gemacht! ✨';
      }
      
      referenceScore = Math.round(afterCleannessSimilarity + referenceBonus);
    }

    const baseScore = Math.round(
      edgeDetectionScore * 0.3 + 
      reflectionScore * 0.3 + 
      brightnessScore * 0.2 +
      (referenceScore > 0 ? referenceScore * 0.2 : 0)
    );
    
    const finalScore = Math.min(100, Math.max(0, baseScore + referenceBonus));

    return {
      score: finalScore,
      category: ChallengeCategory.MIRROR_CLEANING,
      breakdown: {
        edgeDetection: Math.round(edgeDetectionScore),
        reflectionQuality: Math.round(reflectionScore),
        brightnessAnalysis: Math.round(brightnessScore),
        ...(referenceScore > 0 && { referenceComparison: Math.round(referenceScore) })
      },
      feedback: contextualFeedback || this.generateFeedback(finalScore, 'mirror')
    };
  }

  private static calculateImageSimilarity(img1: ImageData, img2: ImageData): number {
    // Einfache Pixel-basierte Ähnlichkeitsberechnung
    const data1 = img1.data;
    const data2 = img2.data;
    const minLength = Math.min(data1.length, data2.length);
    
    let totalDifference = 0;
    let pixelCount = 0;
    
    for (let i = 0; i < minLength; i += 4) { // RGBA pixels
      const rDiff = Math.abs(data1[i] - data2[i]);
      const gDiff = Math.abs(data1[i + 1] - data2[i + 1]);
      const bDiff = Math.abs(data1[i + 2] - data2[i + 2]);
      
      const pixelDifference = (rDiff + gDiff + bDiff) / 3;
      totalDifference += pixelDifference;
      pixelCount++;
    }
    
    const averageDifference = totalDifference / pixelCount;
    const similarity = Math.max(0, 100 - (averageDifference / 255) * 100);
    
    return similarity;
  }

  private static analyzeToiletCleaning(
    before: ImageData,
    after: ImageData,
    roi?: any,
    cleanReference?: ImageData | null,
    dirtyReference?: ImageData | null
  ): ScoringResult {
    const stainReduction = this.calculateStainReduction(before, after, roi);
    const cleanlinessScore = this.calculateCleanliness(after, roi);
    const brightnessScore = this.calculateBrightnessImprovement(before, after, roi);

    const score = Math.round(
      stainReduction * 0.5 + 
      cleanlinessScore * 0.3 + 
      brightnessScore * 0.2
    );

    return {
      score: Math.min(100, Math.max(0, score)),
      category: ChallengeCategory.TOILET_CLEANING,
      breakdown: {
        stainReduction: Math.round(stainReduction),
        cleanlinessScore: Math.round(cleanlinessScore),
        brightnessAnalysis: Math.round(brightnessScore)
      },
      feedback: this.generateFeedback(score, 'toilet')
    };
  }

  private static analyzeRoomTidying(
    before: ImageData,
    after: ImageData,
    roi?: any,
    cleanReference?: ImageData | null,
    dirtyReference?: ImageData | null
  ): ScoringResult {
    const tidiness = this.calculateTidiness(before, after, roi);
    const freeSpace = this.calculateFreeSpace(after, roi);
    const edgeReduction = this.calculateEdgeReduction(before, after, roi);

    const score = Math.round(
      tidiness * 0.5 + 
      freeSpace * 0.3 + 
      edgeReduction * 0.2
    );

    return {
      score: Math.min(100, Math.max(0, score)),
      category: ChallengeCategory.ROOM_TIDYING,
      breakdown: {
        tidiness: Math.round(tidiness),
        freeSpace: Math.round(freeSpace),
        edgeDetection: Math.round(edgeReduction)
      },
      feedback: this.generateFeedback(score, 'room')
    };
  }

  // Heuristic algorithms
  private static calculateEdgeReduction(before: ImageData, after: ImageData, roi?: any): number {
    const beforeEdges = this.detectEdges(before, roi);
    const afterEdges = this.detectEdges(after, roi);
    
    const reduction = Math.max(0, beforeEdges - afterEdges);
    return Math.min(100, (reduction / beforeEdges) * 100);
  }

  private static detectEdges(imageData: ImageData, roi?: any): number {
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;
    
    let edgeCount = 0;
    const threshold = 50;

    for (let y = 1; y < height - 1; y++) {
      for (let x = 1; x < width - 1; x++) {
        const idx = (y * width + x) * 4;
        
        // Apply ROI filtering if specified
        if (roi && !this.isInROI(x, y, width, height, roi)) continue;
        
        const gray = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
        
        // Simple edge detection using neighboring pixels
        const rightIdx = (y * width + x + 1) * 4;
        const bottomIdx = ((y + 1) * width + x) * 4;
        
        const rightGray = 0.299 * data[rightIdx] + 0.587 * data[rightIdx + 1] + 0.114 * data[rightIdx + 2];
        const bottomGray = 0.299 * data[bottomIdx] + 0.587 * data[bottomIdx + 1] + 0.114 * data[bottomIdx + 2];
        
        const gradientX = Math.abs(gray - rightGray);
        const gradientY = Math.abs(gray - bottomGray);
        const gradient = Math.sqrt(gradientX * gradientX + gradientY * gradientY);
        
        if (gradient > threshold) {
          edgeCount++;
        }
      }
    }
    
    return edgeCount;
  }

  private static calculateReflectionQuality(imageData: ImageData, roi?: any): number {
    // Measure reflection quality by analyzing contrast and brightness uniformity
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;
    
    let totalBrightness = 0;
    let pixelCount = 0;
    const brightnesses: number[] = [];

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        if (roi && !this.isInROI(x, y, width, height, roi)) continue;
        
        const idx = (y * width + x) * 4;
        const brightness = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
        
        brightnesses.push(brightness);
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    const avgBrightness = totalBrightness / pixelCount;
    
    // Calculate variance for uniformity
    const variance = brightnesses.reduce((sum, b) => sum + Math.pow(b - avgBrightness, 2), 0) / pixelCount;
    const uniformity = Math.max(0, 100 - (variance / 100));
    
    // Higher brightness and uniformity = better reflection
    const reflectionScore = (avgBrightness / 255) * 0.6 + (uniformity / 100) * 0.4;
    
    return reflectionScore * 100;
  }

  private static calculateBrightnessImprovement(before: ImageData, after: ImageData, roi?: any): number {
    const beforeBrightness = this.getAverageBrightness(before, roi);
    const afterBrightness = this.getAverageBrightness(after, roi);
    
    const improvement = afterBrightness - beforeBrightness;
    return Math.min(100, Math.max(0, (improvement / 255) * 100 + 50));
  }

  private static calculateStainReduction(before: ImageData, after: ImageData, roi?: any): number {
    const beforeStains = this.detectStains(before, roi);
    const afterStains = this.detectStains(after, roi);
    
    const reduction = Math.max(0, beforeStains - afterStains);
    return beforeStains > 0 ? (reduction / beforeStains) * 100 : 80;
  }

  private static detectStains(imageData: ImageData, roi?: any): number {
    // Detect dark spots/stains
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;
    
    let stainCount = 0;
    const stainThreshold = 80; // Dark pixels

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        if (roi && !this.isInROI(x, y, width, height, roi)) continue;
        
        const idx = (y * width + x) * 4;
        const brightness = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
        
        if (brightness < stainThreshold) {
          stainCount++;
        }
      }
    }
    
    return stainCount;
  }

  private static calculateCleanliness(imageData: ImageData, roi?: any): number {
    const avgBrightness = this.getAverageBrightness(imageData, roi);
    const stainCount = this.detectStains(imageData, roi);
    
    // Higher brightness and fewer stains = cleaner
    const brightnessScore = (avgBrightness / 255) * 100;
    const stainPenalty = Math.min(50, stainCount / 100);
    
    return Math.max(0, brightnessScore - stainPenalty);
  }

  private static calculateTidiness(before: ImageData, after: ImageData, roi?: any): number {
    // Measure reduction in visual complexity (clutter)
    const beforeComplexity = this.calculateVisualComplexity(before, roi);
    const afterComplexity = this.calculateVisualComplexity(after, roi);
    
    const improvement = Math.max(0, beforeComplexity - afterComplexity);
    return beforeComplexity > 0 ? (improvement / beforeComplexity) * 100 : 70;
  }

  private static calculateFreeSpace(imageData: ImageData, roi?: any): number {
    // Estimate free space by analyzing color uniformity and brightness
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;
    
    let uniformAreas = 0;
    let totalPixels = 0;

    for (let y = 1; y < height - 1; y++) {
      for (let x = 1; x < width - 1; x++) {
        if (roi && !this.isInROI(x, y, width, height, roi)) continue;
        
        const idx = (y * width + x) * 4;
        const brightness = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
        
        // Check neighboring pixels for uniformity
        let isUniform = true;
        const threshold = 30;
        
        for (let dy = -1; dy <= 1; dy++) {
          for (let dx = -1; dx <= 1; dx++) {
            const neighborIdx = ((y + dy) * width + (x + dx)) * 4;
            const neighborBrightness = 0.299 * data[neighborIdx] + 0.587 * data[neighborIdx + 1] + 0.114 * data[neighborIdx + 2];
            
            if (Math.abs(brightness - neighborBrightness) > threshold) {
              isUniform = false;
              break;
            }
          }
          if (!isUniform) break;
        }
        
        if (isUniform) uniformAreas++;
        totalPixels++;
      }
    }
    
    return totalPixels > 0 ? (uniformAreas / totalPixels) * 100 : 0;
  }

  private static calculateVisualComplexity(imageData: ImageData, roi?: any): number {
    // Measure visual complexity by counting edge density
    return this.detectEdges(imageData, roi) / (imageData.width * imageData.height) * 10000;
  }

  private static getAverageBrightness(imageData: ImageData, roi?: any): number {
    const data = imageData.data;
    const width = imageData.width;
    const height = imageData.height;
    
    let totalBrightness = 0;
    let pixelCount = 0;

    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        if (roi && !this.isInROI(x, y, width, height, roi)) continue;
        
        const idx = (y * width + x) * 4;
        const brightness = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 0;
  }

  private static isInROI(x: number, y: number, width: number, height: number, roi: any): boolean {
    if (!roi) return true;
    
    const roiX = roi.x * width;
    const roiY = roi.y * height;
    const roiWidth = roi.width * width;
    const roiHeight = roi.height * height;
    
    return x >= roiX && x <= roiX + roiWidth && y >= roiY && y <= roiY + roiHeight;
  }

  private static generateFeedback(score: number, type: string): string {
    const feedbackMap: Record<string, Record<string, string>> = {
      mirror: {
        excellent: "Perfekte Spiegelreinigung! Streifenfrei und kristallklar! 🌟",
        good: "Sehr gut! Der Spiegel glänzt schön, nur noch kleine Verbesserungen möglich.",
        average: "Guter Fortschritt! Ein paar Streifen sind noch sichtbar.",
        poor: "Weiter üben! Versuche es mit kreisförmigen Bewegungen."
      },
      toilet: {
        excellent: "Makellos sauber! Das ist Hygiene auf höchstem Niveau! 🧽✨",
        good: "Sehr sauber! Fast alle Flecken sind verschwunden.",
        average: "Gute Arbeit! Noch ein paar hartnäckige Stellen übrig.",
        poor: "Mehr Putzkraft nötig! Konzentriere dich auf die Flecken."
      },
      room: {
        excellent: "Perfekt aufgeräumt! Ordnung ist das halbe Leben! 🏠",
        good: "Super Organisation! Der Raum sieht viel ordentlicher aus.",
        average: "Guter Anfang! Noch ein paar Gegenstände sortieren.",
        poor: "Weiter machen! Jeder kleine Schritt zählt."
      }
    };

    const category = feedbackMap[type] || feedbackMap.room;
    
    if (score >= 85) return category.excellent;
    if (score >= 70) return category.good;
    if (score >= 50) return category.average;
    return category.poor;
  }
}
