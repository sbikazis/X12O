import 'package:flutter/material.dart';
import '../app.dart';
import 'game_screen.dart';
import 'rules_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curve, child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(curve),
          child: child,
        ));
      },
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Stack(children: [
      Positioned(top: -110, right: -100, child: _Glow(color: Palette.cyan.withValues(alpha: .13))),
      Positioned(bottom: 80, left: -120, child: _Glow(color: Palette.coral.withValues(alpha: .09))),
      SingleChildScrollView(padding: const EdgeInsets.fromLTRB(22, 18, 22, 30), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 39, height: 39, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(colors: [Palette.cyan, Color(0xFF9AFFF4)]),
              boxShadow: [BoxShadow(color: Palette.cyan.withValues(alpha: .2), blurRadius: 20)],
            ), child: const Center(child: Text('12', style: TextStyle(color: Palette.ink, fontWeight: FontWeight.w900, fontSize: 17)))),
            const SizedBox(width: 11),
            const Text('X12O', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
            const Spacer(),
            IconButton.filledTonal(onPressed: () => _open(context, const ProfileScreen()), icon: const Icon(Icons.person_outline_rounded)),
          ]),
          const SizedBox(height: 37),
          const Text('THINK BIGGER.', style: TextStyle(color: Palette.cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 8),
          Text('A new way\nto play XO.', style: Theme.of(context).textTheme.headlineLarge?.copyWith(height: 1.04)),
          const SizedBox(height: 12),
          const Text('A 12×12 battlefield. Every move matters. Every line changes the game.', style: TextStyle(color: Palette.muted, height: 1.5, fontSize: 14)),
          const SizedBox(height: 26),
          _HeroCard(onTap: () => _open(context, const GameScreen())),
          const SizedBox(height: 27),
          const Text('YOUR ARENA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.6, fontSize: 12)),
          const SizedBox(height: 13),
          Row(children: [
            Expanded(child: _ModeCard(icon: Icons.bolt_rounded, title: 'ARENA', subtitle: 'Abilities & tactics', tint: Palette.coral, onTap: () => _open(context, const GameScreen()))),
            const SizedBox(width: 12),
            Expanded(child: _ModeCard(icon: Icons.people_alt_outlined, title: 'LOCAL DUEL', subtitle: 'Two players, one phone', tint: Palette.cyan, onTap: () => _open(context, const GameScreen()))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ModeCard(icon: Icons.psychology_alt_rounded, title: 'AI CHALLENGE', subtitle: 'Face the X12O brain', tint: Palette.gold, onTap: () => _open(context, const GameScreen(vsAi: true)))),
            const SizedBox(width: 12),
            Expanded(child: _ModeCard(icon: Icons.menu_book_rounded, title: 'HOW TO PLAY', subtitle: 'Master the rules', tint: Colors.white, onTap: () => _open(context, const RulesScreen()))),
          ]),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(
            color: Palette.panel, borderRadius: BorderRadius.circular(19), border: Border.all(color: Palette.line),
          ), child: const Row(children: [
            Icon(Icons.emoji_events_outlined, color: Palette.gold, size: 26),
            SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YOUR JOURNEY STARTS HERE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: .6)),
              SizedBox(height: 4),
              Text('Play your first match to build your record.', style: TextStyle(color: Palette.muted, fontSize: 11)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Palette.muted),
          ])),
          const SizedBox(height: 24),
          const Center(child: Text('BUILT FOR THE NEXT MOVE', style: TextStyle(color: Color(0xFF56627A), fontSize: 9, letterSpacing: 2, fontWeight: FontWeight.w800))),
        ],
      )),
    ])),
  );
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => IgnorePointer(child: Container(width: 230, height: 230, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 45)])));
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(25),
    child: Ink(padding: const EdgeInsets.all(21), decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF20384D), Color(0xFF142235), Palette.panel]),
      border: Border.all(color: Palette.cyan.withValues(alpha: .32)),
    ), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: Palette.cyan.withValues(alpha: .13), borderRadius: BorderRadius.circular(7)), child: const Text('THE CLASSIC', style: TextStyle(color: Palette.cyan, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.3))),
        const Spacer(), const Icon(Icons.north_east_rounded, color: Palette.cyan),
      ]),
      const SizedBox(height: 17),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('12×12', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          Text('THE BIG BOARD', style: TextStyle(color: Palette.muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.7)),
          SizedBox(height: 12),
          Text('Connect three. Claim the point.\nOutscore your rival.', style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
        ])),
        const _MiniBoard(),
      ]),
      const SizedBox(height: 18),
      const Row(children: [Text('START MATCH', style: TextStyle(color: Palette.cyan, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)), SizedBox(width: 8), Icon(Icons.arrow_forward_rounded, color: Palette.cyan, size: 16)]),
    ])),
  ));
}

class _MiniBoard extends StatelessWidget {
  const _MiniBoard();
  @override
  Widget build(BuildContext context) => Container(width: 100, height: 100, padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: .16), borderRadius: BorderRadius.circular(13)),
    child: GridView.builder(physics: const NeverScrollableScrollPhysics(), itemCount: 9,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemBuilder: (_, i) {
        const marks = ['X', '', 'O', '', 'X', '', '', 'O', ''];
        final mark = marks[i];
        return Container(decoration: BoxDecoration(color: Colors.white.withValues(alpha: .055), borderRadius: BorderRadius.circular(5)),
          child: Center(child: Text(mark, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: mark == 'X' ? Palette.cyan : Palette.coral))));
      },
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.tint, required this.onTap});
  final IconData icon; final String title; final String subtitle; final Color tint; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Palette.panel, borderRadius: BorderRadius.circular(18), child: InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(18),
    child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: Palette.line)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: tint, size: 23), const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: .5)),
        const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Palette.muted, fontSize: 10)),
      ]),
    ),
  ));
}
