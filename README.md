# AuraEcho — Fazoviy Xotira va Hissiyot Jurnali (Spatial Memory & Sensory Journal)

**AuraEcho** — Apple iOS / Cupertino dizayn tizimiga qat'iy asoslangan, real vaqtda Web Audio API orqali fazoviy tovushlarni sintez qiluvchi, sensorli telemetriya ko'rsatkichlari (desibel shovqin, yorug'lik, 3D giroskop qiyaligi) bilan xotiralarni muhrlovchi innovatsion veb-ilova.

---

## Asosiy Imkoniyatlar va Texnik Xususiyatlar

1. **Apple iOS / Cupertino Dizayn Tizimi (Strict Flat Aesthetic):**
   - Mutlaqo gradientlarsiz (Zero Gradients) toza iOS tizim ranglari (`#007AFF`, `#F2F2F7`, `#FFFFFF`, `#000000`, `#1C1C1E`, `#34C759`, `#FF3B30`).
   - Cupertino Switch (51x31 standart), Segmented Controls, Inset Grouped List, Modal Bottom Sheets va Action Dialoglar.
   - SF Pro tizim tipografiyasi.
   - Hech qanday stiker yoki multfilm rasmlarsiz — faqat minimalist SF SVG vektor piktogrammalari.

2. **Mukammal Tongi va Tungi Rejim (Light / Dark Modes):**
   - Tongi (`#F2F2F7` / `#FFFFFF`) va Tungi (`#000000` / `#1C1C1E`) rejimlari o'rtasida bir lahzalik o'tish.
   - WCAG AA kontrast talablariga to'liq mos.

3. **Web Audio API Fazoviy Tovush Sintezatori (Zero External Assets):**
   - **Taptic Click:** Tugmalar bosilganda iOS Haptic Engine kabi nozik audio signal.
   - **Yomg'ir & Tomchilar:** Oq/pushti shovqin filtrlari va tasodifiy mikro-tomchilar sintezi.
   - **O'rmon & Mayin Shamol:** LFO modulyatsiyali shamol g'ubori va qushlar sayrashi harmonikasi.
   - **Binaural To'lqinlar (6Hz Theta):** Chap va o'ng quloq uchun stereo ajratilgan chastotali meditatsiya to'lqinlari.
   - **Okean Oq Shovqini:** Past chastotali LFO modulyatsiyali to'lqin ko'tarilishi va qaytishi.
   - **Real Vaqtli Spektr Vizualizatori:** HTML5 Canvas orqali tekis iOS spektr ustunlari.

4. **Sensorli Telemetriya Vidjetlari:**
   - Shovqin darajasi (Desibel metr).
   - Atrof-muhit yorug'ligi (Lux datchigi).
   - 3D Giroskop qiyaligi vizualizatori.
   - Fazoviy uyg'unlik indeksi hisoblagichi.

5. **Xotiralar Arxivi & Kapsulalar Boshqaruvi:**
   - Yangi kapsula yaratish, joylashuv, hissiyot, teglar va audio muhitini biriktirish.
   - Qidiruv va hissiyotlar bo'yicha saralash.
   - Xotiraning fazoviy muhitini bir marta bosish bilan qayta tinglash.
   - JSON eksport va import qilish imkoniyati.

6. **To'liq O'zbek Tili:**
   - Barcha menyular, bildirishnomalar, tavsiflar va muloqot oynalari to'liq o'zbek tilida.

---

## Loyihani Ishga Tushirish

Ilova sof veb-texnologiyalar (HTML5, Vanilla CSS, Vanilla JavaScript va Web Audio API) asosida yaratilgan. Istalgan zamonaviy veb-brauzerda yoki lokal server orqali ishlaydi.

### Tezkor lokal server orqali ochish:
```bash
# Python 3 orqali
python -m http.server 8080
```
Brauzerda oching: `http://localhost:8080`

---

## Majburiy Mualliflik va Aloqa

- **Yaratuvchi:** Hayrulloh Abdusamadov
- **Telegram kanal:** [https://t.me/HayrullohAdusamadov](https://t.me/HayrullohAdusamadov)
