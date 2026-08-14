/**
 * AuraEcho - Ultra Kengaytirilgan Fazoviy Audio Studiyasi (Web Audio API)
 * 16 ta procedural tovush qatlamlari, Shaxsiy Tovush Sintezatori va Audio Eksport (WAV/Audio yuklab olish)
 */

class AuraAudioEngine {
  constructor() {
    this.ctx = null;
    this.masterGain = null;
    this.analyser = null;
    this.isInitialized = false;

    // 16 ta standart tovush kanallari
    this.channelKeys = [
      'rain', 'forest', 'binaural', 'ocean',
      'thunder', 'campfire', 'coffeeshop', 'cosmic',
      'tibetan', 'stream', 'nightcity', 'noises',
      'leaves', 'train', 'clock', 'piano'
    ];

    this.channels = {};
    this.channelKeys.forEach(k => {
      this.channels[k] = {
        active: false,
        gainNode: null,
        pannerNode: null,
        nodes: [],
        volume: 0.5,
        pan: 0,
        intervalId: null
      };
    });

    // Standart qulay boshlang'ich ovoz darajalari
    this.channels.rain.volume = 0.6;
    this.channels.ocean.volume = 0.6;
    this.channels.campfire.volume = 0.55;
    this.channels.cosmic.volume = 0.45;
    this.channels.piano.volume = 0.55;

    // Shaxsiy sintezator holati (Custom Synthesizer)
    this.customChannel = {
      active: false,
      gainNode: null,
      pannerNode: null,
      nodes: [],
      volume: 0.6,
      pan: 0,
      config: {
        waveType: 'sine',
        freq: 220,
        filterType: 'lowpass',
        filterFreq: 800,
        lfoFreq: 2,
        lfoDepth: 50
      }
    };
  }

  /**
   * AudioContext-ni uyg'otish (Browser Autoplay xavfsizligi)
   */
  init() {
    if (this.isInitialized && this.ctx) {
      if (this.ctx.state === 'suspended') {
        this.ctx.resume();
      }
      return;
    }

    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (!AudioContextClass) {
      console.warn("Web Audio API qo'llab-quvvatlanmaydi.");
      return;
    }

    this.ctx = new AudioContextClass();

    this.masterGain = this.ctx.createGain();
    this.masterGain.gain.setValueAtTime(0.85, this.ctx.currentTime);

    this.analyser = this.ctx.createAnalyser();
    this.analyser.fftSize = 128;
    this.analyser.smoothingTimeConstant = 0.82;

    this.masterGain.connect(this.analyser);
    this.analyser.connect(this.ctx.destination);

    this.isInitialized = true;
  }

  ensureRunning() {
    this.init();
    if (this.ctx && this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  /**
   * iOS Taptic Feedback
   */
  playTaptic(type = 'light') {
    try {
      this.ensureRunning();
      if (!this.ctx) return;

      const now = this.ctx.currentTime;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.connect(gain);
      gain.connect(this.masterGain);

      if (type === 'light') {
        osc.frequency.setValueAtTime(1400, now);
        osc.frequency.exponentialRampToValueAtTime(300, now + 0.015);
        gain.gain.setValueAtTime(0.08, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.015);
        osc.start(now);
        osc.stop(now + 0.016);
      } else if (type === 'medium') {
        osc.frequency.setValueAtTime(900, now);
        osc.frequency.exponentialRampToValueAtTime(120, now + 0.03);
        gain.gain.setValueAtTime(0.12, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.03);
        osc.start(now);
        osc.stop(now + 0.032);
      } else if (type === 'success') {
        osc.frequency.setValueAtTime(523.25, now);
        osc.frequency.setValueAtTime(659.25, now + 0.05);
        gain.gain.setValueAtTime(0.1, now);
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
        osc.start(now);
        osc.stop(now + 0.13);
      }
    } catch (e) {}
  }

  /* --------------------------------------------------------------------------
     Shovqin Buferlari Yaratish
     -------------------------------------------------------------------------- */
  createWhiteNoiseBuffer(seconds = 5) {
    if (!this.ctx) return null;
    const bufferSize = this.ctx.sampleRate * seconds;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) data[i] = Math.random() * 2 - 1;
    return buffer;
  }

  createPinkNoiseBuffer(seconds = 6) {
    if (!this.ctx) return null;
    const bufferSize = this.ctx.sampleRate * seconds;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      b0 = 0.99886 * b0 + white * 0.0555179;
      b1 = 0.99332 * b1 + white * 0.0750759;
      b2 = 0.96900 * b2 + white * 0.1538520;
      b3 = 0.86650 * b3 + white * 0.3104856;
      b4 = 0.55000 * b4 + white * 0.5329522;
      b5 = -0.7616 * b5 - white * 0.0168980;
      data[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11;
      b6 = white * 0.115926;
    }
    return buffer;
  }

  createBrownNoiseBuffer(seconds = 6) {
    if (!this.ctx) return null;
    const bufferSize = this.ctx.sampleRate * seconds;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    let lastOut = 0.0;
    for (let i = 0; i < bufferSize; i++) {
      const white = Math.random() * 2 - 1;
      data[i] = (lastOut + (0.02 * white)) / 1.02;
      lastOut = data[i];
      data[i] *= 3.5;
    }
    return buffer;
  }

  createPanner(panValue = 0) {
    if (this.ctx && this.ctx.createStereoPanner) {
      const panner = this.ctx.createStereoPanner();
      panner.pan.setValueAtTime(panValue, this.ctx.currentTime);
      return panner;
    }
    return this.ctx.createGain();
  }

  prepareChannel(channelKey) {
    this.ensureRunning();
    const ch = this.channels[channelKey];
    ch.gainNode = this.ctx.createGain();
    ch.gainNode.gain.setValueAtTime(ch.volume, this.ctx.currentTime);
    ch.pannerNode = this.createPanner(ch.pan);
    ch.gainNode.connect(ch.pannerNode);
    ch.pannerNode.connect(this.masterGain);
    return ch;
  }

  /* --------------------------------------------------------------------------
     1-12. STANDART 12 TA TOVUSHLAR
     -------------------------------------------------------------------------- */
  startRain() {
    if (this.channels.rain.active) return;
    const ch = this.prepareChannel('rain');
    const noiseBuffer = this.createPinkNoiseBuffer(5);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = noiseBuffer;
    noiseSrc.loop = true;

    const bandpass = this.ctx.createBiquadFilter();
    bandpass.type = 'bandpass';
    bandpass.frequency.setValueAtTime(1100, this.ctx.currentTime);
    bandpass.Q.setValueAtTime(0.8, this.ctx.currentTime);

    const lowpass = this.ctx.createBiquadFilter();
    lowpass.type = 'lowpass';
    lowpass.frequency.setValueAtTime(3200, this.ctx.currentTime);

    noiseSrc.connect(bandpass);
    bandpass.connect(lowpass);
    lowpass.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, bandpass, lowpass);

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      this.triggerRainDrop(ch.gainNode);
    }, 180);
    ch.active = true;
  }

  triggerRainDrop(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const dropGain = this.ctx.createGain();
    const filter = this.ctx.createBiquadFilter();
    const freq = 1200 + Math.random() * 1400;
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, now);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.4, now + 0.04);
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(freq, now);
    dropGain.gain.setValueAtTime(0.04 * Math.random(), now);
    dropGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.045);
    osc.connect(filter);
    filter.connect(dropGain);
    dropGain.connect(targetGain);
    osc.start(now);
    osc.stop(now + 0.05);
  }

  startForest() {
    if (this.channels.forest.active) return;
    const ch = this.prepareChannel('forest');
    const noiseBuffer = this.createPinkNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = noiseBuffer;
    noiseSrc.loop = true;

    const windFilter = this.ctx.createBiquadFilter();
    windFilter.type = 'bandpass';
    windFilter.frequency.setValueAtTime(400, this.ctx.currentTime);
    windFilter.Q.setValueAtTime(2.5, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(0.18, this.ctx.currentTime);
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(250, this.ctx.currentTime);
    lfo.connect(lfoGain);
    lfoGain.connect(windFilter.frequency);

    noiseSrc.connect(windFilter);
    windFilter.connect(ch.gainNode);
    noiseSrc.start();
    lfo.start();
    ch.nodes.push(noiseSrc, windFilter, lfo, lfoGain);

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      if (Math.random() > 0.35) this.triggerBirdChirp(ch.gainNode);
    }, 3500);
    ch.active = true;
  }

  triggerBirdChirp(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const chirpGain = this.ctx.createGain();
    const baseF = 2400 + Math.random() * 800;
    osc.type = 'sine';
    osc.frequency.setValueAtTime(baseF, now);
    osc.frequency.exponentialRampToValueAtTime(baseF * 1.5, now + 0.08);
    osc.frequency.exponentialRampToValueAtTime(baseF * 0.9, now + 0.16);
    osc.frequency.exponentialRampToValueAtTime(baseF * 1.3, now + 0.24);
    chirpGain.gain.setValueAtTime(0.001, now);
    chirpGain.gain.exponentialRampToValueAtTime(0.04, now + 0.04);
    chirpGain.gain.exponentialRampToValueAtTime(0.0001, now + 0.26);
    osc.connect(chirpGain);
    chirpGain.connect(targetGain);
    osc.start(now);
    osc.stop(now + 0.28);
  }

  startBinaural() {
    if (this.channels.binaural.active) return;
    const ch = this.prepareChannel('binaural');
    const baseFreq = 200, beatFreq = 6;
    const merger = this.ctx.createChannelMerger(2);

    const oscLeft = this.ctx.createOscillator();
    oscLeft.type = 'sine';
    oscLeft.frequency.setValueAtTime(baseFreq, this.ctx.currentTime);
    const gainLeft = this.ctx.createGain();
    gainLeft.gain.setValueAtTime(0.5, this.ctx.currentTime);
    oscLeft.connect(gainLeft);
    gainLeft.connect(merger, 0, 0);

    const oscRight = this.ctx.createOscillator();
    oscRight.type = 'sine';
    oscRight.frequency.setValueAtTime(baseFreq + beatFreq, this.ctx.currentTime);
    const gainRight = this.ctx.createGain();
    gainRight.gain.setValueAtTime(0.5, this.ctx.currentTime);
    oscRight.connect(gainRight);
    gainRight.connect(merger, 0, 1);

    const subOsc = this.ctx.createOscillator();
    subOsc.type = 'triangle';
    subOsc.frequency.setValueAtTime(baseFreq / 2, this.ctx.currentTime);
    const subGain = this.ctx.createGain();
    subGain.gain.setValueAtTime(0.12, this.ctx.currentTime);
    subOsc.connect(subGain);

    merger.connect(ch.gainNode);
    subGain.connect(ch.gainNode);
    oscLeft.start();
    oscRight.start();
    subOsc.start();
    ch.nodes.push(oscLeft, oscRight, subOsc, gainLeft, gainRight, subGain, merger);
    ch.active = true;
  }

  startOcean() {
    if (this.channels.ocean.active) return;
    const ch = this.prepareChannel('ocean');
    const brownBuffer = this.createBrownNoiseBuffer(7);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = brownBuffer;
    noiseSrc.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(380, this.ctx.currentTime);

    const waveGain = this.ctx.createGain();
    waveGain.gain.setValueAtTime(0.3, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(0.11, this.ctx.currentTime);
    const lfoDepth = this.ctx.createGain();
    lfoDepth.gain.setValueAtTime(0.28, this.ctx.currentTime);
    lfo.connect(lfoDepth);
    lfoDepth.connect(waveGain.gain);

    noiseSrc.connect(filter);
    filter.connect(waveGain);
    waveGain.connect(ch.gainNode);
    noiseSrc.start();
    lfo.start();
    ch.nodes.push(noiseSrc, filter, waveGain, lfo, lfoDepth);
    ch.active = true;
  }

  startThunder() {
    if (this.channels.thunder.active) return;
    const ch = this.prepareChannel('thunder');
    const brownBuffer = this.createBrownNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = brownBuffer;
    noiseSrc.loop = true;

    const lowpass = this.ctx.createBiquadFilter();
    lowpass.type = 'lowpass';
    lowpass.frequency.setValueAtTime(140, this.ctx.currentTime);
    noiseSrc.connect(lowpass);
    lowpass.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, lowpass);

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      if (Math.random() > 0.4) this.triggerThunderStrike(ch.gainNode);
    }, 6000);
    ch.active = true;
  }

  triggerThunderStrike(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const strikeNoise = this.ctx.createBufferSource();
    strikeNoise.buffer = this.createBrownNoiseBuffer(4);
    const filter = this.ctx.createBiquadFilter();
    filter.type = 'lowpass';
    filter.frequency.setValueAtTime(280, now);
    filter.frequency.exponentialRampToValueAtTime(70, now + 3.2);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(0.01, now);
    gain.gain.linearRampToValueAtTime(0.65, now + 0.15);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 3.5);

    strikeNoise.connect(filter);
    filter.connect(gain);
    gain.connect(targetGain);
    strikeNoise.start(now);
    strikeNoise.stop(now + 3.6);
  }

  startCampfire() {
    if (this.channels.campfire.active) return;
    const ch = this.prepareChannel('campfire');
    const brownBuffer = this.createBrownNoiseBuffer(5);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = brownBuffer;
    noiseSrc.loop = true;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'bandpass';
    filter.frequency.setValueAtTime(240, this.ctx.currentTime);
    filter.Q.setValueAtTime(1.5, this.ctx.currentTime);

    noiseSrc.connect(filter);
    filter.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, filter);

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      this.triggerFireCrackle(ch.gainNode);
    }, 120);
    ch.active = true;
  }

  triggerFireCrackle(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const burst = this.ctx.createBufferSource();
    const len = Math.floor(this.ctx.sampleRate * 0.015);
    const buf = this.ctx.createBuffer(1, len, this.ctx.sampleRate);
    const data = buf.getChannelData(0);
    for (let i = 0; i < len; i++) data[i] = (Math.random() * 2 - 1) * Math.exp(-i / (len * 0.3));
    burst.buffer = buf;

    const hp = this.ctx.createBiquadFilter();
    hp.type = 'highpass';
    hp.frequency.setValueAtTime(1200 + Math.random() * 2000, now);
    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(Math.random() > 0.7 ? 0.3 : 0.08, now);

    burst.connect(hp);
    hp.connect(gain);
    gain.connect(targetGain);
    burst.start(now);
    burst.stop(now + 0.02);
  }

  startCoffeeshop() {
    if (this.channels.coffeeshop.active) return;
    const ch = this.prepareChannel('coffeeshop');
    const pinkBuffer = this.createPinkNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = pinkBuffer;
    noiseSrc.loop = true;

    const bp = this.ctx.createBiquadFilter();
    bp.type = 'bandpass';
    bp.frequency.setValueAtTime(550, this.ctx.currentTime);
    bp.Q.setValueAtTime(0.9, this.ctx.currentTime);

    noiseSrc.connect(bp);
    bp.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, bp);

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      if (Math.random() > 0.6) this.triggerCupClink(ch.gainNode);
    }, 2800);
    ch.active = true;
  }

  triggerCupClink(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    const freq = 1900 + Math.random() * 1200;
    osc.type = 'sine';
    osc.frequency.setValueAtTime(freq, now);
    gain.gain.setValueAtTime(0.05, now);
    gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.2);
    osc.connect(gain);
    gain.connect(targetGain);
    osc.start(now);
    osc.stop(now + 0.22);
  }

  startCosmic() {
    if (this.channels.cosmic.active) return;
    const ch = this.prepareChannel('cosmic');
    const rootFreq = 108;

    const osc1 = this.ctx.createOscillator();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(rootFreq, this.ctx.currentTime);

    const osc2 = this.ctx.createOscillator();
    osc2.type = 'triangle';
    osc2.frequency.setValueAtTime(rootFreq * 2, this.ctx.currentTime);

    const osc3 = this.ctx.createOscillator();
    osc3.type = 'sine';
    osc3.frequency.setValueAtTime(rootFreq * 4, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(0.08, this.ctx.currentTime);
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(3.5, this.ctx.currentTime);
    lfo.connect(lfoGain);
    lfoGain.connect(osc2.frequency);

    const gain1 = this.ctx.createGain(); gain1.gain.setValueAtTime(0.4, this.ctx.currentTime);
    const gain2 = this.ctx.createGain(); gain2.gain.setValueAtTime(0.2, this.ctx.currentTime);
    const gain3 = this.ctx.createGain(); gain3.gain.setValueAtTime(0.15, this.ctx.currentTime);

    osc1.connect(gain1); osc2.connect(gain2); osc3.connect(gain3);
    gain1.connect(ch.gainNode); gain2.connect(ch.gainNode); gain3.connect(ch.gainNode);

    osc1.start(); osc2.start(); osc3.start(); lfo.start();
    ch.nodes.push(osc1, osc2, osc3, lfo, lfoGain, gain1, gain2, gain3);
    ch.active = true;
  }

  startTibetan() {
    if (this.channels.tibetan.active) return;
    const ch = this.prepareChannel('tibetan');
    this.triggerSingingBowl(ch.gainNode);
    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      this.triggerSingingBowl(ch.gainNode);
    }, 7000);
    ch.active = true;
  }

  triggerSingingBowl(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const baseFreqs = [288, 384, 432, 576];
    const baseF = baseFreqs[Math.floor(Math.random() * baseFreqs.length)];

    const osc1 = this.ctx.createOscillator();
    osc1.type = 'sine';
    osc1.frequency.setValueAtTime(baseF, now);

    const osc2 = this.ctx.createOscillator();
    osc2.type = 'sine';
    osc2.frequency.setValueAtTime(baseF * 2.76, now);

    const gain1 = this.ctx.createGain();
    gain1.gain.setValueAtTime(0.01, now);
    gain1.gain.linearRampToValueAtTime(0.35, now + 0.1);
    gain1.gain.exponentialRampToValueAtTime(0.0001, now + 6.5);

    const gain2 = this.ctx.createGain();
    gain2.gain.setValueAtTime(0.01, now);
    gain2.gain.linearRampToValueAtTime(0.12, now + 0.05);
    gain2.gain.exponentialRampToValueAtTime(0.0001, now + 4.5);

    osc1.connect(gain1); osc2.connect(gain2);
    gain1.connect(targetGain); gain2.connect(targetGain);
    osc1.start(now); osc2.start(now);
    osc1.stop(now + 6.8); osc2.stop(now + 6.8);
  }

  startStream() {
    if (this.channels.stream.active) return;
    const ch = this.prepareChannel('stream');
    const pinkBuffer = this.createPinkNoiseBuffer(5);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = pinkBuffer;
    noiseSrc.loop = true;

    const bp = this.ctx.createBiquadFilter();
    bp.type = 'bandpass';
    bp.frequency.setValueAtTime(900, this.ctx.currentTime);
    bp.Q.setValueAtTime(1.8, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(1.2, this.ctx.currentTime);
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(220, this.ctx.currentTime);
    lfo.connect(lfoGain);
    lfoGain.connect(bp.frequency);

    noiseSrc.connect(bp);
    bp.connect(ch.gainNode);
    noiseSrc.start();
    lfo.start();
    ch.nodes.push(noiseSrc, bp, lfo, lfoGain);
    ch.active = true;
  }

  startNightcity() {
    if (this.channels.nightcity.active) return;
    const ch = this.prepareChannel('nightcity');
    const brownBuffer = this.createBrownNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = brownBuffer;
    noiseSrc.loop = true;

    const lp = this.ctx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.setValueAtTime(260, this.ctx.currentTime);
    noiseSrc.connect(lp);
    lp.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, lp);
    ch.active = true;
  }

  startNoises() {
    if (this.channels.noises.active) return;
    const ch = this.prepareChannel('noises');
    const pinkBuf = this.createPinkNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = pinkBuf;
    noiseSrc.loop = true;

    const lp = this.ctx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.setValueAtTime(800, this.ctx.currentTime);
    noiseSrc.connect(lp);
    lp.connect(ch.gainNode);
    noiseSrc.start();
    ch.nodes.push(noiseSrc, lp);
    ch.active = true;
  }

  /* --------------------------------------------------------------------------
     13-16. YANGI QO'SHILGAN 4 TA TOVUSH QATLAMI
     -------------------------------------------------------------------------- */
  // 13. Kuzgi Barglar Shovqini & Shamol (Autumn Leaves Rustle)
  startLeaves() {
    if (this.channels.leaves.active) return;
    const ch = this.prepareChannel('leaves');
    const pinkBuf = this.createPinkNoiseBuffer(6);
    const noiseSrc = this.ctx.createBufferSource();
    noiseSrc.buffer = pinkBuf;
    noiseSrc.loop = true;

    const bp = this.ctx.createBiquadFilter();
    bp.type = 'bandpass';
    bp.frequency.setValueAtTime(1400, this.ctx.currentTime);
    bp.Q.setValueAtTime(3.2, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(0.4, this.ctx.currentTime);
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(600, this.ctx.currentTime);
    lfo.connect(lfoGain);
    lfoGain.connect(bp.frequency);

    noiseSrc.connect(bp);
    bp.connect(ch.gainNode);
    noiseSrc.start();
    lfo.start();
    ch.nodes.push(noiseSrc, bp, lfo, lfoGain);
    ch.active = true;
  }

  // 14. Tungi Poyezd va Relslar Ruxsati (Night Train Rhythm)
  startTrain() {
    if (this.channels.train.active) return;
    const ch = this.prepareChannel('train');

    // Past g'uvillash
    const brownBuf = this.createBrownNoiseBuffer(6);
    const humSrc = this.ctx.createBufferSource();
    humSrc.buffer = brownBuf;
    humSrc.loop = true;
    const lp = this.ctx.createBiquadFilter();
    lp.type = 'lowpass';
    lp.frequency.setValueAtTime(180, this.ctx.currentTime);
    humSrc.connect(lp);
    lp.connect(ch.gainNode);
    humSrc.start();
    ch.nodes.push(humSrc, lp);

    // Relslar chertilishi ritmi (Rhythmic train clicks)
    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      this.triggerTrainClick(ch.gainNode);
    }, 600);
    ch.active = true;
  }

  triggerTrainClick(targetGain) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    [0, 0.12].forEach(offset => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(120, now + offset);
      gain.gain.setValueAtTime(0.18, now + offset);
      gain.gain.exponentialRampToValueAtTime(0.001, now + offset + 0.05);
      osc.connect(gain);
      gain.connect(targetGain);
      osc.start(now + offset);
      osc.stop(now + offset + 0.06);
    });
  }

  // 15. Qadimiy Soat Tik-Taki (Antique Clock Pendulum)
  startClock() {
    if (this.channels.clock.active) return;
    const ch = this.prepareChannel('clock');
    let isTick = true;

    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      const now = this.ctx.currentTime;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      const freq = isTick ? 850 : 620;
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now);
      gain.gain.setValueAtTime(0.22, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.04);
      osc.connect(gain);
      gain.connect(ch.gainNode);
      osc.start(now);
      osc.stop(now + 0.045);
      isTick = !isTick;
    }, 1000);
    ch.active = true;
  }

  // 16. Ambient Pianino Garmoniyasi (Neoclassical Ambient Piano Chords)
  startPiano() {
    if (this.channels.piano.active) return;
    const ch = this.prepareChannel('piano');
    const pentatonicNotes = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25, 587.33, 659.25]; // C D E G A

    this.triggerPianoChord(ch.gainNode, pentatonicNotes);
    ch.intervalId = setInterval(() => {
      if (!ch.active || !this.ctx) return;
      this.triggerPianoChord(ch.gainNode, pentatonicNotes);
    }, 4500);
    ch.active = true;
  }

  triggerPianoChord(targetGain, notes) {
    if (!this.ctx) return;
    const now = this.ctx.currentTime;
    const note1 = notes[Math.floor(Math.random() * notes.length)];
    const note2 = notes[Math.floor(Math.random() * notes.length)];

    [note1, note2].forEach((freq, idx) => {
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();
      const filter = this.ctx.createBiquadFilter();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, now + idx * 0.08);

      filter.type = 'lowpass';
      filter.frequency.setValueAtTime(1400, now);

      gain.gain.setValueAtTime(0.01, now + idx * 0.08);
      gain.gain.linearRampToValueAtTime(0.28, now + idx * 0.08 + 0.06);
      gain.gain.exponentialRampToValueAtTime(0.0001, now + idx * 0.08 + 4.2);

      osc.connect(filter);
      filter.connect(gain);
      gain.connect(targetGain);

      osc.start(now + idx * 0.08);
      osc.stop(now + idx * 0.08 + 4.5);
    });
  }

  /* --------------------------------------------------------------------------
     SHAXSIY TOVUSH SINTEZATORI (Custom Sound Synthesizer)
     -------------------------------------------------------------------------- */
  startCustomSound(config) {
    this.ensureRunning();
    this.stopCustomSound();

    const ch = this.customChannel;
    ch.config = Object.assign(ch.config, config);
    ch.gainNode = this.ctx.createGain();
    ch.gainNode.gain.setValueAtTime(ch.volume, this.ctx.currentTime);
    ch.pannerNode = this.createPanner(ch.pan);
    ch.gainNode.connect(ch.pannerNode);
    ch.pannerNode.connect(this.masterGain);

    const cfg = ch.config;
    let sourceNode;

    if (cfg.waveType === 'white') {
      sourceNode = this.ctx.createBufferSource();
      sourceNode.buffer = this.createWhiteNoiseBuffer(5);
      sourceNode.loop = true;
    } else if (cfg.waveType === 'pink') {
      sourceNode = this.ctx.createBufferSource();
      sourceNode.buffer = this.createPinkNoiseBuffer(6);
      sourceNode.loop = true;
    } else if (cfg.waveType === 'brown') {
      sourceNode = this.ctx.createBufferSource();
      sourceNode.buffer = this.createBrownNoiseBuffer(6);
      sourceNode.loop = true;
    } else {
      sourceNode = this.ctx.createOscillator();
      sourceNode.type = cfg.waveType || 'sine';
      sourceNode.frequency.setValueAtTime(cfg.freq || 220, this.ctx.currentTime);
    }

    // Filtr
    const filter = this.ctx.createBiquadFilter();
    filter.type = cfg.filterType || 'lowpass';
    filter.frequency.setValueAtTime(cfg.filterFreq || 800, this.ctx.currentTime);
    filter.Q.setValueAtTime(2.0, this.ctx.currentTime);

    // LFO modulyatsiyasi
    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(cfg.lfoFreq || 2, this.ctx.currentTime);
    const lfoGain = this.ctx.createGain();
    lfoGain.gain.setValueAtTime(cfg.lfoDepth || 50, this.ctx.currentTime);
    lfo.connect(lfoGain);
    lfoGain.connect(filter.frequency);

    sourceNode.connect(filter);
    filter.connect(ch.gainNode);

    sourceNode.start();
    lfo.start();
    ch.nodes.push(sourceNode, filter, lfo, lfoGain);
    ch.active = true;
  }

  stopCustomSound() {
    const ch = this.customChannel;
    if (!ch.active) return;
    ch.nodes.forEach(n => {
      try { n.stop(); } catch (e) {}
      try { n.disconnect(); } catch (e) {}
    });
    ch.nodes = [];
    ch.active = false;
  }

  /* --------------------------------------------------------------------------
     Umumiy Boshqaruv
     -------------------------------------------------------------------------- */
  stopGenericChannel(channelKey) {
    const ch = this.channels[channelKey];
    if (!ch || !ch.active) return;
    if (ch.intervalId) clearInterval(ch.intervalId);
    ch.nodes.forEach(n => {
      try { n.stop(); } catch (e) {}
      try { n.disconnect(); } catch (e) {}
    });
    ch.nodes = [];
    ch.active = false;
  }

  toggleChannel(channelKey, shouldPlay) {
    this.ensureRunning();
    if (shouldPlay) {
      switch (channelKey) {
        case 'rain': this.startRain(); break;
        case 'forest': this.startForest(); break;
        case 'binaural': this.startBinaural(); break;
        case 'ocean': this.startOcean(); break;
        case 'thunder': this.startThunder(); break;
        case 'campfire': this.startCampfire(); break;
        case 'coffeeshop': this.startCoffeeshop(); break;
        case 'cosmic': this.startCosmic(); break;
        case 'tibetan': this.startTibetan(); break;
        case 'stream': this.startStream(); break;
        case 'nightcity': this.startNightcity(); break;
        case 'noises': this.startNoises(); break;
        case 'leaves': this.startLeaves(); break;
        case 'train': this.startTrain(); break;
        case 'clock': this.startClock(); break;
        case 'piano': this.startPiano(); break;
      }
    } else {
      this.stopGenericChannel(channelKey);
    }
  }

  setVolume(channelKey, value) {
    this.ensureRunning();
    const ch = this.channels[channelKey];
    if (!ch) return;
    ch.volume = parseFloat(value);
    if (ch.gainNode && this.ctx) {
      ch.gainNode.gain.setTargetAtTime(ch.volume, this.ctx.currentTime, 0.02);
    }
  }

  setPan(channelKey, value) {
    this.ensureRunning();
    const ch = this.channels[channelKey];
    if (!ch) return;
    ch.pan = parseFloat(value);
    if (ch.pannerNode && ch.pannerNode.pan && this.ctx) {
      ch.pannerNode.pan.setTargetAtTime(ch.pan, this.ctx.currentTime, 0.02);
    }
  }

  setMasterVolume(value) {
    this.ensureRunning();
    if (!this.masterGain || !this.ctx) return;
    const vol = parseFloat(value);
    this.masterGain.gain.setTargetAtTime(vol, this.ctx.currentTime, 0.02);
  }

  stopAll() {
    this.channelKeys.forEach(k => this.stopGenericChannel(k));
    this.stopCustomSound();
  }

  applyPreset(presetName) {
    this.ensureRunning();
    this.stopAll();

    switch (presetName) {
      case 'focus':
        this.setVolume('rain', 0.6);
        this.setVolume('binaural', 0.5);
        this.startRain();
        this.startBinaural();
        break;
      case 'calm':
        this.setVolume('forest', 0.6);
        this.setVolume('ocean', 0.5);
        this.setVolume('stream', 0.4);
        this.startForest();
        this.startOcean();
        this.startStream();
        break;
      case 'meditation':
        this.setVolume('tibetan', 0.7);
        this.setVolume('cosmic', 0.5);
        this.setVolume('binaural', 0.5);
        this.startTibetan();
        this.startCosmic();
        this.startBinaural();
        break;
      case 'campfire':
        this.setVolume('campfire', 0.7);
        this.setVolume('forest', 0.4);
        this.setVolume('nightcity', 0.3);
        this.startCampfire();
        this.startForest();
        this.startNightcity();
        break;
      case 'storm':
        this.setVolume('rain', 0.7);
        this.setVolume('thunder', 0.7);
        this.setVolume('forest', 0.3);
        this.startRain();
        this.startThunder();
        this.startForest();
        break;
      case 'cafe':
        this.setVolume('coffeeshop', 0.65);
        this.setVolume('rain', 0.45);
        this.startCoffeeshop();
        this.startRain();
        break;
      case 'space':
        this.setVolume('cosmic', 0.75);
        this.setVolume('binaural', 0.45);
        this.startCosmic();
        this.startBinaural();
        break;
      case 'creative':
        this.setVolume('piano', 0.65);
        this.setVolume('leaves', 0.5);
        this.setVolume('rain', 0.4);
        this.startPiano();
        this.startLeaves();
        this.startRain();
        break;
      case 'train':
        this.setVolume('train', 0.7);
        this.setVolume('rain', 0.5);
        this.startTrain();
        this.startRain();
        break;
    }
  }

  /* --------------------------------------------------------------------------
     AUDIO YUKLAB OLISH (WAV / MP3 Formatda Brauzerda Render Qilish)
     -------------------------------------------------------------------------- */
  async exportAudioToFile(target = 'active_mix', duration = 12, fileName = 'AuraEcho_Fazoviy_Miks.wav') {
    const sampleRate = 44100;
    const totalSamples = sampleRate * duration;
    const offlineCtx = new (window.OfflineAudioContext || window.webkitOfflineAudioContext)(2, totalSamples, sampleRate);

    const masterGain = offlineCtx.createGain();
    masterGain.gain.setValueAtTime(0.85, 0);
    masterGain.connect(offlineCtx.destination);

    // Qaysi kanallar faol bo'lsa ularni offline render qilish
    const keysToRender = (target === 'active_mix') 
      ? this.channelKeys.filter(k => this.channels[k].active)
      : [target];

    if (keysToRender.length === 0) {
      keysToRender.push('rain', 'binaural'); // Default agar hech narsa tanlanmagan bo'lsa
    }

    keysToRender.forEach(key => {
      const vol = (this.channels[key] && this.channels[key].volume) || 0.6;
      const pan = (this.channels[key] && this.channels[key].pan) || 0;

      const chGain = offlineCtx.createGain();
      chGain.gain.setValueAtTime(vol, 0);

      const panner = offlineCtx.createStereoPanner ? offlineCtx.createStereoPanner() : offlineCtx.createGain();
      if (panner.pan) panner.pan.setValueAtTime(pan, 0);

      chGain.connect(panner);
      panner.connect(masterGain);

      // Offline generatorlar
      if (key === 'rain' || key === 'stream' || key === 'leaves' || key === 'forest' || key === 'coffeeshop') {
        const buf = offlineCtx.createBuffer(1, totalSamples, sampleRate);
        const data = buf.getChannelData(0);
        for (let i = 0; i < totalSamples; i++) data[i] = Math.random() * 2 - 1;
        const src = offlineCtx.createBufferSource();
        src.buffer = buf;
        const f = offlineCtx.createBiquadFilter();
        f.type = (key === 'rain') ? 'bandpass' : (key === 'stream' ? 'bandpass' : 'lowpass');
        f.frequency.setValueAtTime(key === 'rain' ? 1200 : (key === 'stream' ? 800 : 500), 0);
        src.connect(f);
        f.connect(chGain);
        src.start(0);
      } else if (key === 'binaural' || key === 'cosmic') {
        const osc = offlineCtx.createOscillator();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(key === 'cosmic' ? 108 : 200, 0);
        osc.connect(chGain);
        osc.start(0);
      } else if (key === 'piano') {
        const osc = offlineCtx.createOscillator();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(329.63, 0);
        osc.connect(chGain);
        osc.start(0);
      } else {
        const buf = offlineCtx.createBuffer(1, totalSamples, sampleRate);
        const data = buf.getChannelData(0);
        let lastOut = 0.0;
        for (let i = 0; i < totalSamples; i++) {
          const white = Math.random() * 2 - 1;
          data[i] = (lastOut + (0.02 * white)) / 1.02;
          lastOut = data[i];
          data[i] *= 2.5;
        }
        const src = offlineCtx.createBufferSource();
        src.buffer = buf;
        src.connect(chGain);
        src.start(0);
      }
    });

    const renderedBuffer = await offlineCtx.startRendering();
    const wavBlob = this.audioBufferToWavBlob(renderedBuffer);

    // Yuklab olish linkini bosish
    const url = URL.createObjectURL(wavBlob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 4000);
    return true;
  }

  /**
   * AudioBuffer-ni toza standart stereo WAV blobga aylantirish
   */
  audioBufferToWavBlob(buffer) {
    const numChannels = buffer.numberOfChannels;
    const sampleRate = buffer.sampleRate;
    const format = 1; // PCM
    const bitDepth = 16;
    
    const bytesPerSample = bitDepth / 8;
    const blockAlign = numChannels * bytesPerSample;
    const length = buffer.length;
    const byteRate = sampleRate * blockAlign;
    const dataSize = length * blockAlign;
    const bufferSize = 44 + dataSize;

    const arrayBuffer = new ArrayBuffer(bufferSize);
    const view = new DataView(arrayBuffer);

    const writeString = (offset, string) => {
      for (let i = 0; i < string.length; i++) {
        view.setUint8(offset + i, string.charCodeAt(i));
      }
    };

    writeString(0, 'RIFF');
    view.setUint32(4, 36 + dataSize, true);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, format, true);
    view.setUint16(22, numChannels, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, byteRate, true);
    view.setUint16(32, blockAlign, true);
    view.setUint16(34, bitDepth, true);
    writeString(36, 'data');
    view.setUint32(40, dataSize, true);

    const channels = [];
    for (let i = 0; i < numChannels; i++) {
      channels.push(buffer.getChannelData(i));
    }

    let offset = 44;
    for (let i = 0; i < length; i++) {
      for (let ch = 0; ch < numChannels; ch++) {
        let sample = Math.max(-1, Math.min(1, channels[ch][i]));
        sample = sample < 0 ? sample * 0x8000 : sample * 0x7FFF;
        view.setInt16(offset, sample, true);
        offset += 2;
      }
    }

    return new Blob([arrayBuffer], { type: 'audio/wav' });
  }
}

// Global instansiya
window.auraAudio = new AuraAudioEngine();
