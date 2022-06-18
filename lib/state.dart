import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'func.dart';
final userProvider = StateProvider((ref){
  return FirebaseAuth.instance.currentUser;
});

final userinfoProvider=StateProvider((ref){
  Map<String,dynamic>? a={};
  return a;
});

//エラー情報
final infoTextProvider = StateProvider.autoDispose((ref){
  return '';
});

//メールアドレス
final emailProvider = StateProvider.autoDispose((ref){
  return '';
});

//パスワード
final passwordProvider = StateProvider.autoDispose((ref){
  return '';
});

final usernameProvider = StateProvider.autoDispose((ref){
  return '';
});

final groupidProvider = StateProvider((ref){
  return "";
});

final messageProvider = StateProvider.autoDispose((ref){
  return '';
});

final nowPageProvider = StateProvider.autoDispose((ref){
  return 0;
});


final changeUnameProvider = StateProvider((ref){
  return "";
});


final docProvider = StateProvider((ref){
  return FirebaseFirestore.instance
                .collection('groups')
                .doc(ref.watch(groupidProvider.state).state)
                .collection('chats')
                .orderBy('date',descending: true)
                .limit(20)
                .startAfter(ref.watch(lastdateProvider.state).state.toList())
                .get();
});
final daProvider =StateProvider((ref){
  List<dynamic> list =[];
  return list;
});
final dProvider = StateProvider((ref)async{
  List<dynamic> datalist =[];
  if(ref.watch(groupidProvider.state).state!=""){
    await FirebaseFirestore.instance
                .collection('groups')
                .doc(ref.watch(groupidProvider.state).state)
                .collection('chats')
                .orderBy('date',descending: true)
                .limit(20)
                .startAfter(ref.watch(lastdateProvider.state).state.toList())
                .get()
                .then((value){
                  for(var s in value.docs){
                    datalist.add(s);
                    ref.watch(daProvider.state).state.add(s);
                  }
                });
    for(var a in datalist){
      String i = await getuname(a["uid"]);
      ref.watch(unamesProvider.state).state.add(i);
    }
  }
   return datalist;
});
final lastdateProvider = StateProvider((ref){
  return [DateTime.now().toLocal().toIso8601String()];
});

final pindexProvidr = StateProvider((ref){
  return 0;
});

final unamesProvider = StateProvider((ref){
  return [];
});

final futuerunamesProvider = StateProvider((ref)async{
  return [];
});
