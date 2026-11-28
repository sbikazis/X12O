import 'package:flutter/material.dart';
import '../app.dart';
import '../game/match_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override State<ProfileScreen> createState()=>_ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen>{
 late Future<PlayerStats> _stats;
 @override void initState(){super.initState();_stats=MatchRepository.stats();}
 void _refresh(){setState(()=>_stats=MatchRepository.stats());}
 @override Widget build(BuildContext context)=>Scaffold(
  appBar:AppBar(title:const Text('PLAYER PROFILE',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:1.5)),actions:[IconButton(onPressed:_refresh,icon:const Icon(Icons.refresh_rounded))]),
  body:FutureBuilder<PlayerStats>(future:_stats,builder:(context,snapshot){
   if(snapshot.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
   final stats=snapshot.data??const PlayerStats(0,0,0,0,0,0,[]);
   return ListView(padding:const EdgeInsets.all(20),children:[
    Container(padding:const EdgeInsets.all(21),decoration:BoxDecoration(borderRadius:BorderRadius.circular(23),gradient:const LinearGradient(colors:[Color(0xFF20384C),Palette.panel],begin:Alignment.topLeft,end:Alignment.bottomRight),border:Border.all(color:Palette.cyan.withValues(alpha:.25))),
     child:Column(children:[
      const CircleAvatar(radius:31,backgroundColor:Color(0xFF254354),child:Icon(Icons.person_rounded,size:32,color:Palette.cyan)),
      const SizedBox(height:12),const Text('ROOKIE',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900,letterSpacing:1.2)),
      const SizedBox(height:4),const Text('Your legend is taking shape.',style:TextStyle(color:Palette.muted,fontSize:11)),
      const SizedBox(height:19),
      Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
       _Stat(stats.matches.toString(),'MATCHES'),_Stat(stats.wins.toString(),'X WINS'),_Stat(stats.winRate.toString()+'%','WIN RATE'),
      ]),
     ])),
    const SizedBox(height:22),
    const Text('CAREER RECORD',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.3,fontSize:11)),
    const SizedBox(height:10),
    Row(children:[
     Expanded(child:_Metric('DRAWS',stats.draws.toString(),Palette.gold)),
     const SizedBox(width:8),Expanded(child:_Metric('LOSSES',stats.losses.toString(),Palette.coral)),
     const SizedBox(width:8),Expanded(child:_Metric('POINTS',stats.points.toString(),Palette.cyan)),
    ]),
    const SizedBox(height:23),
    Row(children:[const Expanded(child:Text('RECENT MATCHES',style:TextStyle(fontWeight:FontWeight.w900,letterSpacing:1.3,fontSize:11))),Text(stats.matches==0?'NO MATCHES YET':stats.matches.toString()+' SAVED',style:const TextStyle(color:Palette.muted,fontSize:9,fontWeight:FontWeight.w800))]),
    const SizedBox(height:9),
    if(stats.recent.isEmpty)Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:Palette.panel,borderRadius:BorderRadius.circular(15),border:Border.all(color:Palette.line)),child:const Column(children:[Icon(Icons.sports_esports_rounded,color:Palette.gold,size:28),SizedBox(height:9),Text('YOUR FIRST MATCH IS WAITING',style:TextStyle(fontWeight:FontWeight.w900,fontSize:11)),SizedBox(height:5),Text('Finish a Classic, AI or Arena match and its result will appear here.',textAlign:TextAlign.center,style:TextStyle(color:Palette.muted,fontSize:11,height:1.5))]))
    else ...stats.recent.take(12).map((match){
     final win=match.winner?.name=='x';
     final draw=match.winner==null;
     final color=draw?Palette.gold:win?Palette.cyan:Palette.coral;
     return Container(margin:const EdgeInsets.only(bottom:7),padding:const EdgeInsets.symmetric(horizontal:12,vertical:11),decoration:BoxDecoration(color:Palette.panel,borderRadius:BorderRadius.circular(12),border:Border.all(color:Palette.line)),child:Row(children:[
      Container(width:32,height:32,decoration:BoxDecoration(color:color.withValues(alpha:.12),borderRadius:BorderRadius.circular(9)),child:Icon(draw?Icons.balance_rounded:win?Icons.emoji_events_rounded:Icons.flag_rounded,color:color,size:17)),
      const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(match.mode.toUpperCase(),style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900)),Text(_date(match.playedAt)+' · '+match.moves.toString()+' moves',style:const TextStyle(fontSize:9,color:Palette.muted))])),
      Text(match.xScore.toString()+' : '+match.oScore.toString(),style:TextStyle(fontSize:13,fontWeight:FontWeight.w900,color:color)),
      const SizedBox(width:8),Text(draw?'DRAW':win?'WIN':'LOSS',style:TextStyle(fontSize:8,fontWeight:FontWeight.w900,color:color)),
     ]));
    }),
    const SizedBox(height:12),
    const Text('Your history is stored privately on this device. Online rankings and cross-device sync are not active.',style:TextStyle(color:Palette.muted,fontSize:11,height:1.5)),
   ]);
  }),
 );
 String _date(DateTime d){final local=d.toLocal();return '${local.year}-${local.month.toString().padLeft(2,'0')}-${local.day.toString().padLeft(2,'0')}';}
}
class _Stat extends StatelessWidget{
 const _Stat(this.value,this.label);final String value,label;
 @override Widget build(BuildContext context)=>Column(children:[Text(value,style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(height:3),Text(label,style:const TextStyle(color:Palette.muted,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.8))]);
}
class _Metric extends StatelessWidget{
 const _Metric(this.label,this.value,this.color);final String label,value;final Color color;
 @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:13,horizontal:8),decoration:BoxDecoration(color:Palette.panel,borderRadius:BorderRadius.circular(12),border:Border.all(color:Palette.line)),child:Column(children:[Text(value,style:TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:color)),const SizedBox(height:4),Text(label,style:const TextStyle(color:Palette.muted,fontSize:8,fontWeight:FontWeight.w900,letterSpacing:.8))]));
}
