/// Deterministic rules engine for X12O's 12×12 Classic mode.
enum Mark { x, o }

class GameEngine {
  GameEngine({this.boardSize = 12})
      : board = List.generate(
          boardSize,
          (_) => List<Mark?>.filled(boardSize, null),
        );

  final int boardSize;
  final List<List<Mark?>> board;

  Mark currentPlayer = Mark.x;
  int xScore = 0;
  int oScore = 0;
  int moveCount = 0;

  bool get isFinished => moveCount == boardSize * boardSize;

  int scoreFor(Mark mark) => mark == Mark.x ? xScore : oScore;

  /// Places the current mark and awards one point for every new 3-cell
  /// window completed by this move (horizontal, vertical, or diagonal).
  /// Longer runs therefore score overlapping windows: four in a row = 2.
  /// Each window is counted exactly once, on the move that completes it.
  bool play(int row, int column) {
    if (isFinished ||
        row < 0 ||
        column < 0 ||
        row >= boardSize ||
        column >= boardSize ||
        board[row][column] != null) {
      return false;
    }

    final mark = currentPlayer;
    board[row][column] = mark;
    moveCount++;

    final points = _newTriplesAt(row, column, mark);
    if (mark == Mark.x) {
      xScore += points;
    } else {
      oScore += points;
    }

    currentPlayer = mark == Mark.x ? Mark.o : Mark.x;
    return true;
  }

  int _newTriplesAt(int row, int column, Mark mark) {
    const directions = <(int, int)>[
      (0, 1),
      (1, 0),
      (1, 1),
      (1, -1),
    ];

    var total = 0;
    for (final (dr, dc) in directions) {
      // The newly placed cell can occupy any of the three positions.
      for (var start = -2; start <= 0; start++) {
        var matches = true;
        for (var step = 0; step < 3; step++) {
          final r = row + (start + step) * dr;
          final c = column + (start + step) * dc;
          if (r < 0 ||
              c < 0 ||
              r >= boardSize ||
              c >= boardSize ||
              board[r][c] != mark) {
            matches = false;
            break;
          }
        }
        if (matches) total++;
      }
    }
    return total;
  }

  void reset() {
    for (var row = 0; row < boardSize; row++) {
      board[row].fillRange(0, boardSize, null);
    }
    xScore = 0;
    oScore = 0;
    moveCount = 0;
    currentPlayer = Mark.x;
  }
}
