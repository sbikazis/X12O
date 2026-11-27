import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/game_engine.dart';

void main() {
  group('X12O Classic engine', () {
    test('starts with an empty 12 by 12 board and X first', () {
      final game = GameEngine();
      expect(game.board.length, 12);
      expect(game.board.every((row) => row.length == 12), isTrue);
      expect(game.currentPlayer, Mark.x);
      expect(game.xScore, 0);
      expect(game.oScore, 0);
    });

    test('scores a horizontal triple when its final cell is placed', () {
      final game = GameEngine();
      expect(game.play(0, 0), isTrue); // X
      game.play(1, 0); // O
      game.play(0, 1); // X
      game.play(1, 1); // O
      expect(game.xScore, 0);
      game.play(0, 2); // X completes the triple
      expect(game.xScore, 1);
    });

    test('scores diagonal triples', () {
      final game = GameEngine();
      game.play(0, 0);
      game.play(0, 1);
      game.play(1, 1);
      game.play(0, 2);
      game.play(2, 2);
      expect(game.xScore, 1);
    });

    test('a four-cell run scores two overlapping triples', () {
      final game = GameEngine();
      for (var column = 0; column < 4; column++) {
        game.play(0, column);
        if (column < 3) game.play(2, column);
      }
      expect(game.xScore, 2);
    });

    test('rejects occupied and out-of-range cells without changing turn', () {
      final game = GameEngine();
      expect(game.play(0, 0), isTrue);
      expect(game.play(0, 0), isFalse);
      expect(game.play(-1, 0), isFalse);
      expect(game.currentPlayer, Mark.o);
      expect(game.moveCount, 1);
    });

    test('reset clears the board, scores, and turn', () {
      final game = GameEngine();
      game.play(0, 0);
      game.reset();
      expect(game.moveCount, 0);
      expect(game.xScore, 0);
      expect(game.currentPlayer, Mark.x);
      expect(game.board[0][0], isNull);
    });
  });
}
