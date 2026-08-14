/**
 * AuraEcho - Xotira Kapsulalari va LocalStorage Boshqaruvi
 */

const STORAGE_KEY = 'aura_echo_capsules_v1';
const THEME_KEY = 'aura_echo_theme';

const DEFAULT_CAPSULES = [
  {
    id: 'cap_1',
    title: "Chorvoq tog'lari shabadasi",
    mood: "Xotirjamlik",
    moodColor: "#34C759",
    location: "Burchmulla, Chorvoq suv ombori",
    notes: "Tog' cho'qqilaridan esayotgan mayin shabada va archalar hidi. Fikrlarim butunlay tiniqlashgan lahza.",
    tags: ["Tabiat", "Salqin shabada", "Xotirjamlik", "Tog' havosi"],
    telemetry: {
      decibels: 34,
      lux: 780,
      tiltX: -2,
      tiltY: 6,
      sensoryIndex: 94
    },
    soundConfig: {
      preset: "calm",
      rain: 0.0,
      forest: 0.7,
      binaural: 0.3,
      ocean: 0.0
    },
    createdAt: "2026-08-12T10:30:00.000Z"
  },
  {
    id: 'cap_2',
    title: "Toshkentdagi tungi yomg'ir",
    mood: "Chuqur Diqqat",
    moodColor: "#007AFF",
    location: "Navoiy ko'chasi, Qahvaxona",
    notes: "Derazaga urilayotgan yomg'ir tomchilari va issiq qahva ifori. Yangi loyihalar ustida ishlash uchun ajoyib sokinlik.",
    tags: ["Yomg'ir", "Tungi shahar", "Ijodkorlik", "Qahva"],
    telemetry: {
      decibels: 41,
      lux: 210,
      tiltX: 4,
      tiltY: -3,
      sensoryIndex: 91
    },
    soundConfig: {
      preset: "focus",
      rain: 0.8,
      forest: 0.0,
      binaural: 0.4,
      ocean: 0.2
    },
    createdAt: "2026-08-13T22:15:00.000Z"
  },
  {
    id: 'cap_3',
    title: "Samarqand Registon maydoni sukunati",
    mood: "Ilhom va Hayrat",
    moodColor: "#AF52DE",
    location: "Registon ansambli, Samarqand",
    notes: "Moviy gumbazlar ostidagi cheksiz sokinlik va ulug'vorlik. Asrlar nafasi va fazoviy qulaylik hissi.",
    tags: ["Tarixiy muhit", "Quyosh nuri", "Fazoviy kenglik", "Me'morchilik"],
    telemetry: {
      decibels: 29,
      lux: 920,
      tiltX: 0,
      tiltY: 2,
      sensoryIndex: 97
    },
    soundConfig: {
      preset: "meditation",
      rain: 0.0,
      forest: 0.2,
      binaural: 0.8,
      ocean: 0.3
    },
    createdAt: "2026-08-14T09:40:00.000Z"
  }
];

class AuraStorage {
  constructor() {
    this.init();
  }

  init() {
    if (!localStorage.getItem(STORAGE_KEY)) {
      this.saveAll(DEFAULT_CAPSULES);
    }
  }

  getAll() {
    try {
      const data = localStorage.getItem(STORAGE_KEY);
      return data ? JSON.parse(data) : DEFAULT_CAPSULES;
    } catch (e) {
      console.error("Xotiralarni o'qishda xatolik:", e);
      return DEFAULT_CAPSULES;
    }
  }

  getById(id) {
    const list = this.getAll();
    return list.find(item => item.id === id) || null;
  }

  saveAll(list) {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
      return true;
    } catch (e) {
      console.error("Xotiralarni saqlashda xatolik:", e);
      return false;
    }
  }

  create(capsuleData) {
    const list = this.getAll();
    const newCapsule = {
      id: 'cap_' + Date.now(),
      title: capsuleData.title || "Yangi Xotira",
      mood: capsuleData.mood || "Xotirjamlik",
      moodColor: capsuleData.moodColor || "#007AFF",
      location: capsuleData.location || "Noma'lum joylashuv",
      notes: capsuleData.notes || "",
      tags: capsuleData.tags || [],
      telemetry: capsuleData.telemetry || {
        decibels: 38,
        lux: 400,
        tiltX: 0,
        tiltY: 0,
        sensoryIndex: 85
      },
      soundConfig: capsuleData.soundConfig || {
        preset: "custom",
        rain: 0.5,
        forest: 0.0,
        binaural: 0.5,
        ocean: 0.0
      },
      createdAt: new Date().toISOString()
    };

    list.unshift(newCapsule);
    this.saveAll(list);
    return newCapsule;
  }

  delete(id) {
    let list = this.getAll();
    list = list.filter(item => item.id !== id);
    this.saveAll(list);
    return true;
  }

  search(query = '', moodFilter = 'all', tagFilter = 'all') {
    let list = this.getAll();
    const q = query.toLowerCase().trim();

    return list.filter(item => {
      const matchesQuery = !q || 
        item.title.toLowerCase().includes(q) || 
        item.notes.toLowerCase().includes(q) ||
        item.location.toLowerCase().includes(q) ||
        item.tags.some(t => t.toLowerCase().includes(q));

      const matchesMood = (moodFilter === 'all') || (item.mood === moodFilter);
      const matchesTag = (tagFilter === 'all') || (item.tags.includes(tagFilter));

      return matchesQuery && matchesMood && matchesTag;
    });
  }

  exportJSON() {
    const list = this.getAll();
    return JSON.stringify(list, null, 2);
  }

  importJSON(jsonString) {
    try {
      const parsed = JSON.parse(jsonString);
      if (Array.isArray(parsed)) {
        this.saveAll(parsed);
        return true;
      }
      return false;
    } catch (e) {
      console.error("Import xatosi:", e);
      return false;
    }
  }

  resetToDefaults() {
    this.saveAll(DEFAULT_CAPSULES);
    return DEFAULT_CAPSULES;
  }

  // Mavzu sozlamalari
  getTheme() {
    return localStorage.getItem(THEME_KEY) || 'light';
  }

  setTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
  }
}

// Global instansiya
window.auraStorage = new AuraStorage();
