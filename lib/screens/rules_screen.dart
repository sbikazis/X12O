import 'package:flutter/material.dart';
import '../app.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'THE RULEBOOK',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
      children: const [
        Text(
          'SIMPLE TO LEARN.\nHARD TO MASTER.',
          style: TextStyle(fontSize: 28, height: 1.08, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 12),
        Text(
          'Two players. One huge board. A battle of timing, patterns and foresight.',
          style: TextStyle(color: Palette.muted, height: 1.5),
        ),
        SizedBox(height: 24),
        _Rule('01', 'TAKE YOUR TURN', 'Players alternate placing one symbol on any empty cell of the 12×12 board. X starts.'),
        _Rule('02', 'MAKE A LINE', 'Create three of your symbols in a straight horizontal, vertical or diagonal line. Every distinct group of three earns one point.'),
        _Rule('03', 'THINK BEYOND THREE', 'A run of four contains two overlapping groups of three, so it earns two points. A run of five earns three. Crossing lines score separately.'),
        _Rule('04', 'OWN THE BOARD', 'Classic ends when all 144 cells are filled. The higher score wins. Equal scores mean a draw.'),
        SizedBox(height: 12),
        Text(
          'ARENA // TACTICAL RULES',
          style: TextStyle(color: Palette.coral, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.4),
        ),
        SizedBox(height: 7),
        Text(
          'Arena uses the same scoring system, with tactical abilities and energy. Both players start with 2 energy. Each normal placement restores 1 energy, up to a maximum of 6. Abilities that change the board use your turn.',
          style: TextStyle(color: Palette.muted, height: 1.55),
        ),
        SizedBox(height: 14),
        _Rule('3', 'ERASER', 'Cost: 3 energy. Remove one unshielded opponent mark. Points already scored are banked and are never taken away.'),
        _Rule('2', 'SHIELD', 'Cost: 2 energy. Protect one of your marks from Eraser and Swap.'),
        _Rule('2', 'BLOCK', 'Cost: 2 energy. Permanently close one empty cell. A blocked cell cannot be played.'),
        _Rule('4', 'SWAP', 'Cost: 4 energy. Turn one unshielded opponent mark into your mark.'),
        _Rule('5', 'DOUBLE MOVE', 'Cost: 5 energy. Your opponent takes their next normal turn; then you get two consecutive placements. An opponent cannot overwrite an armed bonus.'),
        _Rule('1', 'SCANNER', 'Cost: 1 energy. Reveal empty cells where your opponent could score immediately. Scanning does not pass your turn.'),
        SizedBox(height: 8),
        Text(
          'Arena ends when every cell is occupied or blocked. The player with the higher score wins. Use energy carefully: every ability has an opportunity cost.',
          style: TextStyle(color: Palette.muted, height: 1.55),
        ),
      ],
    ),
  );
}

class _Rule extends StatelessWidget {
  const _Rule(this.number, this.title, this.body);

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 19),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Palette.cyan.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(color: Palette.cyan, fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: .7)),
              const SizedBox(height: 5),
              Text(body, style: const TextStyle(color: Palette.muted, height: 1.5, fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}
