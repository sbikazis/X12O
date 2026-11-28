import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x12o/game/match_repository.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 setUp(()=>SharedPreferences.setMockInitialValues({}));
 group('Local match repository',(){
  test('stores a match and calculates career statistics',()async{
   await MatchRepository.record(mode:'Classic local',xScore:4,oScore:2,moves:144,playedAt:DateTime(2026,11,28));
   final stats=await MatchRepository.stats();
   expect(stats.matches,1);expect(stats.wins,1);expect(stats.losses,0);expect(stats.points,4);expect(stats.winRate,100);
   expect(stats.recent.single.mode,'Classic local');
  });
  test('records draws and losses from the X player perspective',()async{
   await MatchRepository.record(mode:'Arena local',xScore:2,oScore:2,moves:144);
   await MatchRepository.record(mode:'AI / hard',xScore:1,oScore:3,moves:144);
   final stats=await MatchRepository.stats();
   expect(stats.draws,1);expect(stats.losses,1);expect(stats.wins,0);
  });
  test('keeps only the latest 50 matches',()async{
   for(var i=0;i<55;i++){await MatchRepository.record(mode:'match $i',xScore:i,oScore:0,moves:i);}
   final history=await MatchRepository.history();
   expect(history.length,50);expect(history.first.mode,'match 54');expect(history.last.mode,'match 5');
  });
  test('clears local history',()async{
   await MatchRepository.record(mode:'test',xScore:1,oScore:0,moves:144);
   await MatchRepository.clear();
   expect(await MatchRepository.history(),isEmpty);
  });
 });
}
