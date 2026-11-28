import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class MatchRecord {
  const MatchRecord({required this.mode, required this.xScore, required this.oScore, required this.moves, required this.playedAt});
  final String mode;
  final int xScore, oScore, moves;
  final DateTime playedAt;
  Mark? get winner => xScore == oScore ? null : xScore > oScore ? Mark.x : Mark.o;
  int get xpEarned => (winner == Mark.x ? 60 : winner == null ? 35 : 20) + xScore.clamp(0, 20).toInt() * 2;
  Map<String,Object> toJson()=>{'mode':mode,'x':xScore,'o':oScore,'moves':moves,'at':playedAt.toIso8601String()};
  factory MatchRecord.fromJson(Map<String,dynamic> json)=>MatchRecord(
    mode:json['mode'] as String? ?? 'Classic',
    xScore:(json['x'] as num?)?.toInt() ?? 0,
    oScore:(json['o'] as num?)?.toInt() ?? 0,
    moves:(json['moves'] as num?)?.toInt() ?? 0,
    playedAt:DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}


class DailyChallenge {
  const DailyChallenge({required this.dateKey,required this.targetScore,required this.bestScore,required this.completed,required this.rewardXp,this.currentStreak=0,this.bestStreak=0});
  final String dateKey;
  final int targetScore,bestScore,rewardXp,currentStreak,bestStreak;
  final bool completed;
  int get progress => bestScore.clamp(0,targetScore).toInt();
  double get progressRatio => (progress/targetScore).clamp(0.0,1.0);
}

class Achievement {
  const Achievement(this.title,this.description,this.unlocked);
  final String title,description;
  final bool unlocked;
}

class PlayerStats {
  const PlayerStats(this.matches,this.wins,this.losses,this.draws,this.points,this.bestScore,this.recent,
    {this.xp=0,this.level=1,this.levelProgress=0,this.achievements=const []});
  final int matches,wins,losses,draws,points,bestScore,xp,level,levelProgress;
  final List<MatchRecord> recent;
  final List<Achievement> achievements;
  int get winRate=>matches==0?0:(wins*100/matches).round();
}

abstract final class MatchRepository {
  static const _key='x12o.match_history.v1';
  static const _careerKey='x12o.career.v1';
  static const _dailyKey='x12o.daily_challenge.v1';
  static const _streakKey='x12o.daily_streak.v1';

  static Future<List<MatchRecord>> history() async {
    final prefs=await SharedPreferences.getInstance();
    final raw=prefs.getString(_key);
    if(raw==null||raw.isEmpty) return const [];
    try {
      final decoded=jsonDecode(raw) as List<dynamic>;
      return decoded.map((e)=>MatchRecord.fromJson(Map<String,dynamic>.from(e as Map))).toList();
    } catch (_) { return const []; }
  }

  static Map<String,int> _summarize(Iterable<MatchRecord> matches) {
    var count=0,wins=0,losses=0,draws=0,points=0,best=0,xp=0;
    for(final match in matches) {
      count++;
      if(match.winner==Mark.x) { wins++; } else if(match.winner==Mark.o) { losses++; } else { draws++; }
      points+=match.xScore;
      if(match.xScore>best) best=match.xScore;
      xp+=match.xpEarned;
    }
    return {'matches':count,'wins':wins,'losses':losses,'draws':draws,'points':points,'best':best,'xp':xp};
  }

  static Future<void> record({required String mode,required int xScore,required int oScore,required int moves,DateTime? playedAt}) async {
    final prefs=await SharedPreferences.getInstance();
    final current=await history();
    final record=MatchRecord(mode:mode,xScore:xScore,oScore:oScore,moves:moves,playedAt:playedAt??DateTime.now());
    final totals=_readCareer(prefs.getString(_careerKey))??_summarize(current);
    totals['matches']=(totals['matches']??0)+1;
    if(record.winner==Mark.x) { totals['wins']=(totals['wins']??0)+1; }
    else if(record.winner==Mark.o) { totals['losses']=(totals['losses']??0)+1; }
    else { totals['draws']=(totals['draws']??0)+1; }
    totals['points']=(totals['points']??0)+record.xScore;
    totals['best']=record.xScore>(totals['best']??0)?record.xScore:(totals['best']??0);
    totals['xp']=(totals['xp']??0)+record.xpEarned;
    final streak=_readStreak(prefs.getString(_streakKey));
    final challenge=_challengeForToday(_readDaily(prefs.getString(_dailyKey)),streak);
    final best=record.xScore>challenge.bestScore?record.xScore:challenge.bestScore;
    final completed=challenge.completed||best>=challenge.targetScore;
    if(!challenge.completed&&completed) {
      totals['xp']=(totals['xp']??0)+challenge.rewardXp;
      final lastDate=streak?['lastDate'] as String?;
      final current= (streak?['current'] as num?)?.toInt() ?? 0;
      final bestStreak= (streak?['best'] as num?)?.toInt() ?? 0;
      final today=challenge.dateKey;
      final yesterday=_dateKey(DateTime.parse(today).subtract(const Duration(days:1)));
      final nextCurrent=lastDate==today?current:lastDate==yesterday?current+1:1;
      await prefs.setString(_streakKey,jsonEncode({
        'lastDate':today,
        'current':nextCurrent,
        'best':nextCurrent>bestStreak?nextCurrent:bestStreak,
      }));
    }
    await prefs.setString(_dailyKey,jsonEncode({'date':challenge.dateKey,'best':best,'completed':completed}));
    await prefs.setString(_key,jsonEncode([record,...current].take(50).map((e)=>e.toJson()).toList()));
    await prefs.setString(_careerKey,jsonEncode(totals));
  }

  static Map<String,int>? _readCareer(String? raw) {
    if(raw==null||raw.isEmpty) return null;
    try {
      final decoded=Map<String,dynamic>.from(jsonDecode(raw) as Map);
      return decoded.map((key,value)=>MapEntry(key,(value as num).toInt()));
    } catch (_) { return null; }
  }

  
  static String _dateKey(DateTime date) =>
      date.year.toString()+'-'+date.month.toString().padLeft(2,'0')+'-'+date.day.toString().padLeft(2,'0');

  static String _todayKey() => _dateKey(DateTime.now());

  static Map<String,dynamic>? _readStreak(String? raw) {
    if(raw==null||raw.isEmpty) return null;
    try { return Map<String,dynamic>.from(jsonDecode(raw) as Map); } catch (_) { return null; }
  }

  static DailyChallenge _challengeForToday(Map<String,dynamic>? saved, Map<String,dynamic>? streak) {
    final date=_todayKey();
    final parts=date.split('-').map(int.parse).toList();
    final dayOfYear=DateTime(parts[0],parts[1],parts[2]).difference(DateTime(parts[0])).inDays;
    final target=3+(dayOfYear%3);
    final valid=saved!=null&&saved['date']==date;
    final lastDate=streak?['lastDate'] as String?;
    final current=(streak?['current'] as num?)?.toInt() ?? 0;
    final best=(streak?['best'] as num?)?.toInt() ?? 0;
    final yesterday=_dateKey(DateTime(parts[0],parts[1],parts[2]).subtract(const Duration(days:1)));
    final activeCurrent=lastDate==date||lastDate==yesterday?current:0;
    return DailyChallenge(
      dateKey:date,
      targetScore:target,
      bestScore:valid?(saved['best'] as num? ?? 0).toInt():0,
      completed:valid?(saved['completed'] as bool? ?? false):false,
      rewardXp:50,
      currentStreak:activeCurrent,
      bestStreak:best,
    );
  }

  static Map<String,dynamic>? _readDaily(String? raw) {
    if(raw==null||raw.isEmpty) return null;
    try { return Map<String,dynamic>.from(jsonDecode(raw) as Map); } catch (_) { return null; }
  }

  static Future<DailyChallenge> dailyChallenge() async {
    final prefs=await SharedPreferences.getInstance();
    return _challengeForToday(_readDaily(prefs.getString(_dailyKey)),_readStreak(prefs.getString(_streakKey)));
  }

  static Future<PlayerStats> stats() async {
    final prefs=await SharedPreferences.getInstance();
    final recent=await history();
    final totals=_readCareer(prefs.getString(_careerKey))??_summarize(recent);
    final matches=totals['matches']??0,wins=totals['wins']??0,losses=totals['losses']??0;
    final draws=totals['draws']??0,points=totals['points']??0,best=totals['best']??0,xp=totals['xp']??0;
    final level=xp~/100+1;
    final streak=_readStreak(prefs.getString(_streakKey));
    final bestDailyStreak=(streak?['best'] as num?)?.toInt() ?? 0;
    final achievements=<Achievement>[
      Achievement('FIRST MATCH','Complete your first match',matches>=1),
      Achievement('RISING RIVAL','Complete 5 matches',matches>=5),
      Achievement('VETERAN','Complete 10 matches',matches>=10),
      Achievement('FIRST VICTORY','Win your first match',wins>=1),
      Achievement('DOMINATOR','Win 5 matches',wins>=5),
      Achievement('CENTURY','Score 100 total points',points>=100),
      Achievement('WEEK WARRIOR','Maintain a 7-day daily streak',bestDailyStreak>=7),
      Achievement('UNSTOPPABLE','Maintain a 30-day daily streak',bestDailyStreak>=30),
    ];
    return PlayerStats(matches,wins,losses,draws,points,best,List.unmodifiable(recent),
      xp:xp,level:level,levelProgress:xp%100,achievements:List.unmodifiable(achievements));
  }

  static Future<void> clear() async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_careerKey);
    await prefs.remove(_dailyKey);
    await prefs.remove(_streakKey);
  }
}
