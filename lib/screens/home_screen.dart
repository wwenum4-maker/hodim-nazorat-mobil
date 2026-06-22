import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api.dart';
import '../location_service.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map initial; // /api/employee/me natijasi
  const HomeScreen({super.key, required this.initial});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Map emp;
  Map? hours;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    emp = Map.from(widget.initial["employee"] ?? {});
    hours = widget.initial["hours"];
    LocationService.onUpdate = () { if (mounted) setState(() {}); };
  }

  @override
  void dispose() {
    LocationService.onUpdate = null;
    super.dispose();
  }

  Future<void> _toggleTracking() async {
    if (LocationService.isRunning) {
      await LocationService.stop();
      setState(() {});
      return;
    }
    setState(() => _starting = true);
    final res = await LocationService.start();
    setState(() => _starting = false);
    if (res != "ok" && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res)));
    } else {
      setState(() {});
    }
  }

  Future<void> _logout() async {
    await LocationService.stop();
    await Api.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  Future<void> _refresh() async {
    try {
      final d = await Api.me();
      setState(() { emp = Map.from(d["employee"] ?? {}); hours = d["hours"]; });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final running = LocationService.isRunning;
    final status = running ? LocationService.lastStatus : (emp["status"]?.toString() ?? "out");
    final inWork = status == "in";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(emp["name"]?.toString() ?? "Hodim"),
        actions: [TextButton(onPressed: _logout, child: const Text("Chiqish", style: TextStyle(color: Colors.red)))],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Ish vaqti
            _card(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Ish vaqti", style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(hours == null ? "—" : "${hours!["start"]} – ${hours!["end"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
              const Icon(Icons.lock_outline, color: Colors.black38),
            ])),

            // GPS kuzatuvi
            _card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("GPS kuzatuvi", style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: running ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(999)),
                  child: Text(running ? "Yoqilgan" : "O'chiq", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: running ? const Color(0xFF047857) : Colors.black54)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(
                running
                    ? "Joylashuvingiz fonda kuzatilmoqda. Hudud(filial)ga kirsangiz avtomatik 'ishga keldi' yoziladi."
                    : "Kuzatuvni yoqing — ilova fonda ham joylashuvni serverga yuboradi.",
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _starting ? null : _toggleTracking,
                icon: Icon(running ? Icons.stop : Icons.play_arrow),
                label: Text(_starting ? "Ishga tushmoqda..." : (running ? "Kuzatuvni o'chirish" : "Kuzatuvni yoqish")),
                style: FilledButton.styleFrom(
                  backgroundColor: running ? const Color(0xFF1E293B) : const Color(0xFF0D9488),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ])),

            // Holat
            _card(child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Holatingiz", style: TextStyle(color: Colors.black54, fontSize: 12)),
                Text(inWork ? "Ishda" : "Ofisda emas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: inWork ? const Color(0xFF047857) : Colors.black87)),
                if (running && LocationService.lastBranch != null) Text("📍 ${LocationService.lastBranch}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ]),
              Icon(inWork ? Icons.check_circle : Icons.location_off, color: inWork ? const Color(0xFF10B981) : Colors.black26, size: 32),
            ])),

            // Uzrli sabab
            _card(
              border: const Color(0xFFFDE68A),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text("Uzrli sabab yuborish", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text("Vaqtida kela olmasangiz — rasm va izoh yuboring.", style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _openAbsence,
                  icon: const Icon(Icons.photo_camera),
                  label: const Text("Rasm + izoh yuborish"),
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _openAbsence() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const AbsenceSheet(),
    );
  }

  Widget _card({required Widget child, Color? border}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: border != null ? Border.all(color: border, width: 2) : null,
      ),
      child: child,
    );
  }
}

class AbsenceSheet extends StatefulWidget {
  const AbsenceSheet({super.key});
  @override
  State<AbsenceSheet> createState() => _AbsenceSheetState();
}

class _AbsenceSheetState extends State<AbsenceSheet> {
  final comment = TextEditingController();
  XFile? photo;
  bool _busy = false;

  Future<void> _pick(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, imageQuality: 70, maxWidth: 1280);
    if (f != null) setState(() => photo = f);
  }

  Future<void> _send() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    if (comment.text.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text("Izoh kiriting")));
      return;
    }
    setState(() => _busy = true);
    try {
      await Api.sendAbsence(comment.text.trim(), photo?.path);
      nav.pop();
      messenger.showSnackBar(const SnackBar(content: Text("Adminga yuborildi ✓")));
    } catch (e) {
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Uzrli sabab", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (photo != null)
            Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(photo!.path), height: 180, width: double.infinity, fit: BoxFit.cover)),
              Positioned(
                top: 8, right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => photo = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                    child: const Text("O'chirish", style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ),
            ])
          else
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("Kamera"))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton.icon(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.image), label: const Text("Galereya"))),
            ]),
          const SizedBox(height: 12),
          TextField(controller: comment, maxLines: 3, decoration: const InputDecoration(hintText: "Izoh: sabab (masalan: shifokorda navbatdaman)")),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ? null : _send,
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("Adminga yuborish"),
          ),
        ],
      ),
    );
  }
}
