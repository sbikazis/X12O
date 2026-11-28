import 'game_engine.dart';
import 'arena_abilities.dart';
import 'game_state.dart';

class ArenaState {
  ArenaState({
    GameState? game,
    this.xEnergy = 2,
    this.oEnergy = 2,
    Set<int> protectedCells = const {},
    Set<int> blockedCells = const {},
    this.doubleMoveFor,
    this.scannerPenaltyFor,
    Set<int> scannerHints = const {},
  })  : game = game ?? GameState(),
        protectedCells = Set.unmodifiable(protectedCells),
        blockedCells = Set.unmodifiable(blockedCells),
        scannerHints = Set.unmodifiable(scannerHints);

  final GameState game;
  final int xEnergy;
  final int oEnergy;
  final Set<int> protectedCells;
  final Set<int> blockedCells;
  final Mark? doubleMoveFor;
  final Mark? scannerPenaltyFor;
  final Set<int> scannerHints;

  int energyFor(Mark mark) => mark == Mark.x ? xEnergy : oEnergy;
}

abstract final class ArenaEngine {
  static const maxEnergy = ArenaRules.maxEnergy;

  static int _regenerate(int energy) =>
      (energy + ArenaRules.energyPerNormalMove).clamp(0, maxEnergy).toInt();

  static bool _boardIsClosed(List<Mark?> board, Set<int> blocked) {
    for (var i = 0; i < GameEngine.cells; i++) {
      if (board[i] == null && !blocked.contains(i)) return false;
    }
    return true;
  }

  static ArenaState play(ArenaState state, int index) {
    final game = state.game;
    if (game.finished) throw StateError('Match has finished.');
    if (index < 0 || index >= GameEngine.cells) throw RangeError('Invalid cell.');
    if (game.board[index] != null || state.blockedCells.contains(index)) {
      throw StateError('Cell is unavailable.');
    }

    final player = game.turn;
    final played = GameEngine.play(game, index);
    final earnsBonusTurn = state.doubleMoveFor == player && !played.finished;
    final scannerPenaltyApplies = state.scannerPenaltyFor == player;
    final finished = played.finished ||
        _boardIsClosed(played.board, state.blockedCells);

    final nextGame = GameState(
      board: played.board,
      turn: earnsBonusTurn ? player : played.turn,
      xScore: played.xScore,
      oScore: played.oScore,
      moves: played.moves,
      finished: finished,
      lastMove: index,
    );

    return ArenaState(
      game: nextGame,
      xEnergy: player == Mark.x && !scannerPenaltyApplies ? _regenerate(state.xEnergy) : state.xEnergy,
      oEnergy: player == Mark.o && !scannerPenaltyApplies ? _regenerate(state.oEnergy) : state.oEnergy,
      protectedCells: state.protectedCells,
      blockedCells: state.blockedCells,
      // The bonus is consumed by the first of the two consecutive placements.
      doubleMoveFor: earnsBonusTurn ? null : (finished ? null : state.doubleMoveFor),
      scannerPenaltyFor: scannerPenaltyApplies ? null : state.scannerPenaltyFor,
    );
  }

  static ArenaState useAbility(
    ArenaState state,
    ArenaAbility ability, {
    int? target,
  }) {
    final game = state.game;
    if (game.finished) throw StateError('Match has finished.');

    final player = game.turn;
    final remaining = ArenaRules.spend(state.energyFor(player), ability);

    // Scanner is an information action: it reveals immediate opponent scoring
    // cells without handing the turn to the opponent. The player can respond.
    if (ability == ArenaAbility.scanner) {
      final hints = <int>{};
      for (var i = 0; i < GameEngine.cells; i++) {
        if (game.board[i] != null || state.blockedCells.contains(i)) continue;
        final candidate = List<Mark?>.of(game.board)..[i] = player.other;
        if (GameEngine.pointsForMove(candidate, i, player.other) > 0) {
          hints.add(i);
        }
      }
      return ArenaState(
        game: game,
        xEnergy: player == Mark.x ? remaining : state.xEnergy,
        oEnergy: player == Mark.o ? remaining : state.oEnergy,
        protectedCells: state.protectedCells,
        blockedCells: state.blockedCells,
        doubleMoveFor: state.doubleMoveFor,
        scannerPenaltyFor: player,
        scannerHints: hints,
      );
    }

    // Do not let the opponent cancel an already armed double-move bonus.
    if (ability == ArenaAbility.doubleMove &&
        state.doubleMoveFor != null &&
        state.doubleMoveFor != player) {
      throw StateError('The opponent already has a double move armed.');
    }

    final protected = Set<int>.of(state.protectedCells);
    final blocked = Set<int>.of(state.blockedCells);
    final board = List<Mark?>.of(game.board);
    var moves = game.moves;
    var bonus = state.doubleMoveFor;

    if (ability == ArenaAbility.doubleMove) {
      bonus = player;
    } else {
      if (target == null) throw StateError('Choose a target cell.');
      ArenaRules.validateTarget(
        board,
        target,
        currentPlayer: player,
        ability: ability,
        protectedCells: protected,
        blockedCells: blocked,
      );

      switch (ability) {
        case ArenaAbility.erase:
          board[target] = null;
          moves--;
          break;
        case ArenaAbility.shield:
          protected.add(target);
          break;
        case ArenaAbility.block:
          blocked.add(target);
          break;
        case ArenaAbility.swap:
          board[target] = player;
          break;
        case ArenaAbility.doubleMove:
        case ArenaAbility.scanner:
          break;
      }
    }

    final finished = _boardIsClosed(board, blocked);
    final nextGame = GameState(
      board: board,
      turn: player.other,
      xScore: game.xScore,
      oScore: game.oScore,
      moves: moves,
      finished: finished,
      lastMove: game.lastMove,
    );

    return ArenaState(
      game: nextGame,
      xEnergy: player == Mark.x ? remaining : state.xEnergy,
      oEnergy: player == Mark.o ? remaining : state.oEnergy,
      protectedCells: protected,
      blockedCells: blocked,
      doubleMoveFor: finished ? null : bonus,
      scannerPenaltyFor: state.scannerPenaltyFor,
    );
  }
}
