import 'package:flutter/material.dart';
import '../app.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PLAYER PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
    body: ListView(padding: const EdgeInsets.all(22), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF20384C), Palette.panel], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: Palette.cyan.withValues(alpha: .25)),
      ), child: const Column(children: [
        CircleAvatar(radius: 34, backgroundColor: Color(0xFF254354), child: Icon(Icons.person_rounded, size: 34, color: Palette.cyan)),
        SizedBox(height: 13),
        Text('ROOKIE', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        SizedBox(height: 4), Text('Your legend begins with one move.', style: TextStyle(color: Palette.muted, fontSize: 11)),
        SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _Stat('—', 'MATCHES'), _Stat('—', 'WINS'), _Stat('—', 'RATING'),
        ]),
      ])),
      const SizedBox(height: 23),
      const Text('YOUR PROGRESS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.3, fontSize: 11)),
      const SizedBox(height: 10),
      const _Progress(Icons.local_fire_department_rounded, 'Daily streak', 'Not started'),
      const _Progress(Icons.workspace_premium_rounded, 'Achievements', 'Coming soon'),
      const _Progress(Icons.history_rounded, 'Match history', 'Coming soon'),
      const SizedBox(height: 17),
      const Text('Progress tracking will be activated with local profiles and match history. Online rankings will arrive with the multiplayer service.', style: TextStyle(color: Palette.muted, fontSize: 12, height: 1.55)),
    ]),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value; final String label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
    const SizedBox(height: 3),
    Text(label, style: const TextStyle(color: Palette.muted, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .9)),
  ]);
}

class _Progress extends StatelessWidget {
  const _Progress(this.icon, this.title, this.value);
  final IconData icon; final String title; final String value;
  @override
  Widget build(BuildContext context) => ListTile(contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Palette.gold),
    title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
    trailing: Text(value, style: const TextStyle(color: Palette.muted, fontSize: 10)),
  );
}
