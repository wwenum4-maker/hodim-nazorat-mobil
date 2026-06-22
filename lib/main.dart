import 'package:flutter/material.dart';
import 'api.dart';
import 'screens/auth_screen.dart';
import 'screens/link_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HodimApp());
}

const seedTeal = Color(0xFF0D9488);

class HodimApp extends StatelessWidget {
  const HodimApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Hodim Nazorati",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedTeal),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        ),
      ),
      home: const Bootstrap(),
    );
  }
}

/// Boshlanishda: token bormi? bo'lsa — bog'langanmi? ga qarab ekran tanlaydi.
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});
  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    await Api.init();
    if (!mounted) return;
    if (!Api.isLoggedIn) {
      _go(const AuthScreen());
      return;
    }
    try {
      final data = await Api.me();
      final emp = data["employee"] as Map;
      if (emp["linked"] == true) {
        _go(HomeScreen(initial: data));
      } else {
        _go(const LinkScreen());
      }
    } catch (_) {
      await Api.logout();
      _go(const AuthScreen());
    }
  }

  void _go(Widget w) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => w));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
