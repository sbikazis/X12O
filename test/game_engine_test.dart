import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/game_engine.dart';
import 'package:x12o/game/game_state.dart';

void main() {
  group('Scoring rules', () {
    test('counts a horizontal triple', () {
      final board = List<Mark?>.filled(144, null);
      board[0] = Mark.x; board[1] = Mark.x; board[2] = Mark.x;
      expect(GameEngine.pointsForMove(board, 2, Mark.x), 1);
    });
    test('scores each newly completed window as a run grows to four', () {
      var state = GameState();
      state = GameEngine.play(state, 0);   // X
      state = GameEngine.play(state, 24);  // O
      state = GameEngine.play(state, 1);   // X
      state = GameEngine.play(state, 25);  // O
      state = GameEngine.play(state, 2);   // X completes first window
      expect(state.xScore, 1);
      state = GameEngine.play(state, 26);  // O
      state = GameEngine.play(state, 3);   // X completes the second window
      expect(state.xScore, 2);
    });
    test('counts diagonal triples', () {
      final board = List<Mark?>.filled(144, null);
      board[0] = Mark.x; board[13] = Mark.x; board[26] = Mark.x;
      expect(GameEngine.pointsForMove(board, 26, Mark.x), 1);
    });
    test('counts crossed lines separately', () {
      final board = List<Mark?>.filled(144, null);
      const center = 65;
      board[center - 1] = Mark.x; board[center + 1] = Mark.x;
      board[center - 12] = Mark.x; board[center + 12] = Mark.x;
      expect(GameEngine.pointsForMove(board, center, Mark.x), 2);
    });
    test('does not count mixed marks', () {
      final board = List<Mark?>.filled(144, null);
      board[0] = Mark.x; board[1] = Mark.o; board[2] = Mark.x;
      expect(GameEngine.pointsForMove(board, 2, Mark.x), 0);
    });
  });
  group('Match flow', () {
    test('alternates turns', () {
      final one = GameEngine.play(GameState(), 0);
      expect(one.turn, Mark.o);
      final two = GameEngine.play(one, 1);
      expect(two.turn, Mark.x);
      expect(two.moves, 2);
    });
    test('rejects occupied cells', () {
      final one = GameEngine.play(GameState(), 0);
      expect(() => GameEngine.play(one, 0), throwsStateError);
    });
    test('ends after 144 moves', () {
      var state = GameState();
      for (var i = 0; i < 144; i++) { state = GameEngine.play(state, i); }
      expect(state.finished, isTrue);
      expect(state.moves, 144);
    });
  });
}
