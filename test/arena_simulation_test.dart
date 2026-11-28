import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/arena_abilities.dart';
import 'package:x12o/game/arena_engine.dart';
import 'package:x12o/game/game_engine.dart';
import 'package:x12o/game/game_state.dart';

void main() {
  test('seeded Arena matches preserve invariants through ability-heavy play', () {
    for (var seed = 0; seed < 24; seed++) {
      final random = Random(seed);
      var state = ArenaState();
      var steps = 0;

      while (!state.game.finished && steps < 600) {
        final player = state.game.turn;
        final board = state.game.board;
        final empty = <int>[
          for (var i = 0; i < GameEngine.cells; i++)
            if (board[i] == null && !state.blockedCells.contains(i)) i,
        ];
        final own = <int>[
          for (var i = 0; i < GameEngine.cells; i++)
            if (board[i] == player &&
                !state.protectedCells.contains(i) &&
                !state.blockedCells.contains(i))
              i,
        ];
        final opponent = <int>[
          for (var i = 0; i < GameEngine.cells; i++)
            if (board[i] == player.other &&
                !state.protectedCells.contains(i) &&
                !state.blockedCells.contains(i))
              i,
        ];

        final affordable = <ArenaAbility>[
          if (state.energyFor(player) >= ArenaAbility.scanner.cost)
            ArenaAbility.scanner,
          if (state.energyFor(player) >= ArenaAbility.erase.cost &&
              opponent.isNotEmpty)
            ArenaAbility.erase,
          if (state.energyFor(player) >= ArenaAbility.shield.cost &&
              own.isNotEmpty)
            ArenaAbility.shield,
          if (state.energyFor(player) >= ArenaAbility.block.cost &&
              empty.isNotEmpty)
            ArenaAbility.block,
          if (state.energyFor(player) >= ArenaAbility.swap.cost &&
              opponent.isNotEmpty)
            ArenaAbility.swap,
          if (state.energyFor(player) >= ArenaAbility.doubleMove.cost &&
              (state.doubleMoveFor == null ||
                  state.doubleMoveFor == player))
            ArenaAbility.doubleMove,
        ];

        if (affordable.isNotEmpty && random.nextDouble() < .22) {
          final ability = affordable[random.nextInt(affordable.length)];
          final targets = switch (ability) {
            ArenaAbility.erase || ArenaAbility.swap => opponent,
            ArenaAbility.shield => own,
            ArenaAbility.block => empty,
            ArenaAbility.doubleMove || ArenaAbility.scanner => const <int>[],
          };
          state = ArenaEngine.useAbility(
            state,
            ability,
            target: targets.isEmpty
                ? null
                : targets[random.nextInt(targets.length)],
          );
        } else {
          if (empty.isEmpty) {
            fail('No playable cells remain but the match is not finished.');
          }
          state = ArenaEngine.play(
            state,
            empty[random.nextInt(empty.length)],
          );
        }

        expect(state.xEnergy, inInclusiveRange(0, ArenaRules.maxEnergy));
        expect(state.oEnergy, inInclusiveRange(0, ArenaRules.maxEnergy));
        expect(
          state.game.moves,
          state.game.board.where((mark) => mark != null).length,
        );
        expect(state.game.xScore, greaterThanOrEqualTo(0));
        expect(state.game.oScore, greaterThanOrEqualTo(0));
        steps++;
      }

      expect(
        state.game.finished,
        isTrue,
        reason: 'Seed $seed did not finish within $steps actions.',
      );
    }
  });
}
