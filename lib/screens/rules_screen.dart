import 'package:flutter/material.dart';
import '../app.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('THE RULEBOOK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
    body: ListView(padding: const EdgeInsets.fromLTRB(22, 10, 22, 30), children: const [
      Text('SIMPLE TO LEARN.\nHARD TO MASTER.', style: TextStyle(fontSize: 28, height: 1.08, fontWeight: FontWeight.w900)),
      SizedBox(height: 12),
      Text('Two players. One huge board. A battle of timing, patterns and foresight.', style: TextStyle(color: Palette.muted, height: 1.5)),
      SizedBox(height: 24),
      _Rule('01', 'TAKE YOUR TURN', 'Players alternate placing one symbol on any empty cell of the 12×12 board. X starts.'),
      _Rule('02', 'MAKE A LINE', 'Create three of your symbols in a straight horizontal, vertical or diagonal line. Every distinct group of three earns one point.'),
      _Rule('03', 'THINK BEYOND THREE', 'A run of four contains two overlapping groups of three, so it earns two points. A run of five earns three.'),
      _Rule('04', 'OWN THE BOARD', 'The match ends when all 144 cells are filled. The higher score wins. Equal scores mean a draw.'),
      SizedBox(height: 12),
      Text('ARENA MODE', style: TextStyle(color: Palette.cyan, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.4)),
      SizedBox(height: 7),
      Text('Arena will introduce tactical abilities with clear costs and limits. It will be balanced separately from Classic so competitive play stays fair.', style: TextStyle(color: Palette.muted, height: 1.55)),
    ]),
  );
}

class _Rule extends StatelessWidget {
  const _Rule(this.number, this.title, this.body);
  final String number; final String title; final String body;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 19), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(width: 35, height: 35, decoration: BoxDecoration(color: Palette.cyan.withValues(alpha: .1), borderRadius: BorderRadius.circular(11)),
      child: Center(child: Text(number, style: const TextStyle(color: Palette.cyan, fontWeight: FontWeight.w900, fontSize: 11)))),
    const SizedBox(width: 13),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: .7)),
      const SizedBox(height: 5), Text(body, style: const TextStyle(color: Palette.muted, height: 1.5, fontSize: 12)),
    ])),
  ]));
}
