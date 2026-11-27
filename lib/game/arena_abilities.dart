import 'game_engine.dart';
import 'game_state.dart';

enum ArenaAbility { erase, shield, block, swap, doubleMove, scanner }

extension ArenaAbilityInfo on ArenaAbility {
  int get cost => switch (this) {
    ArenaAbility.erase => 3,
    ArenaAbility.shield => 2,
    ArenaAbility.block => 2,
    ArenaAbility.swap => 4,
    ArenaAbility.doubleMove => 5,
    ArenaAbility.scanner => 1,
  };
  String get title => switch (this) {
    ArenaAbility.erase => 'Eraser',
    ArenaAbility.shield => 'Shield',
    ArenaAbility.block => 'Block',
    ArenaAbility.swap => 'Swap',
    ArenaAbility.doubleMove => 'Double move',
    ArenaAbility.scanner => 'Scanner',
  };
}

/// Rules and validation for Arena resources. The board is never mutated here:
/// callers must first validate, then apply an action atomically in a match.
abstract final class ArenaRules {
  static const maxEnergy = 6;
  static const startingEnergy = 2;
  static const energyPerNormalMove = 1;
  static bool canAfford(int energy, ArenaAbility ability) => energy >= ability.cost;
  static int afterNormalMove(int energy) => (energy + energyPerNormalMove).clamp(0, maxEnergy);
  static int spend(int energy, ArenaAbility ability) {
    if (energy < 0 || energy > maxEnergy) throw RangeError('Energy must be between 0 and $maxEnergy.');
    if (!canAfford(energy, ability)) throw StateError('Not enough energy for ${ability.title}.');
    return energy - ability.cost;
  }
  static void validateTarget(List<Mark?> board, int index, {required Mark currentPlayer, required ArenaAbility ability, Set<int> protectedCells = const {}, Set<int> blockedCells = const {}}) {
    if (board.length != GameEngine.cells || index < 0 || index >= GameEngine.cells) throw RangeError('Invalid target cell.');
    if (protectedCells.contains(index) || blockedCells.contains(index)) throw StateError('This cell is protected or blocked.');
    switch (ability) {
      case ArenaAbility.erase:
      case ArenaAbility.swap:
        if (board[index] != currentPlayer.other) throw StateError('Choose an unprotected opponent mark.');
      case ArenaAbility.shield:
        if (board[index] != currentPlayer) throw StateError('Shield one of your own marks.');
      case ArenaAbility.block:
        if (board[index] != null) throw StateError('Only an empty cell can be blocked.');
      case ArenaAbility.doubleMove:
      case ArenaAbility.scanner:
        break;
    }
  }
}
