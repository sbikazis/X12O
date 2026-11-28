import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/arena_engine.dart';
import 'package:x12o/game/arena_abilities.dart';
import 'package:x12o/game/game_state.dart';

void main() {
  group('Arena actions', () {
    test('normal move restores one energy', () {
      final state = ArenaEngine.play(ArenaState(), 0);
      expect(state.xEnergy, 3);
      expect(state.game.turn, Mark.o);
    });

    test('erase removes opponent mark and consumes turn', () {
      var state = ArenaState();
      state = ArenaEngine.play(state, 0);
      state = ArenaEngine.play(state, 1);
      state = ArenaEngine.play(state, 2);
      state = ArenaEngine.useAbility(state, ArenaAbility.erase, target: 0);
      expect(state.game.board[0], isNull);
      expect(state.oEnergy, 0);
      expect(state.game.turn, Mark.x);
      expect(state.game.moves, 2);
    });

    test('erasing a mark never removes points already earned', () {
      final board = List<Mark?>.filled(144, null)
        ..[0] = Mark.x
        ..[1] = Mark.x
        ..[2] = Mark.x;
      final state = ArenaState(
        game: GameState(
          board: board,
          turn: Mark.o,
          xScore: 1,
          moves: 3,
        ),
        oEnergy: 3,
      );
      final erased = ArenaEngine.useAbility(
        state,
        ArenaAbility.erase,
        target: 0,
      );
      expect(erased.game.board[0], isNull);
      expect(erased.game.xScore, 1);
    });

    test('shield blocks erase', () {
      var state = ArenaState();
      state = ArenaEngine.play(state, 0);
      state = ArenaEngine.play(state, 1);
      state = ArenaEngine.play(state, 2);
      state = ArenaEngine.useAbility(state, ArenaAbility.shield, target: 1);
      expect(
        () => ArenaEngine.useAbility(state, ArenaAbility.erase, target: 1),
        throwsStateError,
      );
    });

    test('block prevents placement', () {
      final state = ArenaEngine.useAbility(
        ArenaState(),
        ArenaAbility.block,
        target: 70,
      );
      expect(() => ArenaEngine.play(state, 70), throwsStateError);
    });

    test('swap converts opponent mark', () {
      var state = ArenaState(oEnergy: 4);
      state = ArenaEngine.play(state, 10);
      state = ArenaEngine.useAbility(state, ArenaAbility.swap, target: 10);
      expect(state.game.board[10], Mark.o);
    });

    test('double move gives same player two consecutive placements', () {
      var state = ArenaEngine.useAbility(
        ArenaState(xEnergy: 5),
        ArenaAbility.doubleMove,
      );
      expect(state.game.turn, Mark.o);
      state = ArenaEngine.play(state, 0);
      expect(state.game.turn, Mark.x);
      state = ArenaEngine.play(state, 1);
      expect(state.game.turn, Mark.x);
      state = ArenaEngine.play(state, 2);
      expect(state.game.turn, Mark.o);
    });

    test('scanner reveals opponent threats without giving away the turn', () {
      final board = List<Mark?>.filled(144, null)
        ..[60] = Mark.o
        ..[61] = Mark.o;
      final initial = ArenaState(
        game: GameState(board: board, turn: Mark.x, moves: 2),
      );
      final scanned = ArenaEngine.useAbility(initial, ArenaAbility.scanner);
      expect(scanned.scannerHints, contains(62));
      expect(scanned.game.turn, Mark.x);
      expect(scanned.game.moves, 2);
      expect(scanned.xEnergy, 1);
      expect(scanned.oEnergy, 2);
    });

    test('scanner consumes the next placement energy regeneration', () {
      var state = ArenaEngine.useAbility(ArenaState(), ArenaAbility.scanner);
      expect(state.xEnergy, 1);
      state = ArenaEngine.play(state, 65);
      expect(state.xEnergy, 1);
      expect(state.scannerPenaltyFor, isNull);
    });

    test('scanner penalty follows its owner across the opponent turn', () {
      var state = ArenaEngine.useAbility(
        ArenaState(xEnergy: 4, oEnergy: 2),
        ArenaAbility.scanner,
      );
      state = ArenaEngine.useAbility(state, ArenaAbility.shield, target: 65);
      expect(state.game.turn, Mark.o);
      state = ArenaEngine.play(state, 66);
      expect(state.oEnergy, 3);
      expect(state.scannerPenaltyFor, Mark.x);
      state = ArenaEngine.play(state, 67);
      expect(state.xEnergy, 3);
      expect(state.scannerPenaltyFor, isNull);
    });

    test('scanner ignores blocked cells', () {
      final board = List<Mark?>.filled(144, null)
        ..[60] = Mark.o
        ..[61] = Mark.o;
      final initial = ArenaState(
        game: GameState(board: board, turn: Mark.x, moves: 2),
        blockedCells: {62},
      );
      final scanned = ArenaEngine.useAbility(initial, ArenaAbility.scanner);
      expect(scanned.scannerHints, isNot(contains(62)));
    });

    test('opponent cannot overwrite an armed double move', () {
      var state = ArenaEngine.useAbility(
        ArenaState(xEnergy: 5, oEnergy: 5),
        ArenaAbility.doubleMove,
      );
      expect(
        () => ArenaEngine.useAbility(state, ArenaAbility.doubleMove),
        throwsStateError,
      );
      expect(state.doubleMoveFor, Mark.x);
    });

    test('blocking the final empty cell ends the Arena match', () {
      final board = List<Mark?>.filled(144, Mark.x)..[143] = null;
      final state = ArenaState(
        game: GameState(board: board, turn: Mark.o, moves: 143),
        oEnergy: 2,
      );
      final ended = ArenaEngine.useAbility(
        state,
        ArenaAbility.block,
        target: 143,
      );
      expect(ended.game.finished, isTrue);
    });

    test('rejects unaffordable abilities without changing the source state', () {
      final state = ArenaState();
      expect(
        () => ArenaEngine.useAbility(state, ArenaAbility.erase, target: 0),
        throwsStateError,
      );
      expect(state.xEnergy, 2);
      expect(state.game.turn, Mark.x);
    });

    test('invalid targets do not spend energy or change the source state', () {
      final state = ArenaState(
        game: GameState(
          board: List<Mark?>.filled(144, null)..[0] = Mark.o,
          turn: Mark.o,
          moves: 1,
        ),
        oEnergy: 4,
      );
      expect(
        () => ArenaEngine.useAbility(state, ArenaAbility.swap, target: 0),
        throwsStateError,
      );
      expect(state.oEnergy, 4);
      expect(state.game.turn, Mark.o);
    });
  });
}
