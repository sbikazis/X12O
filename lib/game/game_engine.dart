import 'game_state.dart';

abstract final class GameEngine {
  static const size = 12;
  static const cells = 144;
  static const _directions = <(int, int)>[(0, 1), (1, 0), (1, 1), (1, -1)];

  // Each distinct contiguous three-cell window scores once.
  // A run of four therefore contains two overlapping scoring windows.
  static int pointsForMove(List<Mark?> board, int index, Mark mark) {
    if (board.length != cells || index < 0 || index >= cells) {
      throw RangeError('Invalid board or cell index.');
    }
    var points = 0;
    final row = index ~/ size;
    final col = index % size;
    for (final (dr, dc) in _directions) {
      for (var offset = -2; offset <= 0; offset++) {
        final sr = row + dr * offset;
        final sc = col + dc * offset;
        final er = sr + dr * 2;
        final ec = sc + dc * 2;
        if (!_inside(sr, sc) || !_inside(er, ec)) continue;
        var match = true;
        for (var step = 0; step < 3; step++) {
          if (board[(sr + dr * step) * size + sc + dc * step] != mark) {
            match = false;
            break;
          }
        }
        if (match) points++;
      }
    }
    return points;
  }

  static GameState play(GameState state, int index) {
    if (state.finished) throw StateError('Match has finished.');
    if (index < 0 || index >= cells) throw RangeError.index(index, state.board);
    if (state.board[index] != null) throw StateError('Cell is occupied.');
    final board = List<Mark?>.of(state.board);
    board[index] = state.turn;
    final gained = pointsForMove(board, index, state.turn);
    final moves = state.moves + 1;
    return GameState(
      board: board,
      turn: state.turn.other,
      xScore: state.xScore + (state.turn == Mark.x ? gained : 0),
      oScore: state.oScore + (state.turn == Mark.o ? gained : 0),
      moves: moves,
      finished: moves == cells,
      lastMove: index,
    );
  }

  static bool _inside(int row, int col) => row >= 0 && row < size && col >= 0 && col < size;
}
