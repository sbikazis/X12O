import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app.dart';
import '../game/ai_opponent.dart';
import '../game/game_engine.dart';
import '../game/game_state.dart';
import '../game/match_repository.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.vsAi = false});
  final bool vsAi;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState state = GameState();
  bool aiThinking = false;
  bool _recorded = false;
  int lastMovePoints = 0;
  AiDifficulty difficulty = AiDifficulty.medium;

  void _move(int index) {
    if (state.finished || state.board[index] != null || aiThinking || (widget.vsAi && state.turn == Mark.o)) return;
    final movePoints = GameEngine.pointsForMove(
      List<Mark?>.of(state.board)..[index] = state.turn,
      index,
      state.turn,
    );
    HapticFeedback.selectionClick();
    if (movePoints > 0) HapticFeedback.mediumImpact();
    setState(() {
      state = GameEngine.play(state, index);
      lastMovePoints = movePoints;
    });
    if (state.finished) {
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (mounted) _result();
      });
    } else if (widget.vsAi && state.turn == Mark.o) {
      _scheduleAiMove();
    }
  }

  void _scheduleAiMove() {
    setState(() => aiThinking = true);
    Future<void>.delayed(const Duration(milliseconds: 520), () {
      if (!mounted || state.finished || state.turn != Mark.o) return;
      final index = AiOpponent.chooseMove(state, difficulty: difficulty);
      final movePoints = GameEngine.pointsForMove(
        List<Mark?>.of(state.board)..[index] = state.turn,
        index,
        state.turn,
      );
      HapticFeedback.selectionClick();
      if (movePoints > 0) HapticFeedback.mediumImpact();
      setState(() {
        state = GameEngine.play(state, index);
        lastMovePoints = movePoints;
        aiThinking = false;
      });
      if (state.finished) {
        Future<void>.delayed(const Duration(milliseconds: 420), () { if (mounted) _result(); });
      }
    });
  }

  Future<void> _result() async {
    if (!_recorded) {
      _recorded = true;
      await MatchRepository.record(mode: widget.vsAi ? 'AI / ' + difficulty.name : 'Classic local', xScore: state.xScore, oScore: state.oScore, moves: state.moves);
    }
    if (!mounted) return;
    final title = state.winner == null ? 'A PERFECT DRAW' : 'PLAYER ' + state.winner!.symbol + ' WINS';
    showDialog<void>(context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog(
      backgroundColor: Palette.panel,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Icon(Icons.emoji_events_rounded, color: Palette.gold, size: 42),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 10),
        Text('X  ' + state.xScore.toString() + '   —   ' + state.oScore.toString() + '  O', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7),
        const Text('The board is full. Every line counted.', textAlign: TextAlign.center, style: TextStyle(color: Palette.muted, fontSize: 12)),
      ]),
      actions: [
        FilledButton(onPressed: () { Navigator.pop(dialogContext); setState(() { state = GameState(); _recorded = false; aiThinking = false; lastMovePoints = 0; }); }, child: const Text('PLAY AGAIN')),
        TextButton(onPressed: () { Navigator.pop(dialogContext); Navigator.pop(context); }, child: const Text('HOME')),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final xTurn = state.turn == Mark.x;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
        title: Text(widget.vsAi ? 'AI CHALLENGE' : 'CLASSIC MATCH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.7)),
        actions: [
          if (widget.vsAi) PopupMenuButton<AiDifficulty>(
            tooltip: 'AI difficulty',
            icon: const Icon(Icons.tune_rounded),
            onSelected: (value) => setState(() { difficulty = value; state = GameState(); _recorded = false; aiThinking = false; lastMovePoints = 0; }),
            itemBuilder: (_) => AiDifficulty.values.map((d) => PopupMenuItem(value: d, child: Text(d.name.toUpperCase() + (d == difficulty ? '  ✓' : '')))).toList(),
          ),
          IconButton(onPressed: () => setState(() { state = GameState(); _recorded = false; aiThinking = false; lastMovePoints = 0; }), icon: const Icon(Icons.refresh_rounded), tooltip: 'Restart'),
        ],
      ),
      body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(13, 4, 13, 12), child: Column(children: [
        Row(children: [
          Expanded(child: _Score(mark: Mark.x, score: state.xScore, active: xTurn && !state.finished)),
          const SizedBox(width: 9),
          Expanded(child: _Score(mark: Mark.o, score: state.oScore, active: !xTurn && !state.finished, isAi: widget.vsAi)),
        ]),
        const SizedBox(height: 12),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
          decoration: BoxDecoration(color: Palette.panel, borderRadius: BorderRadius.circular(12), border: Border.all(color: Palette.line)),
          child: Row(children: [
            Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: xTurn ? Palette.cyan : Palette.coral)),
            const SizedBox(width: 9),
            Expanded(child: Text(state.finished ? 'MATCH COMPLETE' : 'PLAYER ' + state.turn.symbol + ' — YOUR MOVE', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
            Text(widget.vsAi ? difficulty.name.toUpperCase() + ' · ' + state.moves.toString() + '/144' : state.moves.toString() + '/144 MOVES', style: const TextStyle(color: Palette.muted, fontSize: 9, fontWeight: FontWeight.w800)),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(child: Center(child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screen.width - 26, maxHeight: screen.height * .64),
          child: AspectRatio(aspectRatio: 1, child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Palette.panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: Palette.line),
              boxShadow: [BoxShadow(color: Palette.cyan.withValues(alpha: .05), blurRadius: 30, spreadRadius: 2)]),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: GameEngine.cells,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 12, crossAxisSpacing: 3, mainAxisSpacing: 3),
              itemBuilder: (_, index) => _Cell(mark: state.board[index], last: state.lastMove == index, scored: state.lastMove == index && lastMovePoints > 0, onTap: () => _move(index)),
            ),
          )),
        ))),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Palette.gold, size: 17),
          const SizedBox(width: 7),
          const Expanded(child: Text('Every straight three-cell line scores one point.', style: TextStyle(color: Palette.muted, fontSize: 10))),
          TextButton(onPressed: () => showModalBottomSheet<void>(context: context, backgroundColor: Palette.panel, showDragHandle: true,
            builder: (_) => const Padding(padding: EdgeInsets.fromLTRB(22, 8, 22, 28), child: Text(
              'Three matching symbols in a straight horizontal, vertical or diagonal line score one point. Every distinct three-cell window counts: a run of four scores two points. Crossed lines count separately.',
              style: TextStyle(color: Palette.muted, height: 1.6),
            ))), child: const Text('SCORING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900))),
        ]),
      ]))),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({required this.mark, required this.score, required this.active, this.isAi = false});
  final Mark mark; final int score; final bool active; final bool isAi;
  @override
  Widget build(BuildContext context) {
    final tint = mark == Mark.x ? Palette.cyan : Palette.coral;
    return AnimatedContainer(duration: const Duration(milliseconds: 220), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(color: active ? tint.withValues(alpha: .1) : Palette.panel, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: active ? tint.withValues(alpha: .65) : Palette.line, width: active ? 1.4 : 1)),
      child: Row(children: [
        Text(mark.symbol, style: TextStyle(color: tint, fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isAi && mark == Mark.o ? 'X12O AI' : 'PLAYER ' + mark.symbol, style: const TextStyle(color: Palette.muted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7)),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              score.toString(),
              key: ValueKey<int>(score),
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.1),
            ),
          ),
        ])),
        if (active) Icon(Icons.circle, size: 7, color: tint),
      ]),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.mark, required this.last, required this.scored, required this.onTap});
  final Mark? mark; final bool last; final bool scored; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final tint = mark == Mark.x ? Palette.cyan : Palette.coral;
    return GestureDetector(onTap: mark == null ? onTap : null, child: AnimatedContainer(
      duration: const Duration(milliseconds: 170), curve: Curves.easeOut,
      decoration: BoxDecoration(color: mark == null ? Palette.panel2 : tint.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: last ? tint.withValues(alpha: .8) : Colors.white.withValues(alpha: .035), width: last ? 1.1 : .5),
        boxShadow: last ? [BoxShadow(color: tint.withValues(alpha: .18), blurRadius: 8)] : null),
      child: Center(child: AnimatedScale(scale: mark == null ? .6 : 1, duration: const Duration(milliseconds: 190), curve: Curves.elasticOut,
        child: mark == null ? const SizedBox.shrink() : FittedBox(child: Text(mark.symbol, style: TextStyle(color: tint, fontSize: 20, fontWeight: FontWeight.w900, height: 1))))),
    ));
  }
}
