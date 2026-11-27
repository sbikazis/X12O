import 'dart:math';
import 'game_engine.dart';
import 'game_state.dart';

enum AiDifficulty { easy, medium, hard }

/// Deterministic, offline opponent. It evaluates immediate scoring windows,
/// threats and board control; no network or paid service is required.
abstract final class AiOpponent {
  static int chooseMove(GameState state, {AiDifficulty difficulty = AiDifficulty.medium, int seed = 12}) {
    if (state.finished) throw StateError('Cannot choose a move after the match ends.');
    final legal = <int>[for (var i = 0; i < GameEngine.cells; i++) if (state.board[i] == null) i];
    if (legal.isEmpty) throw StateError('No legal moves remain.');
    if (state.moves == 0) return 5 * GameEngine.size + 5;
    final candidates = legal.where((i) => _nearExisting(state.board, i)).toList();
    final pool = candidates.isEmpty ? legal : candidates;
    if (difficulty == AiDifficulty.easy) {
      pool.sort((a, b) => _centerDistance(a).compareTo(_centerDistance(b)));
      final count = max(1, min(pool.length, 8));
      return pool[Random(seed + state.moves).nextInt(count)];
    }
    var best = pool.first;
    var bestScore = -double.infinity;
    for (final index in pool) {
      final score = _evaluate(state.board, index, state.turn);
      if (score > bestScore || (score == bestScore && _centerDistance(index) < _centerDistance(best))) {
        best = index;
        bestScore = score;
      }
    }
    if (difficulty == AiDifficulty.medium) {
      final tied = pool.where((i) => _evaluate(state.board, i, state.turn) >= bestScore - 1.5).toList();
      return tied[Random(seed + state.moves).nextInt(tied.length)];
    }
    return best;
  }

  static double _evaluate(List<Mark?> board, int index, Mark mark) {
    final own = _windowPotential(board, index, mark);
    final block = _windowPotential(board, index, mark.other);
    final copy = List<Mark?>.of(board)..[index] = mark;
    final immediate = GameEngine.pointsForMove(copy, index, mark);
    return immediate * 1000 + own * 1.0 + block * .92 - _centerDistance(index) * .015;
  }

  static double _windowPotential(List<Mark?> board, int index, Mark mark) {
    const directions = <(int, int)>[(0, 1), (1, 0), (1, 1), (1, -1)];
    final row = index ~/ GameEngine.size, col = index % GameEngine.size;
    var value = 0.0;
    for (final (dr, dc) in directions) {
      for (var start = -2; start <= 0; start++) {
        final sr = row + dr * start, sc = col + dc * start;
        final er = sr + dr * 2, ec = sc + dc * 2;
        if (sr < 0 || sr >= 12 || sc < 0 || sc >= 12 || er < 0 || er >= 12 || ec < 0 || ec >= 12) continue;
        var mine = 0, empty = 0, blocked = false;
        for (var step = 0; step < 3; step++) {
          final cell = board[(sr + dr * step) * 12 + sc + dc * step];
          if (cell == mark) { mine++; } else if (cell == null || (sr + dr * step) * 12 + sc + dc * step == index) { empty++; } else { blocked = true; }
        }
        if (!blocked && empty > 0) value += mine == 2 ? 24 : mine == 1 ? 3 : 0.4;
      }
    }
    return value;
  }

  static bool _nearExisting(List<Mark?> board, int index) {
    final row = index ~/ 12, col = index % 12;
    for (var r = max(0, row - 2); r <= min(11, row + 2); r++) {
      for (var c = max(0, col - 2); c <= min(11, col + 2); c++) {
        if (board[r * 12 + c] != null) return true;
      }
    }
    return false;
  }

  static int _centerDistance(int index) {
    final row = index ~/ 12, col = index % 12;
    return (row * 2 - 11).abs() + (col * 2 - 11).abs();
  }
}
