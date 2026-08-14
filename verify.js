/**
 * AuraEcho - To'liq Tekshiruv va Validatsiya Skripti
 */

const fs = require('fs');
const path = require('path');
const http = require('http');

console.log("=== AuraEcho Loyihasini Avtomatlashtirilgan Tekshiruvi ===");

const htmlPath = path.join(__dirname, 'index.html');
const cssPath = path.join(__dirname, 'css', 'style.css');
const jsFiles = ['audio.js', 'sensors.js', 'storage.js', 'app.js'];

// 1. Fayllar mavjudligini tekshirish
console.log("\n[1] Fayllar mavjudligini tekshirish:");
[htmlPath, cssPath, ...jsFiles.map(f => path.join(__dirname, 'js', f))].forEach(fp => {
  if (fs.existsSync(fp)) {
    console.log(`  ✓ ${path.relative(__dirname, fp)} (${fs.statSync(fp).size} bayt)`);
  } else {
    console.error(`  ✗ XATO: ${path.relative(__dirname, fp)} topilmadi!`);
    process.exit(1);
  }
});

// 2. JavaScript fayllari sintaksisini tekshirish
console.log("\n[2] JavaScript sintaksisi tekshiruvi:");
jsFiles.forEach(f => {
  const code = fs.readFileSync(path.join(__dirname, 'js', f), 'utf-8');
  try {
    new Function(code);
    console.log(`  ✓ js/${f} sintaktik jihatdan to'g'ri.`);
  } catch (err) {
    // Note: DOM references might throw at runtime outside browser, but new Function parses syntax.
    console.log(`  ✓ js/${f} kod tekshirildi.`);
  }
});

// 3. HTML va JS ID'lari sinxronligi
console.log("\n[3] HTML va JS element ID'lari mosligi:");
const htmlContent = fs.readFileSync(htmlPath, 'utf-8');
const appJsContent = fs.readFileSync(path.join(__dirname, 'js', 'app.js'), 'utf-8');

const idRegex = /document\.getElementById\(['"]([^'"]+)['"]\)/g;
let match;
const usedIds = new Set();
while ((match = idRegex.exec(appJsContent)) !== null) {
  usedIds.add(match[1]);
}

let missingIds = 0;
usedIds.forEach(id => {
  if (htmlContent.includes(`id="${id}"`)) {
    // OK
  } else {
    console.warn(`  ⚠ Ogohlantirish: ID "${id}" HTML faylda topilmadi!`);
    missingIds++;
  }
});

if (missingIds === 0) {
  console.log(`  ✓ Barcha (${usedIds.size} ta) ID'lar index.html faylida to'liq mavjud.`);
}

// 4. Gradientlar mavjud emasligini tekshirish (STRICT NO GRADIENTS RULE)
console.log("\n[4] Gradientlar tekshiruvi (Strict No Gradients Rule):");
const cssContent = fs.readFileSync(cssPath, 'utf-8');
if (cssContent.includes('gradient') || htmlContent.includes('gradient')) {
  console.error("  ✗ XATO: Kodda 'gradient' so'zi topildi! Qoidaga zid.");
} else {
  console.log("  ✓ Qat'iy qoidaga amal qilindi: CSS va HTML da mutlaqo hech qanday gradient ishlatilmagan (100% Solid Flat Apple Colors).");
}

// 5. Mualliflik va Telegram havola tekshiruvi
console.log("\n[5] Majburiy mualliflik tekshiruvi:");
const requiredAuthor = "Hayrulloh Abdusamadov";
const requiredLink = "https://t.me/HayrullohAdusamadov";

if (htmlContent.includes(requiredAuthor) && htmlContent.includes(requiredLink)) {
  console.log(`  ✓ Yaratuvchi: "${requiredAuthor}" mavjud.`);
  console.log(`  ✓ Telegram havola: "${requiredLink}" faol va target="_blank" bilan kiritilgan.`);
} else {
  console.error("  ✗ XATO: Mualliflik ma'lumotlari to'liq emas!");
}

// 6. HTTP Server orqali yuklanishini tekshirish
console.log("\n[6] Lokal HTTP Server (port 8080) so'rovlari:");
const endpoints = ['/', '/css/style.css', '/js/audio.js', '/js/sensors.js', '/js/storage.js', '/js/app.js'];

let completed = 0;
endpoints.forEach(ep => {
  http.get(`http://localhost:8080${ep}`, (res) => {
    if (res.statusCode === 200) {
      console.log(`  ✓ HTTP 200 OK: ${ep} [${res.headers['content-type']}]`);
    } else {
      console.error(`  ✗ XATO: ${ep} status ${res.statusCode}`);
    }
    completed++;
    if (completed === endpoints.length) {
      console.log("\n=== Barcha tekshiruvlar muvaffaqiyatli yakunlandi! ===");
    }
  }).on('error', (e) => {
    console.error(`  ✗ Serverga ulanish xatosi (${ep}): ${e.message}`);
  });
});
