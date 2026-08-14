/**
 * AuraEcho - Sensorli Telemetriya va Atrof-Muhit Datchiklari
 * Real qurilma sensorlari (Giroskop, Mikrofon Desibel, Yorug'lik) va aqlli fizik simulyatsiya
 */

class AuraSensorsEngine {
  constructor() {
    this.decibels = 38;
    this.tiltX = 0;
    this.tiltY = 0;
    this.lux = 420;
    this.sensoryIndex = 86;
    
    this.micStream = null;
    this.micAnalyser = null;
    this.isMicActive = false;
    this.listeners = [];

    this.initOrientation();
    this.initLightSensor();
    this.startSimulationLoop();
  }

  /**
   * Giroskop va Qiyalik sensorini ulash
   */
  initOrientation() {
    if (window.DeviceOrientationEvent) {
      window.addEventListener('deviceorientation', (event) => {
        if (event.gamma !== null && event.beta !== null) {
          // Cheklovlar (-30 dan +30 gacha)
          this.tiltX = Math.max(-30, Math.min(30, Math.round(event.gamma)));
          this.tiltY = Math.max(-30, Math.min(30, Math.round(event.beta)));
          this.notify();
        }
      });
    }

    // Desktop foydalanuvchilari uchun sichqoncha harakati orqali interaktiv giroskop
    window.addEventListener('mousemove', (e) => {
      if (!window.DeviceOrientationEvent || (this.tiltX === 0 && this.tiltY === 0)) {
        const xOffset = (e.clientX / window.innerWidth - 0.5) * 40;
        const yOffset = (e.clientY / window.innerHeight - 0.5) * 40;
        this.tiltX = Math.round(xOffset);
        this.tiltY = Math.round(yOffset);
        this.notify();
      }
    });
  }

  /**
   * Yorug'lik datchigi
   */
  initLightSensor() {
    if ('AmbientLightSensor' in window) {
      try {
        const sensor = new AmbientLightSensor();
        sensor.addEventListener('reading', () => {
          this.lux = Math.round(sensor.illuminance);
          this.notify();
        });
        sensor.start();
      } catch (err) {
        // Fallback simulation
      }
    }
  }

  /**
   * Haqiqiy mikrofondan desibel o'lchash (ixtiyoriy foydalanuvchi roziligi bilan)
   */
  async enableLiveMic() {
    try {
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        this.micStream = await navigator.mediaDevices.getUserMedia({ audio: true, video: false });
        if (window.auraAudio && window.auraAudio.ctx) {
          const micSource = window.auraAudio.ctx.createMediaStreamSource(this.micStream);
          this.micAnalyser = window.auraAudio.ctx.createAnalyser();
          this.micAnalyser.fftSize = 64;
          micSource.connect(this.micAnalyser);
          this.isMicActive = true;
          return true;
        }
      }
    } catch (e) {
      console.log("Mikrofon faollashtirilmadi, simulyatsiyadan foydalanilmoqda.");
      this.isMicActive = false;
      return false;
    }
    return false;
  }

  /**
   * Dinamik fizik simulyatsiya tsikli
   */
  startSimulationLoop() {
    let tick = 0;
    setInterval(() => {
      tick += 0.05;

      // 1. Desibel hisoblash
      if (this.isMicActive && this.micAnalyser) {
        const data = new Uint8Array(this.micAnalyser.frequencyBinCount);
        this.micAnalyser.getByteFrequencyData(data);
        let sum = 0;
        for (let i = 0; i < data.length; i++) sum += data[i];
        const avg = sum / data.length;
        this.decibels = Math.min(100, Math.max(25, Math.round(30 + (avg / 255) * 65)));
      } else {
        // Yumshoq tabiiy tebranish
        const noise = Math.sin(tick * 1.5) * 6 + Math.cos(tick * 2.7) * 4;
        this.decibels = Math.round(38 + noise);
      }

      // 2. Lux hisoblash (Kun vaqtiga qarab)
      const hour = new Date().getHours();
      const baseLux = (hour >= 7 && hour <= 19) ? 680 : 160;
      this.lux = Math.round(baseLux + Math.sin(tick * 0.8) * 35);

      // 3. Hissiyot / Fazoviy uyg'unlik indeksi
      const harmony = 100 - Math.abs(this.decibels - 40) * 0.8 - Math.abs(this.tiltX) * 0.3;
      this.sensoryIndex = Math.max(40, Math.min(99, Math.round(harmony)));

      this.notify();
    }, 200);
  }

  subscribe(callback) {
    this.listeners.push(callback);
    callback(this.getSnapshot());
  }

  notify() {
    const data = this.getSnapshot();
    this.listeners.forEach(cb => cb(data));
  }

  getSnapshot() {
    return {
      decibels: this.decibels,
      tiltX: this.tiltX,
      tiltY: this.tiltY,
      lux: this.lux,
      sensoryIndex: this.sensoryIndex,
      isMicActive: this.isMicActive
    };
  }
}

// Global instansiya
window.auraSensors = new AuraSensorsEngine();
