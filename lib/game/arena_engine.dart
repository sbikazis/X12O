import 'game_engine.dart';
import 'game_state.dart';

class ArenaState {
  ArenaState({GameState? game, this.xEnergy=2, this.oEnergy=2, Set<int> protectedCells=const {}, Set<int> blockedCells=const {}, this.doubleMoveFor, Set<int> scannerHints=const {}})
    : game=game??GameState(), protectedCells=Set.unmodifiable(protectedCells), blockedCells=Set.unmodifiable(blockedCells), scannerHints=Set.unmodifiable(scannerHints);
  final GameState game;
  final int xEnergy, oEnergy;
  final Set<int> protectedCells, blockedCells, scannerHints;
  final Mark? doubleMoveFor;
  int energyFor(Mark m)=>m==Mark.x?xEnergy:oEnergy;
}
abstract final class ArenaEngine {
  static const maxEnergy=6;
  static int _regen(int n)=>(n+1).clamp(0,maxEnergy);
  static ArenaState play(ArenaState s,int i) {
    final g=s.game;
    if(g.finished) throw StateError('Match has finished.');
    if(i<0||i>=GameEngine.cells) throw RangeError('Invalid cell.');
    if(g.board[i]!=null||s.blockedCells.contains(i)) throw StateError('Cell is unavailable.');
    final p=g.turn;
    final played=GameEngine.play(g,i);
    final bonus=s.doubleMoveFor==p&&!played.finished;
    final next=GameState(board:played.board,turn:bonus?p:played.turn,xScore:played.xScore,oScore:played.oScore,moves:played.moves,finished:played.finished,lastMove:i);
    return ArenaState(game:next,xEnergy:p==Mark.x?_regen(s.xEnergy):s.xEnergy,oEnergy:p==Mark.o?_regen(s.oEnergy):s.oEnergy,
      protectedCells:s.protectedCells,blockedCells:s.blockedCells,doubleMoveFor:bonus?null:s.doubleMoveFor);
  }
  static ArenaState useAbility(ArenaState s,ArenaAbility a,{int? target}) {
    final g=s.game; if(g.finished) throw StateError('Match has finished.');
    final p=g.turn, energy=s.energyFor(p);
    if(energy<a.cost) throw StateError('Not enough energy.');
    final board=List<Mark?>.of(g.board), shield=Set<int>.of(s.protectedCells), blocked=Set<int>.of(s.blockedCells);
    var bonus=s.doubleMoveFor; var hints=<int>{};
    if(a==ArenaAbility.scanner) {
      for(var i=0;i<GameEngine.cells;i++) { if(board[i]!=null) continue; final b=List<Mark?>.of(board)..[i]=p.other; if(GameEngine.pointsForMove(b,i,p.other)>0) hints.add(i); }
    } else if(a==ArenaAbility.doubleMove) { bonus=p; }
    else {
      if(target==null||target<0||target>=GameEngine.cells) throw RangeError('Invalid target.');
      if(shield.contains(target)||blocked.contains(target)) throw StateError('Cell is protected or blocked.');
      switch(a) {
        case ArenaAbility.erase: if(board[target]!=p.other) throw StateError('Choose an opponent mark.'); board[target]=null; break;
        case ArenaAbility.shield: if(board[target]!=p) throw StateError('Choose your own mark.'); shield.add(target); break;
        case ArenaAbility.block: if(board[target]!=null) throw StateError('Choose an empty cell.'); blocked.add(target); break;
        case ArenaAbility.swap: if(board[target]!=p.other) throw StateError('Choose an opponent mark.'); board[target]=p; break;
        case ArenaAbility.doubleMove: case ArenaAbility.scanner: break;
      }
    }
    final remaining=energy-a.cost;
    return ArenaState(game:GameState(board:board,turn:p.other,xScore:g.xScore,oScore:g.oScore,moves:g.moves,finished:false,lastMove:g.lastMove),
      xEnergy:p==Mark.x?remaining:s.xEnergy,oEnergy:p==Mark.o?remaining:s.oEnergy,protectedCells:shield,blockedCells:blocked,doubleMoveFor:bonus,scannerHints:hints);
  }
}
