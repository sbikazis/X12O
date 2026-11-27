import 'package:flutter/material.dart';
import '../app.dart';
import '../game/arena_engine.dart';
import '../game/arena_abilities.dart';
import '../game/game_engine.dart';
import '../game/game_state.dart';

class ArenaScreen extends StatefulWidget {
 const ArenaScreen({super.key});
 @override State<ArenaScreen> createState()=>_ArenaScreenState();
}
class _ArenaScreenState extends State<ArenaScreen>{
 ArenaState state=ArenaState();
 ArenaAbility? selected;
 bool targeting=false;
 Color tint(Mark m)=>m==Mark.x?Palette.cyan:Palette.coral;
 void message(String s){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s),duration:const Duration(seconds:2)));}
 void ability(ArenaAbility a){
  if(state.energyFor(state.game.turn)<a.cost){message('Not enough energy.');return;}
  if(a==ArenaAbility.scanner||a==ArenaAbility.doubleMove){
   try{setState(()=>state=ArenaEngine.useAbility(state,a));message(a==ArenaAbility.scanner?'Threat scan complete.':'Double move armed. Place twice.');}catch(e){message(e.toString());}
  }else{setState((){selected=a;targeting=true;});message('Choose a target cell.');}
 }
 void cell(int i){
  try{setState(()=>state=targeting?ArenaEngine.useAbility(state,selected!,target:i):ArenaEngine.play(state,i));selected=null;targeting=false;}
  catch(e){message(e.toString().replaceFirst('Bad state: ',''));}
 }
 @override Widget build(BuildContext context){
  final g=state.game,p=g.turn,c=tint(p);
  return Scaffold(appBar:AppBar(title:const Text('ARENA // TACTICAL',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:1.3))),
   body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.all(10),child:Row(children:[player(Mark.x),const SizedBox(width:8),player(Mark.o)])),
    Container(margin:const EdgeInsets.symmetric(horizontal:10),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Palette.panel,borderRadius:BorderRadius.circular(10),border:Border.all(color:Palette.line)),
     child:Row(children:[Icon(Icons.bolt,color:c),const SizedBox(width:7),Expanded(child:Text(targeting?'TARGET: '+selected!.title.toUpperCase():'PLAYER '+p.symbol+' — YOUR TURN',style:const TextStyle(fontSize:10,fontWeight:FontWeight.w900))),Text(g.moves.toString()+'/144',style:const TextStyle(color:Palette.muted,fontSize:10))])),
    Expanded(child:Center(child:AspectRatio(aspectRatio:1,child:Container(margin:const EdgeInsets.all(7),padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:Palette.panel,borderRadius:BorderRadius.circular(14),border:Border.all(color:Palette.line)),
     child:GridView.builder(physics:const NeverScrollableScrollPhysics(),itemCount:144,gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:12,crossAxisSpacing:3,mainAxisSpacing:3),
      itemBuilder:(_,i){final m=g.board[i],blocked=state.blockedCells.contains(i),scan=state.scannerHints.contains(i),shield=state.protectedCells.contains(i);return GestureDetector(onTap:()=>cell(i),child:Container(decoration:BoxDecoration(color:blocked?Palette.coral.withValues(alpha:.2):m==null?Palette.panel2:tint(m).withValues(alpha:.14),borderRadius:BorderRadius.circular(4),border:Border.all(color:scan?Palette.gold:shield?Palette.cyan:g.lastMove==i?tint(m!):Palette.line,width:scan||shield||g.lastMove==i?1.2:.5)),child:Center(child:Text(blocked?'×':m?.symbol??(scan?'!':shield?'◆':''),style:TextStyle(fontSize:11,fontWeight:FontWeight.w900,color:blocked?Palette.coral:scan?Palette.gold:shield?Palette.cyan:m==null?Palette.muted:tint(m))))));}))))),
    Padding(padding:const EdgeInsets.fromLTRB(10,5,10,12),child:Column(children:[
     Row(children:[const Expanded(child:Text('TACTICAL ABILITIES',style:TextStyle(fontSize:10,fontWeight:FontWeight.w900,letterSpacing:1))),Text(state.energyFor(p).toString()+'/6 ENERGY',style:TextStyle(color:c,fontWeight:FontWeight.w900,fontSize:10))]),
     const SizedBox(height:7),Wrap(spacing:6,runSpacing:6,children:ArenaAbility.values.map((a)=>SizedBox(width:(MediaQuery.sizeOf(context).width-34)/3,child:Material(color:Palette.panel,borderRadius:BorderRadius.circular(9),child:InkWell(onTap:()=>ability(a),borderRadius:BorderRadius.circular(9),child:Container(padding:const EdgeInsets.symmetric(vertical:9,horizontal:5),decoration:BoxDecoration(borderRadius:BorderRadius.circular(9),border:Border.all(color:selected==a?Palette.cyan:Palette.line)),child:Column(children:[Text(a.title.toUpperCase(),style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900)),Text(a.cost.toString()+' ENERGY',style:const TextStyle(color:Palette.muted,fontSize:8))])))))).toList()),
     if(targeting)TextButton(onPressed:()=>setState((){selected=null;targeting=false;}),child:const Text('CANCEL TARGET')),
     if(g.finished)FilledButton(onPressed:()=>setState(()=>state=ArenaState()),child:const Text('PLAY AGAIN')),
    ]))
   ])));
 }
 Widget player(Mark m){final active=state.game.turn==m;return Expanded(child:Container(padding:const EdgeInsets.all(9),decoration:BoxDecoration(color:active?tint(m).withValues(alpha:.1):Palette.panel,borderRadius:BorderRadius.circular(11),border:Border.all(color:active?tint(m):Palette.line)),child:Row(children:[Text(m.symbol,style:TextStyle(color:tint(m),fontSize:21,fontWeight:FontWeight.w900)),const SizedBox(width:7),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('PLAYER '+m.symbol,style:const TextStyle(fontSize:9,fontWeight:FontWeight.w900)),Text(state.energyFor(m).toString()+' ENERGY',style:const TextStyle(fontSize:8,color:Palette.muted))])),Text((m==Mark.x?state.game.xScore:state.game.oScore).toString(),style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900))])));}
}
