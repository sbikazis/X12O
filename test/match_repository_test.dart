import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:x12o/game/match_repository.dart';

void main(){
 TestWidgetsFlutterBinding.ensureInitialized();
 setUp(()=>SharedPreferences.setMockInitialValues({}));
 group('Local match repository',(){
  test('stores a match and calculates career statistics and XP',()async{
   final challenge=await MatchRepository.dailyChallenge();
   await MatchRepository.record(mode:'Classic local',xScore:4,oScore:2,moves:144,playedAt:DateTime(2026,11,28));
   final stats=await MatchRepository.stats();
   expect(stats.matches,1);expect(stats.wins,1);expect(stats.losses,0);expect(stats.points,4);expect(stats.winRate,100);
   final bonus=4>=challenge.targetScore?50:0;
   expect(stats.xp,68+bonus);expect(stats.level,(68+bonus)~/100+1);expect(stats.levelProgress,(68+bonus)%100);
   expect(stats.achievements.first.unlocked,isTrue);
   expect(stats.achievements[3].unlocked,isTrue);
   expect(stats.recent.single.mode,'Classic local');
  });
  test('records draws and losses from the X player perspective',()async{
   await MatchRepository.record(mode:'Arena local',xScore:2,oScore:2,moves:144);
   await MatchRepository.record(mode:'AI / hard',xScore:1,oScore:3,moves:144);
   final stats=await MatchRepository.stats();
   expect(stats.draws,1);expect(stats.losses,1);expect(stats.wins,0);
   expect(stats.xp,61);
  });
  test('unlocks match milestones and advances levels',()async{
   for(var i=0;i<10;i++){await MatchRepository.record(mode:'Classic',xScore:10,oScore:0,moves:144);}
   final stats=await MatchRepository.stats();
   expect(stats.level,9);
   expect(stats.achievements[1].unlocked,isTrue);
   expect(stats.achievements[2].unlocked,isTrue);
   expect(stats.achievements[4].unlocked,isTrue);
   expect(stats.achievements[5].unlocked,isTrue);
  });
  test('keeps only the latest 50 matches',()async{
   for(var i=0;i<55;i++){await MatchRepository.record(mode:'match $i',xScore:i,oScore:0,moves:i);}
   final history=await MatchRepository.history();
   expect(history.length,50);expect(history.first.mode,'match 54');expect(history.last.mode,'match 5');
   final stats=await MatchRepository.stats();
   expect(stats.matches,55);expect(stats.wins,54);// Each match caps score-derived XP at 20 points; the daily bonus is +50.
   expect(stats.xp,5105);
  });

  test('daily challenge grants its bonus once and tracks best score',()async{
   final challenge=await MatchRepository.dailyChallenge();
   await MatchRepository.record(mode:'Classic',xScore:challenge.targetScore,oScore:0,moves:144);
   final completed=await MatchRepository.dailyChallenge();
   expect(completed.completed,isTrue);
   expect(completed.bestScore,challenge.targetScore);
   final afterFirst=await MatchRepository.stats();
   await MatchRepository.record(mode:'Classic',xScore:challenge.targetScore+2,oScore:0,moves:144);
   final afterSecond=await MatchRepository.stats();
   expect(afterSecond.xp-afterFirst.xp,60+(challenge.targetScore+2)*2);
   expect((await MatchRepository.dailyChallenge()).bestScore,challenge.targetScore+2);
  });
  test('daily streak increments on consecutive mission completions',()async{
   final challenge=await MatchRepository.dailyChallenge();
   final today=DateTime.parse(challenge.dateKey);
   final yesterday=DateTime(today.year,today.month,today.day).subtract(const Duration(days:1));
   final yesterdayKey='${yesterday.year}-${yesterday.month.toString().padLeft(2,'0')}-${yesterday.day.toString().padLeft(2,'0')}';
   final prefs=await SharedPreferences.getInstance();
   await prefs.setString('x12o.daily_streak.v1',jsonEncode({'lastDate':yesterdayKey,'current':3,'best':4}));
   await MatchRepository.record(mode:'Classic',xScore:challenge.targetScore,oScore:0,moves:144);
   final updated=await MatchRepository.dailyChallenge();
   expect(updated.currentStreak,4);
   expect(updated.bestStreak,4);
  });
  test('missed daily missions reset the active streak but preserve the record',()async{
   final challenge=await MatchRepository.dailyChallenge();
   final today=DateTime.parse(challenge.dateKey);
   final twoDaysAgo=DateTime(today.year,today.month,today.day).subtract(const Duration(days:2));
   final oldKey='${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2,'0')}-${twoDaysAgo.day.toString().padLeft(2,'0')}';
   final prefs=await SharedPreferences.getInstance();
   await prefs.setString('x12o.daily_streak.v1',jsonEncode({'lastDate':oldKey,'current':5,'best':7}));
   final current=await MatchRepository.dailyChallenge();
   expect(current.currentStreak,0);
   expect(current.bestStreak,7);
  });
  test('unlocks daily streak achievements from the personal best',()async{
   final prefs=await SharedPreferences.getInstance();
   await prefs.setString('x12o.daily_streak.v1',jsonEncode({'lastDate':'2026-11-28','current':7,'best':30}));
   final stats=await MatchRepository.stats();
   expect(stats.achievements[6].unlocked,isTrue);
   expect(stats.achievements[7].unlocked,isTrue);
  });
  test('clears local history',()async{
   await MatchRepository.record(mode:'test',xScore:1,oScore:0,moves:144);
   await MatchRepository.clear();
   expect(await MatchRepository.history(),isEmpty);
  });
 });
}
