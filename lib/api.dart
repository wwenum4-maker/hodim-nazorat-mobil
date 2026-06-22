import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiError implements Exception {
  final String message;
  ApiError(this.message);
  @override
  String toString() => message;
}

/// Backend bilan ishlovchi yagona xizmat.
class Api {
  // Android emulyatori uchun host kompyuter = 10.0.2.2.
  // Haqiqiy telefon uchun: kompyuteringiz LAN IP (masalan http://192.168.1.50:4000)
  // yoki internetga joylangan manzil (masalan https://sizning-domen.uz).
  static String _base = "http://10.0.2.2:4000";
  static String? _token;

  static String get base => _base;
  static String? get token => _token;
  static bool get isLoggedIn => _token != null;

  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _base = p.getString("api") ?? _base;
    _token = p.getString("token");
  }

  static Future<void> setBase(String b) async {
    _base = b.trim().replaceAll(RegExp(r"/+$"), "");
    final p = await SharedPreferences.getInstance();
    await p.setString("api", _base);
  }

  static Future<void> setToken(String? t) async {
    _token = t;
    final p = await SharedPreferences.getInstance();
    if (t == null) {
      await p.remove("token");
    } else {
      await p.setString("token", t);
    }
  }

  static Map<String, String> _headers({bool json = true}) => {
        if (json) "Content-Type": "application/json",
        if (_token != null) "Authorization": "Bearer $_token",
      };

  static dynamic _decode(http.Response r) {
    final body = r.body.isEmpty ? {} : jsonDecode(r.body);
    if (r.statusCode >= 400) {
      throw ApiError(body is Map && body["error"] != null ? body["error"] : "Xatolik (${r.statusCode})");
    }
    return body;
  }

  static Future<Map<String, dynamic>> _post(String path, Map body) async {
    final r = await http.post(Uri.parse(_base + path), headers: _headers(), body: jsonEncode(body));
    return Map<String, dynamic>.from(_decode(r));
  }

  static Future<Map<String, dynamic>> _get(String path) async {
    final r = await http.get(Uri.parse(_base + path), headers: _headers());
    return Map<String, dynamic>.from(_decode(r));
  }

  // ---- Auth ----
  static Future<void> register({required String name, required String email, required String phone, required String password}) async {
    final d = await _post("/api/employee/register", {"name": name, "email": email, "phone": phone, "password": password});
    await setToken(d["token"]);
  }

  static Future<void> login({required String email, required String password}) async {
    final d = await _post("/api/employee/login", {"email": email, "password": password});
    await setToken(d["token"]);
  }

  static Future<Map<String, dynamic>> me() => _get("/api/employee/me");

  static Future<Map<String, dynamic>> link(String joinCode) => _post("/api/employee/link", {"joinCode": joinCode});

  static Future<void> logout() => setToken(null);

  // ---- Joylashuv (geofence -> kirish/chiqish serverda) ----
  static Future<Map<String, dynamic>> sendLocation(double lat, double lng) =>
      _post("/api/employee/location", {"lat": lat, "lng": lng});

  // ---- Uzrli sabab (rasm + izoh) ----
  static Future<void> sendAbsence(String comment, String? photoPath) async {
    final req = http.MultipartRequest("POST", Uri.parse("$_base/api/employee/absence"));
    if (_token != null) req.headers["Authorization"] = "Bearer $_token";
    req.fields["comment"] = comment;
    if (photoPath != null) {
      req.files.add(await http.MultipartFile.fromPath("photo", photoPath));
    }
    final res = await http.Response.fromStream(await req.send());
    _decode(res);
  }
}
