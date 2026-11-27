enum Mark { x, o }
extension MarkInfo on Mark {
  String get symbol => this == Mark.x ? 'X' : 'O';
  Mark get other => this == Mark.x ? Mark.o : Mark.x;
}

class GameState {
  GameState({
    List<Mark?>? board,
    this.turn = Mark.x,
    this.xScore = 0,
    this.oScore = 0,
    this.moves = 0,
    this.finished = false,
    this.lastMove,
  }) : board = List<Mark?>.unmodifiable(board ?? List<Mark?>.filled(144, null));

  final List<Mark?> board;
  final Mark turn;
  final int xScore;
  final int oScore;
  final int moves;
  final bool finished;
  final int? lastMove;

  Mark? get winner {
    if (!finished || xScore == oScore) return null;
    return xScore > oScore ? Mark.x : Mark.o;
  }
}
