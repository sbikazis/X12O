import 'package:flutter/material.dart';

import 'game/game_engine.dart';

void main() => runApp(const X12OApp());

class X12OApp extends StatelessWidget {
  const X12OApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF090D18);
    return MaterialApp(
      title: 'X12O',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B7CFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF141B2B),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameEngine game = GameEngine();

  void _play(int row, int column) {
    if (!game.play(row, column)) return;
    setState(() {});
  }

  void _reset() => setState(() => game = GameEngine());

  @override
  Widget build(BuildContext context) {
    final finished = game.isFinished;
    final winner = game.xScore == game.oScore
        ? 'DRAW'
        : game.xScore > game.oScore
            ? 'X WINS'
            : 'O WINS';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, compact ? 8 : 18, 16, 12),
              child: Column(
                children: [
                  _Header(onReset: _reset),
                  SizedBox(height: compact ? 12 : 22),
                  Row(
                    children: [
                      Expanded(
                        child: _ScoreCard(
                          label: 'PLAYER ONE',
                          mark: 'X',
                          score: game.xScore,
                          active: !finished && game.currentPlayer == Mark.x,
                          color: const Color(0xFF9C8CFF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ScoreCard(
                          label: 'PLAYER TWO',
                          mark: 'O',
                          score: game.oScore,
                          active: !finished && game.currentPlayer == Mark.o,
                          color: const Color(0xFF4DE0C1),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  Row(
                    children: [
                      Text(
                        finished ? winner : '${game.currentPlayer.name.toUpperCase()}  TURN',
                        style: const TextStyle(
                          fontSize: 12,
                          letterSpacing: 2.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${game.moveCount} / 144 MOVES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.48),
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _Board(
                          game: game,
                          onTap: _play,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141B2B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Text(
                      finished
                          ? 'Match complete · $winner'
                          : 'Complete lines of 3 in any direction to score. The highest score wins.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('NEW MATCH'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8172F5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            gradient: const LinearGradient(
              colors: [Color(0xFF9C8CFF), Color(0xFF4DE0C1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              '12',
              style: TextStyle(
                color: Color(0xFF09111D),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'X12O',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.8,
              ),
            ),
            Text(
              'THINK BIG. PLAY SMART.',
              style: TextStyle(
                color: Color(0xFF8290A8),
                fontSize: 9,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Restart match',
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF141B2B),
            foregroundColor: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.mark,
    required this.score,
    required this.active,
    required this.color,
  });

  final String label;
  final String mark;
  final int score;
  final bool active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.12) : const Color(0xFF141B2B),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: active ? color.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.06),
          width: active ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            mark,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF8290A8),
                    fontSize: 9,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (active)
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 8)],
              ),
            ),
        ],
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.game, required this.onTap});

  final GameEngine game;
  final void Function(int row, int column) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFF141B2B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF28344B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 12,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: game.boardSize * game.boardSize,
        itemBuilder: (context, index) {
          final row = index ~/ game.boardSize;
          final column = index % game.boardSize;
          final mark = game.board[row][column];
          final color = mark == Mark.x
              ? const Color(0xFF9C8CFF)
              : const Color(0xFF4DE0C1);

          return Material(
            color: const Color(0xFF202A3D),
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: mark == null ? () => onTap(row, column) : null,
              child: Center(
                child: mark == null
                    ? const SizedBox.shrink()
                    : FittedBox(
                        child: Text(
                          mark == Mark.x ? '×' : '○',
                          style: TextStyle(
                            color: color,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
