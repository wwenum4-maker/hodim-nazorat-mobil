#!/usr/bin/env python3
# flutter create yaratgan AndroidManifest.xml ga kerakli ruxsatlarni qo'shadi
# (GPS, fonda joylashuv, foreground service, kamera, bildirishnoma).
import re

p = "android/app/src/main/AndroidManifest.xml"
s = open(p, encoding="utf-8").read()

perms = """
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
"""

# Ruxsatlar hali qo'shilmagan bo'lsa, <manifest ...> tegidan keyin qo'shamiz
if "ACCESS_FINE_LOCATION" not in s:
    s = re.sub(r"(<manifest[^>]*>)", r"\1" + perms, s, count=1)

# Ilova nomini chiroyliroq qilamiz
s = s.replace('android:label="hodim_nazorat"', 'android:label="Hodim Nazorati"')

open(p, "w", encoding="utf-8").write(s)
print("Manifest: ruxsatlar qo'shildi va nom yangilandi")
