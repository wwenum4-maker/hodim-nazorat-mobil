import 'package:flutter/material.dart';
import '../api.dart';
import 'link_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _login = true;
  bool _busy = false;
  String? _err;

  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final pw = TextEditingController();
  final server = TextEditingController(text: Api.base);

  Future<void> _saveServer() async {
    await Api.setBase(server.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Server manzili saqlandi")));
  }

  Future<void> _submit() async {
    setState(() { _busy = true; _err = null; });
    try {
      await Api.setBase(server.text);
      if (_login) {
        await Api.login(email: email.text.trim(), password: pw.text);
      } else {
        await Api.register(name: name.text.trim(), email: email.text.trim(), phone: phone.text.trim(), password: pw.text);
      }
      final data = await Api.me();
      final emp = data["employee"] as Map;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => emp["linked"] == true ? HomeScreen(initial: data) : const LinkScreen(),
      ));
    } catch (e) {
      setState(() => _err = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Hodim Nazorati", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  // Tablar
                  Container(
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _tab("Kirish", _login, () => setState(() => _login = true)),
                      _tab("Ro'yxatdan o'tish", !_login, () => setState(() => _login = false)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  if (!_login) ...[
                    TextField(controller: name, decoration: const InputDecoration(hintText: "Ismingiz (F.I.O)")),
                    const SizedBox(height: 8),
                  ],
                  TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: "Gmail")),
                  const SizedBox(height: 8),
                  if (!_login) ...[
                    TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: "Telefon (+998...)")),
                    const SizedBox(height: 8),
                  ],
                  TextField(controller: pw, obscureText: true, decoration: const InputDecoration(hintText: "Parol")),
                  if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_login ? "Kirish" : "Ro'yxatdan o'tish"),
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 6),
                  const Text("Server manzili", style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Expanded(child: TextField(controller: server, style: const TextStyle(fontSize: 13), decoration: const InputDecoration(isDense: true, hintText: "http://192.168.x.x:4000"))),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: _saveServer, child: const Text("Saqlash")),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(9)),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: active ? const Color(0xFF0F766E) : Colors.black54)),
        ),
      ),
    );
  }
}
