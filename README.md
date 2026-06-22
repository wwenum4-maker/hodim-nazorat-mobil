# Hodim Nazorati — Mobil ilova (Flutter)

Xodimlar telefoni uchun ilova: ro'yxatdan o'tish/kirish, QR orqali tashkilotga bog'lanish,
**fonda GPS kuzatuvi** (joylashuvni serverga yuboradi — kirish/chiqish serverda hisoblanadi)
va uzrli sabab (rasm + izoh) yuborish.

> Admin **veb-paneldan** boshqaradi (alohida loyiha). Bu ilova faqat **xodim** uchun.

## Talablar
- **Flutter SDK** (3.3+): https://docs.flutter.dev/get-started/install
- Android uchun: **Android Studio** (Android SDK + emulyator yoki telefon)
- iOS uchun: **macOS + Xcode** (faqat Mac'da)
- Ishlab turgan **backend** (1-bosqichda yasalgan server)

## 1. Loyihani tayyorlash
Flutter to'liq loyiha (android/ va ios/ papkalari) buyruq bilan yaratiladi. Tartib:

```bash
# 1) Bo'sh Flutter loyiha yarating
flutter create hodim_nazorat
cd hodim_nazorat

# 2) Shu paketdagi fayllarni nusxalang:
#    - pubspec.yaml  -> loyiha ildiziga (mavjudini almashtiring)
#    - lib/ ichidagi hamma fayllar -> loyihaning lib/ ga
# 3) Paketlarni oling
flutter pub get
```

## 2. Ruxsatlarni qo'shish
- **Android:** `setup/AndroidManifest-permissions.xml` ichidagi qatorlarni
  `android/app/src/main/AndroidManifest.xml` ga qo'shing. `minSdkVersion 21` qiling.
- **iOS:** `setup/iOS-Info.plist-keys.xml` ichidagilarni `ios/Runner/Info.plist` ga qo'shing
  va Xcode'da **Background Modes → Location updates** ni yoqing.

## 3. Server manzilini sozlash
Ilovaning kirish ekranida pastda **"Server manzili"** maydoni bor:
- **Android emulyator:** `http://10.0.2.2:4000` (host kompyuter)
- **Haqiqiy telefon (bir Wi-Fi'da):** kompyuteringiz IP — masalan `http://192.168.1.50:4000`
  (kompyuter IP: Windows `ipconfig`, Mac/Linux `ifconfig`/`ip a`)
- **Internetga joylangach:** `https://sizning-domeningiz` (3-bosqich)

Standart qiymat `lib/api.dart` ichida `_base` da ham bor.

## 4. Ishga tushirish
```bash
flutter run            # ulangan telefon/emulyatorda
# yoki o'rnatiladigan APK:
flutter build apk --release   # build/app/outputs/flutter-apk/app-release.apk
```
`app-release.apk` ni xodimlarga ulashing (Android). iOS uchun TestFlight/App Store kerak.

## Ishlash tartibi (xodim)
1. **Ro'yxatdan o'tish** — ism, Gmail, telefon, parol.
2. **Adminga bog'lanish** — admin bergan QR ni skaner qiladi yoki kodni kiritadi.
3. **GPS kuzatuvini yoqish** — "Kuzatuvni yoqish" tugmasi. Shundan so'ng ilova **fonda ham**
   joylashuvni serverga yuboradi; xodim filial hududiga kirsa server avtomatik
   "ishga keldi", chiqsa "ishdan ketdi" deb yozadi va adminга xabar/email yuboradi.
4. **Uzrli sabab** — kela olmasa rasm + izoh yuboradi.

## Fonda GPS haqida muhim eslatma
- **Android:** doimiy bildirishnoma (foreground service) ko'rsatiladi — bu ilova fonda/ekran
  o'chganda ham joylashuvni yuborishini ta'minlaydi. Fon uchun "Always / Doim ruxsat bering".
- **iOS:** "Always" ruxsati + Background Modes (Location) yoqilgan bo'lishi kerak.
- Ba'zi Android telefonlarda (Xiaomi, Huawei va h.k.) batareya tejash ilovani
  "uxlatishi" mumkin — sozlamalardan ilovaga **"cheklanmagan/avtostart"** ruxsat bering.

## Keyingi qadam (3-bosqich)
Serverni internetga joylab (URL + HTTPS), server manzilini shu URL'ga o'zgartirasiz —
shunda istalgan joydagi telefon ulanadi. Play Store/App Store'ga chiqarish — alohida bosqich.
