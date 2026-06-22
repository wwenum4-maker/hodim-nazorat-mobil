# APK'ni GitHub'da avtomatik yasash

Kompyuteringizga Flutter yoki Android Studio o'rnatish **shart emas**.
GitHub serverlari APK'ni siz uchun yasaydi, siz tayyor faylni yuklab olasiz.

---

## 1-qadam: GitHub'ga yuklash
1. github.com'da bepul hisob oching.
2. Yangi repozitoriy yarating, masalan `hodim-nazorat-mobil` (Private bo'lsa ham bo'ladi).
3. Bu papkadagi **hamma** fayllarni repozitoriyga yuklang.
   - Eng oson yo'l — **GitHub Desktop** dasturi (grafik, sudrab tashlash) yoki kompyuterda buyruqlar:
   ```bash
   git init
   git add .
   git commit -m "Hodim Nazorati mobil"
   git branch -M main
   git remote add origin https://github.com/FOYDALANUVCHI/hodim-nazorat-mobil.git
   git push -u origin main
   ```
   > Muhim: `.github` papkasi ham yuklanishi shart — APK aynan shu orqali yasaladi.
   > (Saytda fayllarni sudrab tashlash yashirin `.github` papkasini o'tkazib yuborishi mumkin,
   > shuning uchun `git` yoki GitHub Desktop afzal.)

## 2-qadam: Avtomatik yasash
- Yuklash tugashi bilan GitHub yasashni o'zi boshlaydi.
- Repozitoriyda **Actions** bo'limiga kiring — "APK yasash" jarayonini ko'rasiz (≈ 5–10 daqiqa).
- Yashil ✓ chiqsa — tayyor.
- Qo'lda qayta yasash kerak bo'lsa: **Actions → "APK yasash" → "Run workflow"**.

## 3-qadam: APK'ni yuklab olish
- **Eng oson (telefonda ham):** repozitoriy sahifasi → o'ng tarafda **Releases** → **latest** →
  `app-release.apk` faylini yuklab oling.
- Yoki: **Actions** → tugagan jarayon → eng pastda **Artifacts** → `hodim-nazorat-apk`.

## 4-qadam: Telefonga o'rnatish
1. APK'ni xodim telefoniga o'tkazing (Telegram, USB yoki havola orqali).
2. Faylni ochib o'rnating. Android "Noma'lum manbalar"ga ruxsat so'rasa — ruxsat bering.
3. Ilovani oching → **"Server manzili"** maydoniga serveringiz manzilini yozing
   (Render'dagi URL, masalan `https://hodim-nazorat.onrender.com`).
4. Ro'yxatdan o'tish → admindan olgan **QR yoki kod** bilan ulanish → **GPS kuzatuvni yoqish**.

---

## Muhim eslatmalar
- Birinchi ochilishda ilova **joylashuv** va **kamera**ga ruxsat so'raydi.
  Joylashuvda **"Har doim ruxsat berish" (Allow all the time)** ni tanlang —
  aks holda ilova yopiq bo'lganda fonda kuzatuv ishlamaydi.
- Kodga o'zgartirish kiritsangiz, GitHub'ga qayta `push` qilish kifoya —
  yangi APK avtomatik yasaladi.
- **Yasash xato bersa:** Actions'dagi qizil qadamni ochib xabarini o'qing.
  Ko'pincha yechim — `.github/workflows/build-apk.yml` faylida Flutter versiyasini belgilash:
  `channel: stable` o'rniga `flutter-version: 3.24.5` yozib qo'yish.
- APK debug-kalit bilan imzolanadi — telefonga o'rnatishga to'liq yetarli.
  (Google Play'ga joylash uchun alohida imzo kerak — hozir kerak emas.)
