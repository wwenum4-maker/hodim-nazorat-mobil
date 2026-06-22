import 'dart:async';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'api.dart';

/// Fonda GPS kuzatuvi.
/// Android'da foreground service (doimiy bildirishnoma) orqali ilova yopilganda ham ishlaydi.
/// iOS'da "Always" ruxsati + background location rejimi orqali davom etadi.
/// Joylashuv serverga yuboriladi — kirish/chiqish (geofence) serverda hisoblanadi.
class LocationService {
  static StreamSubscription<Position>? _sub;
  static Timer? _heartbeat;
  static String lastStatus = "—"; // 'in' | 'out'
  static String? lastBranch;
  static String? lastEvent; // 'arrival' | 'departure' | null
  static void Function()? onUpdate;

  static bool get isRunning => _sub != null;

  /// Joylashuv ruxsatlarini tekshirish va so'rash. Fon uchun "Always" kerak.
  static Future<String> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return "Telefonda joylashuv (GPS) o'chiq. Yoqing.";
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      return "Joylashuvga ruxsat berilmadi.";
    }
    if (perm == LocationPermission.deniedForever) {
      return "Ruxsat butunlay rad etilgan. Sozlamalardan yoqing.";
    }
    // whileInUse bo'lsa ham ishlaydi, lekin fon uchun "Always" tavsiya etiladi.
    return "ok";
  }

  static LocationSettings _settings() {
    const notif = "Ish vaqti davomida joylashuvingiz kuzatilmoqda";
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25, // 25 metr siljiganda yangilash
        forceLocationManager: false,
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Hodim Nazorati",
          notificationText: notif,
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    } else if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 25,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 25);
  }

  static Future<String> start() async {
    final p = await ensurePermission();
    if (p != "ok") return p;

    // Siljiganda yuborish
    _sub = Geolocator.getPositionStream(locationSettings: _settings()).listen((pos) {
      _send(pos.latitude, pos.longitude);
    });

    // Harakatsiz turganda ham server yangi qolishi uchun har 2 daqiqada bir marta
    _heartbeat = Timer.periodic(const Duration(minutes: 2), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition();
        _send(pos.latitude, pos.longitude);
      } catch (_) {}
    });

    // Darhol bitta joylashuv yuboramiz
    try {
      final pos = await Geolocator.getCurrentPosition();
      _send(pos.latitude, pos.longitude);
    } catch (_) {}

    return "ok";
  }

  static Future<void> _send(double lat, double lng) async {
    try {
      final r = await Api.sendLocation(lat, lng);
      lastStatus = r["status"]?.toString() ?? lastStatus;
      lastBranch = r["branch"]?.toString();
      lastEvent = r["event"]?.toString();
      onUpdate?.call();
    } catch (_) {
      // tarmoq xatosi — keyingi yangilanishda qayta urinadi
    }
  }

  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _heartbeat?.cancel();
    _heartbeat = null;
    onUpdate?.call();
  }
}
