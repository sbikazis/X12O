import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/ai_opponent.dart';
import 'package:x12o/game/arena_abilities.dart';
import 'package:x12o/game/game_engine.dart';
import 'package:x12o/game/game_state.dart';

void main() {
  group('Offline AI', () {
    test('chooses a legal opening move', () {
      final move = AiOpponent.chooseMove(GameState());
      expect(move, inInclusiveRange(0, 143));
    });
    test('takes an immediate scoring opportunity', () {
      final board = List<Mark?>.filled(144, null);
      board[60] = Mark.o; board[61] = Mark.o;
      final state = GameState(board: board, turn: Mark.o, moves: 2);
      expect(AiOpponent.chooseMove(state, difficulty: AiDifficulty.hard), 62);
    });
    test('hard AI blocks an immediate opponent scoring move', () {
      final board = List<Mark?>.filled(144, null)
        ..[59] = Mark.o
        ..[60] = Mark.x
        ..[61] = Mark.x;
      final state = GameState(board: board, turn: Mark.o, moves: 3);
      expect(AiOpponent.chooseMove(state, difficulty: AiDifficulty.hard), 62);
    });
    test('never chooses an occupied cell', () {
      final state = GameEngine.play(GameState(), 65);
      final move = AiOpponent.chooseMove(state);
      expect(state.board[move], isNull);
    });
  });
  group('Arena resource rules', () {
    test('enforces ability costs and caps energy', () {
      expect(ArenaRules.canAfford(2, ArenaAbility.erase), isFalse);
      expect(ArenaRules.spend(4, ArenaAbility.erase), 1);
      expect(ArenaRules.afterNormalMove(6), 6);
      expect(() => ArenaRules.spend(1, ArenaAbility.shield), throwsStateError);
    });
    test('only permits erasing an opponent mark', () {
      final board = List<Mark?>.filled(144, null)..[20] = Mark.o;
      expect(() => ArenaRules.validateTarget(board, 20, currentPlayer: Mark.x, ability: ArenaAbility.erase), returnsNormally);
      expect(() => ArenaRules.validateTarget(board, 20, currentPlayer: Mark.o, ability: ArenaAbility.erase), throwsStateError);
    });
    test('shield and block enforce valid targets', () {
      final board = List<Mark?>.filled(144, null)..[10] = Mark.x;
      expect(() => ArenaRules.validateTarget(board, 10, currentPlayer: Mark.x, ability: ArenaAbility.shield), returnsNormally);
      expect(() => ArenaRules.validateTarget(board, 10, currentPlayer: Mark.x, ability: ArenaAbility.block), throwsStateError);
    });
  });
}
