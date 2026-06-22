import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api.dart';
import 'home_screen.dart';
import 'auth_screen.dart';

class LinkScreen extends StatefulWidget {
  const LinkScreen({super.key});
  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  final code = TextEditingController();
  bool _busy = false;
  bool _scanning = false;
  String? _err;

  Future<void> _link(String value) async {
    if (_busy) return;
    setState(() { _busy = true; _err = null; _scanning = false; });
    try {
      final d = await Api.link(value.trim());
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen(initial: d)));
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    await Api.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adminga bog'lanish"),
        backgroundColor: Colors.white,
        actions: [TextButton(onPressed: _logout, child: const Text("Chiqish", style: TextStyle(color: Colors.red)))],
      ),
      body: _scanning ? _scanner() : _form(),
    );
  }

  Widget _form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Ro'yxatdan o'tdingiz. Endi admin bergan QR kodni skaner qiling yoki kodni kiriting.",
                style: TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => setState(() => _scanning = true),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text("QR kodni skaner qilish"),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
            const SizedBox(height: 16),
            const Text("yoki kodni qo'lda kiriting:", style: TextStyle(color: Colors.black54, fontSize: 12)),
            const SizedBox(height: 6),
            TextField(controller: code, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: "OFIS-XXXXX")),
            if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: Colors.red, fontSize: 13))),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _busy ? null : () => _link(code.text),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text("Bog'lanish"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scanner() {
    return Stack(
      children: [
        MobileScanner(
          onDetect: (capture) {
            final list = capture.barcodes;
            if (list.isNotEmpty && list.first.rawValue != null) {
              _link(list.first.rawValue!);
            }
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FilledButton(onPressed: () => setState(() => _scanning = false), child: const Text("Bekor qilish")),
          ),
        ),
      ],
    );
  }
}
