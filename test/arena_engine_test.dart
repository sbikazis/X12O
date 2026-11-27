import 'package:flutter_test/flutter_test.dart';
import 'package:x12o/game/arena_engine.dart';
import 'package:x12o/game/arena_abilities.dart';
import 'package:x12o/game/game_state.dart';
void main(){
 group('Arena actions',(){
  test('normal move restores one energy',(){final s=ArenaEngine.play(ArenaState(),0);expect(s.xEnergy,3);expect(s.game.turn,Mark.o);});
  test('erase removes opponent mark and consumes turn',(){var s=ArenaState();s=ArenaEngine.play(s,0);s=ArenaEngine.play(s,1);s=ArenaEngine.play(s,2);s=ArenaEngine.useAbility(s,ArenaAbility.erase,target:0);expect(s.game.board[0],isNull);expect(s.oEnergy,0);expect(s.game.turn,Mark.x);expect(s.game.moves,2);});
  test('shield blocks erase',(){var s=ArenaState();s=ArenaEngine.play(s,0);s=ArenaEngine.play(s,1);s=ArenaEngine.play(s,2);s=ArenaEngine.useAbility(s,ArenaAbility.shield,target:1);expect(()=>ArenaEngine.useAbility(s,ArenaAbility.erase,target:1),throwsStateError);});
  test('block prevents placement',(){final s=ArenaEngine.useAbility(ArenaState(),ArenaAbility.block,target:70);expect(()=>ArenaEngine.play(s,70),throwsStateError);});
  test('swap converts opponent mark',(){var s=ArenaState(oEnergy:4);s=ArenaEngine.play(s,10);s=ArenaEngine.useAbility(s,ArenaAbility.swap,target:10);expect(s.game.board[10],Mark.o);});
  test('double move gives same player two placements',(){var s=ArenaEngine.useAbility(ArenaState(xEnergy:5),ArenaAbility.doubleMove);s=ArenaEngine.play(s,0);expect(s.game.turn,Mark.x);s=ArenaEngine.play(s,1);expect(s.game.turn,Mark.x);s=ArenaEngine.play(s,2);expect(s.game.turn,Mark.o);});
  test('scanner highlights opponent immediate scores',(){final b=List<Mark?>.filled(144,null)..[60]=Mark.o..[61]=Mark.o;var s=ArenaState(game:GameState(board:b,turn:Mark.x,moves:2));s=ArenaEngine.useAbility(s,ArenaAbility.scanner);expect(s.scannerHints,contains(62));});
  test('rejects unaffordable abilities',(){expect(()=>ArenaEngine.useAbility(ArenaState(),ArenaAbility.erase,target:0),throwsStateError);});
 });
}
