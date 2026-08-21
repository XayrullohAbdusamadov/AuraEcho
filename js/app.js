/**
 * AuraEcho - Asosiy Ilova Boshqaruvi va UI Logikasi (16 Qatlam, Sintezator & Audio Eksport)
 */

document.addEventListener('DOMContentLoaded', () => {
  // 1. Tizim elementlari
  const themeToggle = document.getElementById('theme-toggle');
  const themeLabel = document.getElementById('theme-label');
  const tabItems = document.querySelectorAll('.ios-tab-item');
  const tabContents = document.querySelectorAll('.tab-content');

  // Telemetriya elementlari
  const sensorDb = document.getElementById('sensor-db');
  const sensorDbFill = document.getElementById('sensor-db-fill');
  const sensorLux = document.getElementById('sensor-lux');
  const sensorLuxFill = document.getElementById('sensor-lux-fill');
  const sensorIndex = document.getElementById('sensor-index');
  const sensorIndexFill = document.getElementById('sensor-index-fill');
  const gyroBubble = document.getElementById('gyro-bubble');
  const sensorTiltText = document.getElementById('sensor-tilt-text');

  const snapshotDb = document.getElementById('snapshot-db');
  const snapshotLux = document.getElementById('snapshot-lux');
  const snapshotHarmony = document.getElementById('snapshot-harmony');

  // Statistika
  const statTotalCapsules = document.getElementById('stat-total-capsules');
  const statTopMood = document.getElementById('stat-top-mood');

  // Audio elementlari
  const canvas = document.getElementById('visualizer-canvas');
  const canvasCtx = canvas ? canvas.getContext('2d') : null;
  const sliderMasterVolume = document.getElementById('slider-master-volume');
  const masterVolValue = document.getElementById('master-vol-value');
  const btnAudioStopAll = document.getElementById('btn-audio-stop-all');
  const btnDownloadMasterMix = document.getElementById('btn-download-master-mix');

  // 16 ta tovush kanallari ro'yxati
  const channelList = [
    'rain', 'forest', 'binaural', 'ocean',
    'thunder', 'campfire', 'coffeeshop', 'cosmic',
    'tibetan', 'stream', 'nightcity', 'noises',
    'leaves', 'train', 'clock', 'piano'
  ];

  const audioCards = {};
  const audioSwitches = {};
  const audioPlayBtns = {};
  const audioVolSliders = {};
  const audioVolLabels = {};
  const audioPanSliders = {};
  const audioPanLabels = {};

  channelList.forEach(k => {
    audioCards[k] = document.getElementById(`card-${k}`);
    audioSwitches[k] = document.getElementById(`switch-${k}`);
    audioPlayBtns[k] = document.querySelector(`.btn-toggle-play[data-channel="${k}"]`);
    audioVolSliders[k] = document.getElementById(`slider-vol-${k}`);
    audioVolLabels[k] = document.getElementById(`label-vol-${k}`);
    audioPanSliders[k] = document.getElementById(`slider-pan-${k}`);
    audioPanLabels[k] = document.getElementById(`label-pan-${k}`);
  });

  // Shaxsiy Sintezator Modali elementlari
  const modalCustomSynth = document.getElementById('modal-custom-synth');
  const btnOpenCustomSynth = document.getElementById('btn-open-custom-synth');
  const btnOpenCustomSynthDash = document.getElementById('btn-open-custom-synth-dash');
  const btnCancelCustomSynth = document.getElementById('btn-cancel-custom-synth');
  const btnTestCustomSound = document.getElementById('btn-test-custom-sound');
  const customTestBtnText = document.getElementById('custom-test-btn-text');
  const btnDownloadCustomSound = document.getElementById('btn-download-custom-sound');
  const btnSaveCustomSound = document.getElementById('btn-save-custom-sound');

  const customWaveSelector = document.getElementById('custom-wave-selector');
  const customFreqSlider = document.getElementById('custom-freq-slider');
  const customFreqLabel = document.getElementById('custom-freq-label');
  const customFilterSelector = document.getElementById('custom-filter-selector');
  const customCutoffSlider = document.getElementById('custom-cutoff-slider');
  const customCutoffLabel = document.getElementById('custom-cutoff-label');
  const customLfoSlider = document.getElementById('custom-lfo-slider');
  const customLfoLabel = document.getElementById('custom-lfo-label');

  let customSynthConfig = {
    waveType: 'sine',
    freq: 220,
    filterType: 'lowpass',
    filterFreq: 800,
    lfoFreq: 2.0,
    lfoDepth: 50
  };

  // Modallar va formalar
  const modalCreate = document.getElementById('modal-create-capsule');
  const btnOpenCreateModal = document.getElementById('btn-open-create-modal');
  const btnCancelCreate = document.getElementById('btn-cancel-create');
  const btnSaveCapsule = document.getElementById('btn-save-capsule');

  const inputCapsuleTitle = document.getElementById('input-capsule-title');
  const inputCapsuleLocation = document.getElementById('input-capsule-location');
  const inputCapsuleNotes = document.getElementById('input-capsule-notes');
  const modalTagSelector = document.getElementById('modal-tag-selector');
  const formMoodSelector = document.getElementById('form-mood-selector');
  const formSoundPreset = document.getElementById('form-sound-preset');

  // Arxiv va Ko'rish
  const archiveList = document.getElementById('archive-capsules-list');
  const archiveSearchInput = document.getElementById('archive-search-input');
  const moodFilterControl = document.getElementById('mood-filter-control');
  const modalView = document.getElementById('modal-view-capsule');
  const viewCapsuleBody = document.getElementById('view-capsule-body');
  const viewCapsuleModalTitle = document.getElementById('view-capsule-modal-title');
  const btnCloseView = document.getElementById('btn-close-view');
  const btnDeleteCapsuleTrigger = document.getElementById('btn-delete-capsule-trigger');

  // Alert Dialog
  const alertDialog = document.getElementById('alert-delete-dialog');
  const btnAlertCancel = document.getElementById('btn-alert-cancel');
  const btnAlertConfirmDelete = document.getElementById('btn-alert-confirm-delete');

  // Ma'lumotlar boshqaruvi
  const btnExportJson = document.getElementById('btn-export-json');
  const btnTriggerImport = document.getElementById('btn-trigger-import');
  const fileImportInput = document.getElementById('file-import-input');
  const btnResetDefaults = document.getElementById('btn-reset-defaults');

  // Toast
  const toast = document.getElementById('app-toast');
  const toastMessage = document.getElementById('toast-message');

  let currentSelectedMood = "Xotirjamlik";
  let currentSelectedMoodColor = "#34C759";
  let currentSelectedSound = "calm";
  let activeCapsuleForView = null;

  /* --------------------------------------------------------------------------
     1. Mavzu (Light / Dark Mode)
     -------------------------------------------------------------------------- */
  const savedTheme = window.auraStorage.getTheme();
  applyTheme(savedTheme);

  if (themeToggle) {
    themeToggle.checked = (savedTheme === 'dark');
    themeToggle.addEventListener('change', () => {
      window.auraAudio.playTaptic('light');
      const newTheme = themeToggle.checked ? 'dark' : 'light';
      applyTheme(newTheme);
      window.auraStorage.setTheme(newTheme);
    });
  }

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    if (themeLabel) {
      themeLabel.textContent = (theme === 'dark') ? 'Tungi' : 'Tongi';
    }
  }

  /* --------------------------------------------------------------------------
     2. Tab Bar Navigatsiyasi
     -------------------------------------------------------------------------- */
  tabItems.forEach(tab => {
    tab.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      const targetId = tab.getAttribute('data-tab');

      tabItems.forEach(t => t.classList.remove('active'));
      tabContents.forEach(c => c.classList.remove('active'));

      tab.classList.add('active');
      const targetContent = document.getElementById(targetId);
      if (targetContent) {
        targetContent.classList.add('active');
      }

      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });

  /* --------------------------------------------------------------------------
     3. Telemetriya Jonli Ma'lumotlarini Yangilash
     -------------------------------------------------------------------------- */
  window.auraSensors.subscribe((data) => {
    if (sensorDb) sensorDb.textContent = data.decibels;
    if (sensorDbFill) sensorDbFill.style.width = `${Math.min(100, data.decibels)}%`;

    if (sensorLux) sensorLux.textContent = data.lux;
    if (sensorLuxFill) sensorLuxFill.style.width = `${Math.min(100, (data.lux / 1000) * 100)}%`;

    if (sensorIndex) sensorIndex.textContent = data.sensoryIndex;
    if (sensorIndexFill) sensorIndexFill.style.width = `${data.sensoryIndex}%`;

    if (gyroBubble) {
      gyroBubble.style.transform = `translate(${data.tiltX * 1.5}px, ${data.tiltY * 1.5}px)`;
    }
    if (sensorTiltText) {
      sensorTiltText.textContent = `X: ${data.tiltX > 0 ? '+' : ''}${data.tiltX}° | Y: ${data.tiltY > 0 ? '+' : ''}${data.tiltY}°`;
    }

    if (snapshotDb) snapshotDb.textContent = `${data.decibels} dB`;
    if (snapshotLux) snapshotLux.textContent = `${data.lux} lux`;
    if (snapshotHarmony) snapshotHarmony.textContent = `${data.sensoryIndex}%`;
  });

  /* --------------------------------------------------------------------------
     4. 16 ta Fazoviy Tovushlar Boshqaruvi
     -------------------------------------------------------------------------- */
  if (sliderMasterVolume) {
    sliderMasterVolume.addEventListener('input', (e) => {
      window.auraAudio.ensureRunning();
      const val = parseFloat(e.target.value);
      window.auraAudio.setMasterVolume(val);
      if (masterVolValue) masterVolValue.textContent = `${Math.round(val * 100)}%`;
    });
  }

  // Barchasini to'xtatish
  if (btnAudioStopAll) {
    btnAudioStopAll.addEventListener('click', () => {
      window.auraAudio.playTaptic('medium');
      window.auraAudio.stopAll();
      channelList.forEach(k => {
        if (audioSwitches[k]) audioSwitches[k].checked = false;
        if (audioCards[k]) audioCards[k].classList.remove('playing');
        updatePlayBtnIcon(k, false);
      });
      showToast("Barcha 16 ta fazoviy tovushlar to'xtatildi");
    });
  }

  // 16 ta kanal hodisalari
  channelList.forEach(channel => {
    const card = audioCards[channel];
    const sw = audioSwitches[channel];
    const playBtn = audioPlayBtns[channel];
    const volSlider = audioVolSliders[channel];
    const volLabel = audioVolLabels[channel];
    const panSlider = audioPanSliders[channel];
    const panLabel = audioPanLabels[channel];

    const toggleSoundState = (forceState) => {
      window.auraAudio.ensureRunning();
      window.auraAudio.playTaptic('light');
      const newState = (forceState !== undefined) ? forceState : !window.auraAudio.channels[channel].active;
      window.auraAudio.toggleChannel(channel, newState);
      if (sw) sw.checked = newState;
      if (card) card.classList.toggle('playing', newState);
      updatePlayBtnIcon(channel, newState);
    };

    if (sw) {
      sw.addEventListener('change', () => toggleSoundState(sw.checked));
    }

    if (playBtn) {
      playBtn.addEventListener('click', (e) => {
        e.stopPropagation();
        toggleSoundState();
      });
    }

    if (volSlider) {
      volSlider.addEventListener('input', (e) => {
        window.auraAudio.ensureRunning();
        const val = parseFloat(e.target.value);
        window.auraAudio.setVolume(channel, val);
        if (volLabel) volLabel.textContent = `${Math.round(val * 100)}%`;
      });
    }

    if (panSlider) {
      panSlider.addEventListener('input', (e) => {
        window.auraAudio.ensureRunning();
        const val = parseFloat(e.target.value);
        window.auraAudio.setPan(channel, val);
        if (panLabel) {
          if (val === 0) panLabel.textContent = 'Markaz';
          else if (val < 0) panLabel.textContent = `Chap ${Math.round(Math.abs(val) * 100)}%`;
          else panLabel.textContent = `O'ng ${Math.round(val * 100)}%`;
        }
      });
    }
  });

  function updatePlayBtnIcon(channel, isPlaying) {
    const btn = audioPlayBtns[channel];
    if (!btn) return;
    if (isPlaying) {
      btn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <rect x="6" y="4" width="4" height="16"></rect>
          <rect x="14" y="4" width="4" height="16"></rect>
        </svg>
      `;
    } else {
      btn.innerHTML = `
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <polygon points="5 3 19 12 5 21 5 3"></polygon>
        </svg>
      `;
    }
  }

  // Alohida tovushni audio fayl sifatida yuklab olish
  document.querySelectorAll('.btn-download-single-sound').forEach(btn => {
    btn.addEventListener('click', async (e) => {
      e.stopPropagation();
      window.auraAudio.playTaptic('medium');
      const channel = btn.getAttribute('data-channel');
      showToast(`${channel.toUpperCase()} audio render qilinmoqda...`);
      await window.auraAudio.exportAudioToFile(channel, 15, `AuraEcho_${channel}.wav`);
      showToast(`${channel.toUpperCase()} audio fayli muvaffaqiyatli yuklandi!`);
    });
  });

  // Master umumiy miksni yuklab olish
  if (btnDownloadMasterMix) {
    btnDownloadMasterMix.addEventListener('click', async () => {
      window.auraAudio.playTaptic('medium');
      showToast("Fazoviy audio miks render qilinmoqda...");
      await window.auraAudio.exportAudioToFile('active_mix', 18, `AuraEcho_Miks_${Date.now()}.wav`);
      showToast("Fazoviy audio miks muvaffaqiyatli yuklandi!");
    });
  }

  // Tezkor Preset Tugmalari
  document.querySelectorAll('.btn-quick-preset').forEach(btn => {
    btn.addEventListener('click', (e) => {
      e.stopPropagation();
      window.auraAudio.ensureRunning();
      window.auraAudio.playTaptic('medium');
      const preset = btn.getAttribute('data-preset');
      applyAudioPreset(preset);
      showToast(`Fazoviy muhit yoqildi`);
    });
  });

  function applyAudioPreset(presetName) {
    window.auraAudio.applyPreset(presetName);

    // Switchlar, kartalar va slayderlarni yangilash
    channelList.forEach(k => {
      const ch = window.auraAudio.channels[k];
      if (audioSwitches[k]) audioSwitches[k].checked = ch.active;
      if (audioCards[k]) audioCards[k].classList.toggle('playing', ch.active);
      updatePlayBtnIcon(k, ch.active);
      if (audioVolSliders[k]) audioVolSliders[k].value = ch.volume;
      if (audioVolLabels[k]) audioVolLabels[k].textContent = `${Math.round(ch.volume * 100)}%`;
    });
  }

  /* --------------------------------------------------------------------------
     5. Shaxsiy Tovush Sintezatori Modali
     -------------------------------------------------------------------------- */
  const openCustomSynth = () => {
    window.auraAudio.playTaptic('light');
    modalCustomSynth.classList.add('active');
  };

  if (btnOpenCustomSynth) btnOpenCustomSynth.addEventListener('click', openCustomSynth);
  if (btnOpenCustomSynthDash) btnOpenCustomSynthDash.addEventListener('click', openCustomSynth);

  if (btnCancelCustomSynth) {
    btnCancelCustomSynth.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      window.auraAudio.stopCustomSound();
      if (customTestBtnText) customTestBtnText.textContent = "Tovushni Sinash (Ijro)";
      modalCustomSynth.classList.remove('active');
    });
  }

  // To'lqin turi tanlash
  if (customWaveSelector) {
    customWaveSelector.querySelectorAll('.ios-segment-item').forEach(btn => {
      btn.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        customWaveSelector.querySelectorAll('.ios-segment-item').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        customSynthConfig.waveType = btn.getAttribute('data-wave');
        if (window.auraAudio.customChannel.active) {
          window.auraAudio.startCustomSound(customSynthConfig);
        }
      });
    });
  }

  // Chastota slayderi
  if (customFreqSlider) {
    customFreqSlider.addEventListener('input', (e) => {
      const val = parseFloat(e.target.value);
      customSynthConfig.freq = val;
      if (customFreqLabel) customFreqLabel.textContent = `${val} Hz`;
      if (window.auraAudio.customChannel.active) {
        window.auraAudio.startCustomSound(customSynthConfig);
      }
    });
  }

  // Filtr turi
  if (customFilterSelector) {
    customFilterSelector.querySelectorAll('.ios-segment-item').forEach(btn => {
      btn.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        customFilterSelector.querySelectorAll('.ios-segment-item').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        customSynthConfig.filterType = btn.getAttribute('data-filter');
        if (window.auraAudio.customChannel.active) {
          window.auraAudio.startCustomSound(customSynthConfig);
        }
      });
    });
  }

  // Kesish chastotasi
  if (customCutoffSlider) {
    customCutoffSlider.addEventListener('input', (e) => {
      const val = parseFloat(e.target.value);
      customSynthConfig.filterFreq = val;
      if (customCutoffLabel) customCutoffLabel.textContent = `${val} Hz`;
      if (window.auraAudio.customChannel.active) {
        window.auraAudio.startCustomSound(customSynthConfig);
      }
    });
  }

  // LFO modulyatsiyasi
  if (customLfoSlider) {
    customLfoSlider.addEventListener('input', (e) => {
      const val = parseFloat(e.target.value);
      customSynthConfig.lfoFreq = val;
      if (customLfoLabel) customLfoLabel.textContent = `${val.toFixed(1)} Hz`;
      if (window.auraAudio.customChannel.active) {
        window.auraAudio.startCustomSound(customSynthConfig);
      }
    });
  }

  // Sinash / Ijro tugmasi
  if (btnTestCustomSound) {
    btnTestCustomSound.addEventListener('click', () => {
      window.auraAudio.playTaptic('medium');
      if (window.auraAudio.customChannel.active) {
        window.auraAudio.stopCustomSound();
        if (customTestBtnText) customTestBtnText.textContent = "Tovushni Sinash (Ijro)";
      } else {
        window.auraAudio.startCustomSound(customSynthConfig);
        if (customTestBtnText) customTestBtnText.textContent = "To'xtatish";
      }
    });
  }

  // Shaxsiy tovushni yuklab olish
  if (btnDownloadCustomSound) {
    btnDownloadCustomSound.addEventListener('click', async () => {
      window.auraAudio.playTaptic('medium');
      showToast("Shaxsiy tovush audio render qilinmoqda...");
      await window.auraAudio.exportAudioToFile('custom', 15, `AuraEcho_Shaxsiy_Tovush_${Date.now()}.wav`);
      showToast("Shaxsiy tovush muvaffaqiyatli yuklandi!");
    });
  }

  // Shaxsiy tovushni saqlash
  if (btnSaveCustomSound) {
    btnSaveCustomSound.addEventListener('click', () => {
      window.auraAudio.playTaptic('success');
      showToast("Shaxsiy tovush sozlamalari saqlandi!");
      modalCustomSynth.classList.remove('active');
    });
  }

  /* --------------------------------------------------------------------------
     6. Real Vaqtli Spektr Analizatori (Canvas Flat Visualizer)
     -------------------------------------------------------------------------- */
  function renderVisualizer() {
    requestAnimationFrame(renderVisualizer);
    if (!canvas || !canvasCtx || !window.auraAudio.analyser) return;

    if (canvas.width !== canvas.clientWidth) {
      canvas.width = canvas.clientWidth;
    }

    const analyser = window.auraAudio.analyser;
    const bufferLength = analyser.frequencyBinCount;
    const dataArray = new Uint8Array(bufferLength);
    analyser.getByteFrequencyData(dataArray);

    const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
    const bgFill = isDark ? '#1C1C1E' : '#F2F2F7';
    const barFill = isDark ? '#0A84FF' : '#007AFF';

    canvasCtx.fillStyle = bgFill;
    canvasCtx.fillRect(0, 0, canvas.width, canvas.height);

    const barCount = Math.min(72, Math.floor(canvas.width / 14));
    const barWidth = Math.max(4, (canvas.width / barCount) - 3);
    let x = 2;

    for (let i = 0; i < barCount; i++) {
      const dataIndex = Math.floor((i / barCount) * bufferLength);
      const val = dataArray[dataIndex] || 0;
      const barHeight = Math.max(3, (val / 255) * (canvas.height - 12));

      canvasCtx.fillStyle = barFill;
      const y = canvas.height - barHeight - 4;
      canvasCtx.beginPath();
      if (canvasCtx.roundRect) {
        canvasCtx.roundRect(x, y, barWidth, barHeight, 3);
      } else {
        canvasCtx.rect(x, y, barWidth, barHeight);
      }
      canvasCtx.fill();
      x += barWidth + 3;
    }
  }
  renderVisualizer();

  /* --------------------------------------------------------------------------
     7. Yangi Xotira Yaratish Modali
     -------------------------------------------------------------------------- */
  if (btnOpenCreateModal) {
    btnOpenCreateModal.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      modalCreate.classList.add('active');
      if (inputCapsuleTitle) inputCapsuleTitle.focus();
    });
  }

  if (btnCancelCreate) {
    btnCancelCreate.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      modalCreate.classList.remove('active');
    });
  }

  // Hissiyot tanlash
  if (formMoodSelector) {
    const moodBtns = formMoodSelector.querySelectorAll('.ios-segment-item');
    moodBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        moodBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentSelectedMood = btn.getAttribute('data-mood');
        currentSelectedMoodColor = btn.getAttribute('data-color') || '#007AFF';
      });
    });
  }

  // Tovush preset tanlash
  if (formSoundPreset) {
    const soundBtns = formSoundPreset.querySelectorAll('.ios-segment-item');
    soundBtns.forEach(btn => {
      btn.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        soundBtns.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        currentSelectedSound = btn.getAttribute('data-sound');
      });
    });
  }

  // Teglar tanlash
  if (modalTagSelector) {
    modalTagSelector.querySelectorAll('.sensory-tag').forEach(tag => {
      tag.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        tag.classList.toggle('active');
      });
    });
  }

  // Kapsulani saqlash
  if (btnSaveCapsule) {
    btnSaveCapsule.addEventListener('click', () => {
      const title = inputCapsuleTitle.value.trim();
      if (!title) {
        window.auraAudio.playTaptic('medium');
        alert("Iltimos, xotira nomini kiriting.");
        return;
      }

      const activeTags = [];
      modalTagSelector.querySelectorAll('.sensory-tag.active').forEach(t => {
        activeTags.push(t.getAttribute('data-tag'));
      });

      const snapshot = window.auraSensors.getSnapshot();

      window.auraStorage.create({
        title: title,
        mood: currentSelectedMood,
        moodColor: currentSelectedMoodColor,
        location: inputCapsuleLocation.value.trim() || "Noma'lum hudud",
        notes: inputCapsuleNotes.value.trim(),
        tags: activeTags,
        telemetry: snapshot,
        soundConfig: {
          preset: currentSelectedSound
        }
      });

      window.auraAudio.playTaptic('success');
      modalCreate.classList.remove('active');
      
      inputCapsuleTitle.value = '';
      inputCapsuleLocation.value = '';
      inputCapsuleNotes.value = '';

      renderArchiveList();
      updateDashboardStats();
      showToast("Yangi xotira kapsulasi muvaffaqiyatli saqlandi!");
    });
  }

  /* --------------------------------------------------------------------------
     8. Xotiralar Arxivi & Filtrlash
     -------------------------------------------------------------------------- */
  function renderArchiveList() {
    if (!archiveList) return;

    const query = archiveSearchInput ? archiveSearchInput.value : '';
    const activeMoodBtn = moodFilterControl ? moodFilterControl.querySelector('.ios-segment-item.active') : null;
    const moodFilter = activeMoodBtn ? activeMoodBtn.getAttribute('data-mood') : 'all';

    const capsules = window.auraStorage.search(query, moodFilter);

    if (capsules.length === 0) {
      archiveList.innerHTML = `
        <div class="empty-state">
          <div class="empty-state-icon">
            <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </div>
          <div class="ios-headline">Hech qanday xotira topilmadi</div>
          <div class="ios-footnote">Qidiruv mezonini o'zgartiring yoki yangi kapsula yarating.</div>
        </div>
      `;
      return;
    }

    let html = '';
    capsules.forEach(cap => {
      const dateStr = formatDate(cap.createdAt);
      const tagsHtml = (cap.tags || []).map(t => `<span class="capsule-badge">${t}</span>`).join(' ');

      html += `
        <div class="ios-cell interactive capsule-item" data-id="${cap.id}">
          <div class="ios-cell-left">
            <div class="ios-cell-icon" style="background-color: ${cap.moodColor || 'var(--ios-blue)'};">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                <path d="M12 2a10 10 0 1 0 10 10A10 10 0 0 0 12 2zm0 18a8 8 0 1 1 8-8 8 8 0 0 1-8 8z"/>
              </svg>
            </div>
            <div class="ios-cell-content">
              <span class="ios-cell-title">${escapeHtml(cap.title)}</span>
              <span class="ios-cell-subtitle">${escapeHtml(cap.location)} • ${dateStr}</span>
              <div class="tag-list" style="margin-top: 4px;">
                <span class="capsule-badge" style="background-color: rgba(0,122,255,0.12); color: var(--ios-blue); font-weight: 700;">${escapeHtml(cap.mood)}</span>
                ${tagsHtml}
              </div>
            </div>
          </div>
          <div class="ios-cell-right">
            <span class="ios-footnote" style="font-weight: 600; color: var(--text-secondary);">${cap.telemetry ? cap.telemetry.decibels : 35} dB</span>
            <span class="ios-chevron">›</span>
          </div>
        </div>
      `;
    });

    archiveList.innerHTML = html;

    archiveList.querySelectorAll('.capsule-item').forEach(item => {
      item.addEventListener('click', () => {
        const id = item.getAttribute('data-id');
        openCapsuleDetails(id);
      });
    });
  }

  if (archiveSearchInput) {
    archiveSearchInput.addEventListener('input', () => renderArchiveList());
  }

  if (moodFilterControl) {
    moodFilterControl.querySelectorAll('.ios-segment-item').forEach(btn => {
      btn.addEventListener('click', () => {
        window.auraAudio.playTaptic('light');
        moodFilterControl.querySelectorAll('.ios-segment-item').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        renderArchiveList();
      });
    });
  }

  /* --------------------------------------------------------------------------
     9. Xotira Tafsilotlari Modali (View Details)
     -------------------------------------------------------------------------- */
  function openCapsuleDetails(id) {
    window.auraAudio.playTaptic('light');
    const cap = window.auraStorage.getById(id);
    if (!cap) return;

    activeCapsuleForView = cap;
    if (viewCapsuleModalTitle) viewCapsuleModalTitle.textContent = cap.title;

    const tagsHtml = (cap.tags || []).map(t => `<span class="sensory-tag active">${t}</span>`).join(' ');
    const tel = cap.telemetry || { decibels: 38, lux: 400, tiltX: 0, tiltY: 0, sensoryIndex: 85 };

    viewCapsuleBody.innerHTML = `
      <div class="ios-grouped-list" style="padding: 18px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 8px;">
          <div>
            <h2 class="ios-title2" style="margin: 0;">${escapeHtml(cap.title)}</h2>
            <p class="ios-subhead" style="margin-top: 2px;">📍 ${escapeHtml(cap.location)} • ${formatDate(cap.createdAt)}</p>
          </div>
          <span class="capsule-badge" style="background-color: ${cap.moodColor || 'var(--ios-blue)'}; color: #FFFFFF; font-size: 13px; padding: 4px 10px;">
            ${escapeHtml(cap.mood)}
          </span>
        </div>

        <p class="ios-body" style="margin-top: 10px; line-height: 22px;">${escapeHtml(cap.notes || "Qo'shimcha eslatma kiritilmagan.")}</p>

        <div class="tag-list" style="margin-top: 12px;">
          ${tagsHtml}
        </div>
      </div>

      <!-- Telemetriya Datchiklari -->
      <div class="ios-section-header" style="padding-left: 4px;">Muhrlangan Sensor Telemetriyasi</div>
      <div class="telemetry-grid">
        <div class="telemetry-card">
          <span class="ios-caption2">Shovqin</span>
          <span class="telemetry-value">${tel.decibels} <span class="ios-caption2">dB</span></span>
        </div>
        <div class="telemetry-card">
          <span class="ios-caption2">Yorug'lik</span>
          <span class="telemetry-value">${tel.lux} <span class="ios-caption2">lux</span></span>
        </div>
        <div class="telemetry-card">
          <span class="ios-caption2">Uyg'unlik</span>
          <span class="telemetry-value" style="color: var(--ios-green);">${tel.sensoryIndex}%</span>
        </div>
      </div>

      <!-- Fazoviy Tovushni Tinglash & Yuklab Olish -->
      <div style="display: flex; gap: 10px; margin-top: 10px;">
        <button id="btn-play-capsule-sound" class="ios-btn ios-btn-primary" style="flex: 1;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polygon points="5 3 19 12 5 21 5 3"></polygon>
          </svg>
          <span>Tovushni Tinglash</span>
        </button>

        <button id="btn-download-capsule-sound" class="ios-btn ios-btn-secondary" style="flex: 1;">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
            <polyline points="7 10 12 15 17 10"></polyline>
            <line x1="12" y1="15" x2="12" y2="3"></line>
          </svg>
          <span>Audio Yuklab Olish</span>
        </button>
      </div>
    `;

    const btnPlaySound = document.getElementById('btn-play-capsule-sound');
    if (btnPlaySound) {
      btnPlaySound.addEventListener('click', () => {
        window.auraAudio.playTaptic('medium');
        const preset = (cap.soundConfig && cap.soundConfig.preset) ? cap.soundConfig.preset : 'calm';
        applyAudioPreset(preset);
        modalView.classList.remove('active');
        const audioTab = document.querySelector('[data-tab="tab-audio"]');
        if (audioTab) audioTab.click();
        showToast("Xotiraning fazoviy muhiti ijro etilmoqda");
      });
    }

    const btnDownloadSound = document.getElementById('btn-download-capsule-sound');
    if (btnDownloadSound) {
      btnDownloadSound.addEventListener('click', async () => {
        window.auraAudio.playTaptic('medium');
        showToast("Xotira audiosi render qilinmoqda...");
        const preset = (cap.soundConfig && cap.soundConfig.preset) ? cap.soundConfig.preset : 'calm';
        await window.auraAudio.exportAudioToFile(preset, 15, `AuraEcho_${cap.title.replace(/\s+/g, '_')}.wav`);
        showToast("Xotira audiosi muvaffaqiyatli yuklandi!");
      });
    }

    modalView.classList.add('active');
  }

  if (btnCloseView) {
    btnCloseView.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      modalView.classList.remove('active');
    });
  }

  /* --------------------------------------------------------------------------
     10. Xotirani O'chirish
     -------------------------------------------------------------------------- */
  if (btnDeleteCapsuleTrigger) {
    btnDeleteCapsuleTrigger.addEventListener('click', () => {
      window.auraAudio.playTaptic('medium');
      if (alertDialog) alertDialog.classList.add('active');
    });
  }

  if (btnAlertCancel) {
    btnAlertCancel.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      if (alertDialog) alertDialog.classList.remove('active');
    });
  }

  if (btnAlertConfirmDelete) {
    btnAlertConfirmDelete.addEventListener('click', () => {
      if (activeCapsuleForView) {
        window.auraStorage.delete(activeCapsuleForView.id);
        window.auraAudio.playTaptic('success');
        if (alertDialog) alertDialog.classList.remove('active');
        if (modalView) modalView.classList.remove('active');
        renderArchiveList();
        updateDashboardStats();
        showToast("Xotira kapsulasi o'chirildi");
      }
    });
  }

  /* --------------------------------------------------------------------------
     11. Ma'lumotlarni Eksport / Import / Qaytarish
     -------------------------------------------------------------------------- */
  if (btnExportJson) {
    btnExportJson.addEventListener('click', () => {
      window.auraAudio.playTaptic('medium');
      const json = window.auraStorage.exportJSON();
      const blob = new Blob([json], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `AuraEcho_Xotiralar_${Date.now()}.json`;
      a.click();
      URL.revokeObjectURL(url);
      showToast("Xotiralar JSON faylga yuklandi");
    });
  }

  if (btnTriggerImport && fileImportInput) {
    btnTriggerImport.addEventListener('click', () => {
      window.auraAudio.playTaptic('light');
      fileImportInput.click();
    });

    fileImportInput.addEventListener('change', (e) => {
      const file = e.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = (evt) => {
        const success = window.auraStorage.importJSON(evt.target.result);
        if (success) {
          window.auraAudio.playTaptic('success');
          renderArchiveList();
          updateDashboardStats();
          showToast("Xotiralar muvaffaqiyatli tiklandi!");
        } else {
          alert("Noto'g'ri JSON fayl formati.");
        }
      };
      reader.readAsText(file);
    });
  }

  if (btnResetDefaults) {
    btnResetDefaults.addEventListener('click', () => {
      window.auraAudio.playTaptic('medium');
      if (confirm("Standart namunaviy xotiralarni tiklamoqchimisiz?")) {
        window.auraStorage.resetToDefaults();
        renderArchiveList();
        updateDashboardStats();
        showToast("Namunaviy xotiralar tiklandi");
      }
    });
  }

  /* --------------------------------------------------------------------------
     12. Yordamchi Funksiyalar
     -------------------------------------------------------------------------- */
  function updateDashboardStats() {
    const list = window.auraStorage.getAll();
    if (statTotalCapsules) statTotalCapsules.textContent = list.length;

    if (statTopMood && list.length > 0) {
      const counts = {};
      list.forEach(item => {
        counts[item.mood] = (counts[item.mood] || 0) + 1;
      });
      let top = list[0].mood;
      let max = 0;
      Object.keys(counts).forEach(k => {
        if (counts[k] > max) {
          max = counts[k];
          top = k;
        }
      });
      statTopMood.textContent = top;
    }
  }

  function showToast(msg) {
    if (!toast || !toastMessage) return;
    toastMessage.textContent = msg;
    toast.classList.add('active');
    setTimeout(() => {
      toast.classList.remove('active');
    }, 2800);
  }

  function formatDate(isoStr) {
    if (!isoStr) return "Yaqinda";
    try {
      const d = new Date(isoStr);
      const months = ["Yan", "Fev", "Mar", "Apr", "May", "Iyun", "Iyul", "Avg", "Sen", "Okt", "Noy", "Dek"];
      return `${d.getDate()} ${months[d.getMonth()]}, ${d.getFullYear()}`;
    } catch (e) {
      return "Yaqinda";
    }
  }

  function escapeHtml(str) {
    if (!str) return '';
    return str
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  }

  // Dastlabki yuklash
  renderArchiveList();
  updateDashboardStats();
});
