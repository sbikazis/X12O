import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_state.dart';

class MatchRecord {
  const MatchRecord({required this.mode, required this.xScore, required this.oScore, required this.moves, required this.playedAt});
  final String mode;
  final int xScore, oScore, moves;
  final DateTime playedAt;
  Mark? get winner => xScore == oScore ? null : xScore > oScore ? Mark.x : Mark.o;
  Map<String,Object> toJson()=>{'mode':mode,'x':xScore,'o':oScore,'moves':moves,'at':playedAt.toIso8601String()};
  factory MatchRecord.fromJson(Map<String,dynamic> json)=>MatchRecord(
    mode:json['mode'] as String? ?? 'Classic',
    xScore:(json['x'] as num?)?.toInt() ?? 0,
    oScore:(json['o'] as num?)?.toInt() ?? 0,
    moves:(json['moves'] as num?)?.toInt() ?? 0,
    playedAt:DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class PlayerStats {
  const PlayerStats(this.matches,this.wins,this.losses,this.draws,this.points,this.bestScore,this.recent);
  final int matches,wins,losses,draws,points,bestScore;
  final List<MatchRecord> recent;
  int get winRate=>matches==0?0:(wins*100/matches).round();
}

abstract final class MatchRepository {
  static const _key='x12o.match_history.v1';
  static Future<List<MatchRecord>> history() async {
    final prefs=await SharedPreferences.getInstance();
    final raw=prefs.getString(_key);
    if(raw==null||raw.isEmpty)return const [];
    try {
      final decoded=jsonDecode(raw) as List<dynamic>;
      return decoded.map((e)=>MatchRecord.fromJson(Map<String,dynamic>.from(e as Map))).toList();
    } catch (_) { return const []; }
  }
  static Future<void> record({required String mode,required int xScore,required int oScore,required int moves,DateTime? playedAt}) async {
    final prefs=await SharedPreferences.getInstance();
    final current=await history();
    final record=MatchRecord(mode:mode,xScore:xScore,oScore:oScore,moves:moves,playedAt:playedAt??DateTime.now());
    final updated=[record,...current].take(50).map((e)=>e.toJson()).toList();
    await prefs.setString(_key,jsonEncode(updated));
  }
  static Future<PlayerStats> stats() async {
    final recent=await history();
    var wins=0,losses=0,draws=0,points=0,best=0;
    for(final match in recent){
      if(match.winner==Mark.x) { wins++; } else if(match.winner==Mark.o) { losses++; } else { draws++; }
      points+=match.xScore;
      if(match.xScore>best) { best=match.xScore; }
    }
    return PlayerStats(recent.length,wins,losses,draws,points,best,List.unmodifiable(recent));
  }
  static Future<void> clear() async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
