
export interface CameraStream {
  stream: MediaStream | null;
  error: string | null;
  isLoading: boolean;
}

export class CameraManager {
  private stream: MediaStream | null = null;
  private constraints: MediaStreamConstraints;

  constructor(constraints?: MediaStreamConstraints) {
    this.constraints = constraints || {
      video: {
        width: { ideal: 1280 },
        height: { ideal: 720 },
        facingMode: 'environment'
      }
    };
  }

  async startCamera(): Promise<CameraStream> {
    try {
      if (this.stream) {
        this.stopCamera();
      }

      const stream = await navigator.mediaDevices.getUserMedia(this.constraints);
      this.stream = stream;

      return {
        stream,
        error: null,
        isLoading: false
      };
    } catch (error) {
      console.error('Camera error:', error);
      return {
        stream: null,
        error: 'Kamera konnte nicht gestartet werden. Bitte überprüfen Sie die Berechtigungen.',
        isLoading: false
      };
    }
  }

  stopCamera(): void {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
      this.stream = null;
    }
  }

  capturePhoto(videoElement: HTMLVideoElement): Promise<string> {
    return new Promise((resolve) => {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      
      canvas.width = videoElement.videoWidth;
      canvas.height = videoElement.videoHeight;
      
      ctx?.drawImage(videoElement, 0, 0);
      const dataURL = canvas.toDataURL('image/jpeg', 0.8);
      resolve(dataURL);
    });
  }

  async switchCamera(): Promise<CameraStream> {
    const currentFacing = (this.constraints.video as any)?.facingMode;
    const newFacing = currentFacing === 'environment' ? 'user' : 'environment';
    
    this.constraints = {
      ...this.constraints,
      video: {
        ...this.constraints.video as any,
        facingMode: newFacing
      }
    };

    return await this.startCamera();
  }
}

export const cameraManager = new CameraManager();
