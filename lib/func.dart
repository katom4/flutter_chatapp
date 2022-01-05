import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state.dart';
void getu(WidgetRef ref) async{
  final a=await FirebaseFirestore.instance
              .collection('users')
              .doc(ref.watch(userProvider.state).state!.uid);
  final b=await a.get();
  final c=await b.exists ? b.data() : null;
  if(c==null){
    print("err");
  }else{
    ref.watch(groupidProvider.state).state=c['gid'];
    ref.watch(usernameProvider.state).state=c['username'];
  }
  ref.watch(unamesProvider.state).state=[];
  ref.watch(daProvider.state).state=[];
  ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
}

Future<String> getuname(String uid) async{
  final a=await FirebaseFirestore.instance
              .collection('users')
              .doc(uid);
  final b=await a.get();
  final c=await b.exists ? b.data() : null;
  if(c==null){
    print("err");
    return "";
  }else{
    return Future<String>.value(c['username']);
  }

}
String getConversionDate(String d){
  if(d.length!=26)return "err";
  String month=d.substring(5,7);
  String date=d.substring(8,10);
  String hour=d.substring(11,13);
  String minute=d.substring(14,16);
  return month+"月"+date+"日　"+hour+"時"+minute+"分";

}