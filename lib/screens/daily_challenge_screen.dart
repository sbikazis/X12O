import 'package:flutter/material.dart';
import '../app.dart';
import '../game/match_repository.dart';
import 'game_screen.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});
  @override State<DailyChallengeScreen> createState()=>_DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late Future<DailyChallenge> _challenge;
  @override void initState(){super.initState();_refresh();}
  void _refresh()=>_challenge=MatchRepository.dailyChallenge();
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('DAILY MISSION',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:1.5))),
    body:FutureBuilder<DailyChallenge>(future:_challenge,builder:(context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
      final challenge=snapshot.data;
      if(challenge==null)return const Center(child:Text('Challenge unavailable'));
      return ListView(padding:const EdgeInsets.all(20),children:[
        Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(
          borderRadius:BorderRadius.circular(23),
          gradient:const LinearGradient(colors:[Color(0xFF3B304B),Palette.panel],begin:Alignment.topLeft,end:Alignment.bottomRight),
          border:Border.all(color:Palette.gold.withValues(alpha:.3))),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[const Icon(Icons.bolt_rounded,color:Palette.gold,size:22),const SizedBox(width:8),const Text('TODAY ONLY',style:TextStyle(color:Palette.gold,fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1.5)),const Spacer(),Text(challenge.dateKey,style:const TextStyle(color:Palette.muted,fontSize:10))]),
            const SizedBox(height:24),
            const Text('CLAIM THE BOARD',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900,letterSpacing:-.5)),
            const SizedBox(height:8),
            Text('Score at least ${challenge.targetScore} points as X in a completed match today.',style:const TextStyle(color:Palette.muted,fontSize:13,height:1.5)),
            const SizedBox(height:23),
            Row(children:[Expanded(child:ClipRRect(borderRadius:BorderRadius.circular(20),child:LinearProgressIndicator(value:challenge.progressRatio,minHeight:9,backgroundColor:Palette.ink,color:Palette.gold))),const SizedBox(width:12),Text('${challenge.progress}/${challenge.targetScore}',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:12))]),
            const SizedBox(height:19),
            Row(children:[const Icon(Icons.workspace_premium_rounded,color:Palette.gold,size:22),const SizedBox(width:8),Text('+ ${challenge.rewardXp} XP REWARD',style:const TextStyle(fontWeight:FontWeight.w900,fontSize:11))]),
            const SizedBox(height:18),
            if(challenge.completed)const Row(children:[Icon(Icons.check_circle_rounded,color:Palette.cyan),SizedBox(width:8),Text('MISSION COMPLETE',style:TextStyle(color:Palette.cyan,fontWeight:FontWeight.w900,fontSize:11))])
            else SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:() async { await Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>const GameScreen())); if(mounted)setState(_refresh); },icon:const Icon(Icons.sports_esports_rounded),label:const Text('PLAY CLASSIC'))),
          ])),
        const SizedBox(height:17),
        const Text('HOW IT WORKS',style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,letterSpacing:1.2)),
        const SizedBox(height:9),
        const Text('Finish any Classic, AI or Arena match with enough points on the X side. Your best score today counts. The 50 XP reward is granted once, and a fresh mission arrives tomorrow.',style:TextStyle(color:Palette.muted,fontSize:12,height:1.6)),
        const SizedBox(height:12),
        const Text('Your challenge progress and reward are stored privately on this device.',style:TextStyle(color:Palette.muted,fontSize:10)),
      ]);
    }),
  );
}
