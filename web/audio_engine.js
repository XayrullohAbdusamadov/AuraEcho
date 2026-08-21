/**
 * AuraEcho - Web Audio Engine for Flutter Web Interop
 */
window.AuraFlutterAudio = {
  ctx: null,
  masterGain: null,
  analyser: null,
  isInit: false,
  channelList: [
    'rain', 'forest', 'binaural', 'ocean',
    'thunder', 'campfire', 'coffeeshop', 'cosmic',
    'tibetan', 'stream', 'nightcity', 'noises',
    'leaves', 'train', 'clock', 'piano'
  ],
  channels: {},
  customChannel: { active: false, gainNode: null, pannerNode: null, nodes: [] },

  init: function() {
    if (this.isInit && this.ctx) {
      if (this.ctx.state === 'suspended') this.ctx.resume();
      return;
    }
    const AudioCtx = window.AudioContext || window.webkitAudioContext;
    if (!AudioCtx) return;
    this.ctx = new AudioCtx();
    this.masterGain = this.ctx.createGain();
    this.masterGain.gain.setValueAtTime(0.85, this.ctx.currentTime);
    this.analyser = this.ctx.createAnalyser();
    this.analyser.fftSize = 128;
    this.masterGain.connect(this.analyser);
    this.analyser.connect(this.ctx.destination);

    this.channelList.forEach(k => {
      this.channels[k] = { active: false, gainNode: null, pannerNode: null, nodes: [], volume: 0.5, pan: 0, intervalId: null };
    });
    this.isInit = true;
  },

  ensureRunning: function() {
    this.init();
    if (this.ctx && this.ctx.state === 'suspended') this.ctx.resume();
  },

  playTaptic: function(type) {
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
      }
    } catch(e) {}
  },

  createNoiseBuffer: function(type, seconds) {
    if (!this.ctx) return null;
    const size = this.ctx.sampleRate * seconds;
    const buf = this.ctx.createBuffer(1, size, this.ctx.sampleRate);
    const d = buf.getChannelData(0);
    if (type === 'brown') {
      let last = 0.0;
      for (let i = 0; i < size; i++) {
        const w = Math.random() * 2 - 1;
        d[i] = (last + (0.02 * w)) / 1.02;
        last = d[i];
        d[i] *= 3.5;
      }
    } else {
      for (let i = 0; i < size; i++) d[i] = Math.random() * 2 - 1;
    }
    return buf;
  },

  prepareChannel: function(k) {
    this.ensureRunning();
    const ch = this.channels[k];
    ch.gainNode = this.ctx.createGain();
    ch.gainNode.gain.setValueAtTime(ch.volume, this.ctx.currentTime);
    ch.pannerNode = this.ctx.createStereoPanner ? this.ctx.createStereoPanner() : this.ctx.createGain();
    if (ch.pannerNode.pan) ch.pannerNode.pan.setValueAtTime(ch.pan, this.ctx.currentTime);
    ch.gainNode.connect(ch.pannerNode);
    ch.pannerNode.connect(this.masterGain);
    return ch;
  },

  toggleChannel: function(k, active) {
    this.ensureRunning();
    const ch = this.channels[k];
    if (!ch) return;
    if (active) {
      if (ch.active) return;
      const c = this.prepareChannel(k);
      if (k === 'rain' || k === 'forest' || k === 'stream' || k === 'leaves' || k === 'coffeeshop') {
        const src = this.ctx.createBufferSource();
        src.buffer = this.createNoiseBuffer('pink', 6);
        src.loop = true;
        const f = this.ctx.createBiquadFilter();
        f.type = (k === 'rain') ? 'bandpass' : 'lowpass';
        f.frequency.setValueAtTime((k === 'rain') ? 1100 : 700, this.ctx.currentTime);
        src.connect(f);
        f.connect(c.gainNode);
        src.start();
        c.nodes.push(src, f);
      } else if (k === 'binaural') {
        const merger = this.ctx.createChannelMerger(2);
        const l = this.ctx.createOscillator(); l.frequency.setValueAtTime(200, this.ctx.currentTime);
        const r = this.ctx.createOscillator(); r.frequency.setValueAtTime(206, this.ctx.currentTime);
        const gl = this.ctx.createGain(); gl.gain.setValueAtTime(0.5, this.ctx.currentTime);
        const gr = this.ctx.createGain(); gr.gain.setValueAtTime(0.5, this.ctx.currentTime);
        l.connect(gl); gl.connect(merger, 0, 0);
        r.connect(gr); gr.connect(merger, 0, 1);
        merger.connect(c.gainNode);
        l.start(); r.start();
        c.nodes.push(l, r, gl, gr, merger);
      } else if (k === 'cosmic') {
        const o1 = this.ctx.createOscillator(); o1.frequency.setValueAtTime(108, this.ctx.currentTime);
        const o2 = this.ctx.createOscillator(); o2.type = 'triangle'; o2.frequency.setValueAtTime(216, this.ctx.currentTime);
        o1.connect(c.gainNode); o2.connect(c.gainNode);
        o1.start(); o2.start();
        c.nodes.push(o1, o2);
      } else if (k === 'piano') {
        c.intervalId = setInterval(() => {
          if (!c.active || !this.ctx) return;
          const osc = this.ctx.createOscillator();
          const g = this.ctx.createGain();
          const notes = [261.63, 293.66, 329.63, 392.00, 440.00, 523.25];
          const n = notes[Math.floor(Math.random() * notes.length)];
          osc.frequency.setValueAtTime(n, this.ctx.currentTime);
          g.gain.setValueAtTime(0.01, this.ctx.currentTime);
          g.gain.linearRampToValueAtTime(0.3, this.ctx.currentTime + 0.05);
          g.gain.exponentialRampToValueAtTime(0.0001, this.ctx.currentTime + 4.0);
          osc.connect(g); g.connect(c.gainNode);
          osc.start(); osc.stop(this.ctx.currentTime + 4.2);
        }, 3500);
      } else {
        const src = this.ctx.createBufferSource();
        src.buffer = this.createNoiseBuffer('brown', 6);
        src.loop = true;
        const f = this.ctx.createBiquadFilter();
        f.type = 'lowpass';
        f.frequency.setValueAtTime(280, this.ctx.currentTime);
        src.connect(f); f.connect(c.gainNode);
        src.start();
        c.nodes.push(src, f);
      }
      ch.active = true;
    } else {
      if (!ch.active) return;
      if (ch.intervalId) clearInterval(ch.intervalId);
      ch.nodes.forEach(n => {
        try { n.stop(); } catch(e){}
        try { n.disconnect(); } catch(e){}
      });
      ch.nodes = [];
      ch.active = false;
    }
  },

  setVolume: function(k, val) {
    this.ensureRunning();
    const ch = this.channels[k];
    if (!ch) return;
    ch.volume = parseFloat(val);
    if (ch.gainNode && this.ctx) ch.gainNode.gain.setTargetAtTime(ch.volume, this.ctx.currentTime, 0.02);
  },

  setPan: function(k, val) {
    this.ensureRunning();
    const ch = this.channels[k];
    if (!ch) return;
    ch.pan = parseFloat(val);
    if (ch.pannerNode && ch.pannerNode.pan && this.ctx) ch.pannerNode.pan.setTargetAtTime(ch.pan, this.ctx.currentTime, 0.02);
  },

  setMasterVolume: function(val) {
    this.ensureRunning();
    if (!this.masterGain || !this.ctx) return;
    this.masterGain.gain.setTargetAtTime(parseFloat(val), this.ctx.currentTime, 0.02);
  },

  stopAll: function() {
    this.channelList.forEach(k => this.toggleChannel(k, false));
    this.stopCustomSound();
  },

  startCustomSound: function(waveType, freq, filterType, filterFreq, lfoFreq, lfoDepth) {
    this.ensureRunning();
    this.stopCustomSound();
    const ch = this.customChannel;
    ch.gainNode = this.ctx.createGain();
    ch.gainNode.gain.setValueAtTime(0.6, this.ctx.currentTime);
    ch.gainNode.connect(this.masterGain);

    const osc = this.ctx.createOscillator();
    osc.type = waveType || 'sine';
    osc.frequency.setValueAtTime(parseFloat(freq) || 220, this.ctx.currentTime);

    const f = this.ctx.createBiquadFilter();
    f.type = filterType || 'lowpass';
    f.frequency.setValueAtTime(parseFloat(filterFreq) || 800, this.ctx.currentTime);

    const lfo = this.ctx.createOscillator();
    lfo.frequency.setValueAtTime(parseFloat(lfoFreq) || 2, this.ctx.currentTime);
    const lfoG = this.ctx.createGain();
    lfoG.gain.setValueAtTime(parseFloat(lfoDepth) || 50, this.ctx.currentTime);
    lfo.connect(lfoG);
    lfoG.connect(f.frequency);

    osc.connect(f);
    f.connect(ch.gainNode);
    osc.start();
    lfo.start();
    ch.nodes.push(osc, f, lfo, lfoG);
    ch.active = true;
  },

  stopCustomSound: function() {
    const ch = this.customChannel;
    if (!ch.active) return;
    ch.nodes.forEach(n => {
      try { n.stop(); } catch(e){}
      try { n.disconnect(); } catch(e){}
    });
    ch.nodes = [];
    ch.active = false;
  },

  exportAudio: async function(target, duration, fileName) {
    const sampleRate = 44100;
    const totalSamples = sampleRate * duration;
    const off = new (window.OfflineAudioContext || window.webkitOfflineAudioContext)(2, totalSamples, sampleRate);
    const g = off.createGain();
    g.gain.setValueAtTime(0.85, 0);
    g.connect(off.destination);

    const keys = (target === 'active_mix') ? this.channelList.filter(k => this.channels[k].active) : [target];
    if (keys.length === 0) keys.push('rain', 'binaural');

    keys.forEach(k => {
      const vol = (this.channels[k] && this.channels[k].volume) || 0.6;
      const cg = off.createGain();
      cg.gain.setValueAtTime(vol, 0);
      cg.connect(g);

      const buf = off.createBuffer(1, totalSamples, sampleRate);
      const data = buf.getChannelData(0);
      for (let i = 0; i < totalSamples; i++) data[i] = Math.random() * 2 - 1;
      const src = off.createBufferSource();
      src.buffer = buf;
      src.connect(cg);
      src.start(0);
    });

    const rendered = await off.startRendering();
    const len = rendered.length * 4 + 44;
    const arrayBuffer = new ArrayBuffer(len);
    const view = new DataView(arrayBuffer);

    const writeStr = (pos, s) => { for (let i = 0; i < s.length; i++) view.setUint8(pos + i, s.charCodeAt(i)); };
    writeStr(0, 'RIFF');
    view.setUint32(4, len - 8, true);
    writeStr(8, 'WAVE');
    writeStr(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true);
    view.setUint16(22, 2, true);
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 4, true);
    view.setUint16(32, 4, true);
    view.setUint16(34, 16, true);
    writeStr(36, 'data');
    view.setUint32(40, rendered.length * 4, true);

    const l = rendered.getChannelData(0), r = rendered.getChannelData(1);
    let offset = 44;
    for (let i = 0; i < rendered.length; i++) {
      view.setInt16(offset, Math.max(-1, Math.min(1, l[i])) * 0x7FFF, true);
      view.setInt16(offset + 2, Math.max(-1, Math.min(1, r[i])) * 0x7FFF, true);
      offset += 4;
    }

    const blob = new Blob([arrayBuffer], { type: 'audio/wav' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName || 'AuraEcho_Audio.wav';
    a.click();
    setTimeout(() => URL.revokeObjectURL(url), 4000);
  }
};
