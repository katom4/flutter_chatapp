import 'package:chat/importer.dart';
import 'chatpage.dart';
import 'package:twitter_login/twitter_login.dart';

class RegisterPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final infoText = ref.watch(infoTextProvider.state).state;
    final email= ref.watch(emailProvider.state).state;
    final password = ref.watch(passwordProvider.state).state;
    final username = ref.watch(usernameProvider.state).state;
    String groupid = ref.watch(groupidProvider.state).state;
    return Scaffold(
      body: Center(
        child:Container(
          padding:EdgeInsets.all(24),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              TextFormField(
                decoration:InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value){
                  ref.watch(emailProvider.state).state=value;
                },
              ),
              TextFormField(
                decoration:InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value){
                  ref.watch(passwordProvider.state).state=value;
                },
              ),
              TextFormField(
                decoration:InputDecoration(labelText: 'ユーザー名'),
                onChanged: (String value){
                  ref.watch(usernameProvider.state).state=value;
                },
              ),
              Container(
                padding:EdgeInsets.all(8),
                child:Text(infoText),
              ),
              Container(
                width:double.infinity,
                child:ElevatedButton(
                  child:Text('ユーザー登録'),
                  onPressed: ()async{
                    try{
                      
                      final FirebaseAuth auth=FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password
                        );
                      auth.currentUser?.sendEmailVerification();
                      await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser!.uid)
                                  .set({
                                    'username':username,
                                    'verification':false,
                                  });
                      
                      ref.read(infoTextProvider.state).state='メールを送信しました';
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  },
                ),
              ),
              SizedBox(height:40),
              Container(
                width:double.infinity,
                height: 30,
                color: Colors.white,
                child:OutlinedButton(
                  child:Text('登録済みの方はこちら'),
                  onPressed: ()async{
                    try{
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return LoginPage();
                        }),
                      );
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  },
                ),
              ),
              const SizedBox(height:8),
              
            ],
          ),
        ),
      ),
      
    );
  }
}

class LoginPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final infoText = ref.watch(infoTextProvider.state).state;
    final email= ref.watch(emailProvider.state).state;
    final password = ref.watch(passwordProvider.state).state;
    final username = ref.watch(usernameProvider.state).state;
    String groupid = ref.watch(groupidProvider.state).state;
    return Scaffold(
      body: Center(
        child:Container(
          padding:EdgeInsets.all(24),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              TextFormField(
                decoration:InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value){
                  ref.watch(emailProvider.state).state=value;
                },
              ),
              TextFormField(
                decoration:InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value){
                  ref.watch(passwordProvider.state).state=value;
                },
              ),
              Container(
                padding:EdgeInsets.all(8),
                child:Text(infoText),
              ),
             
              const SizedBox(height:8),
              Container(
                width:double.infinity,
                child:ElevatedButton(
                  child:Text('ログイン'),
                  style:ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () async{
                    try{
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signInWithEmailAndPassword(
                        email: email, 
                        password: password
                        );

                        final _isVerifired = await auth.currentUser?.emailVerified;
                        if(_isVerifired!=null){//nullの場合避ける
                          if(_isVerifired){//メール認証済み
                            final snapshot=await FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.currentUser?.uid)
                                .get();
                              final vari=snapshot.data()?['verification'];
                            if(vari){//firestoreに登録済み
                              ref.watch(userProvider.state).state=auth.currentUser;
                              final doc =await FirebaseFirestore.instance
                                .collection('users')
                                .doc(auth.currentUser!.uid)
                                .get();
                              ref.watch(groupidProvider.state).state=doc['gid'];
                              ref.watch(usernameProvider.state).state=doc['username'];
                              ref.watch(unamesProvider.state).state=[];
                              ref.watch(daProvider.state).state=[];
                              ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                              await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context){
                                  return ChatPage();
                              })
                            );
                            }else{//firestoreに登録していない
                              int count;
                              int n=0;
                              String gid="";
                              final snapshot=await FirebaseFirestore.instance
                              .collection('groups')
                              .orderBy('date', descending: true)
                              .limit(1)
                              .get();
                                count = snapshot.docs[0].data()['count'];
                                String id=snapshot.docs[0].id;
                                String pass="groups/"+id+"/users";
                                if(count>=300){//グループの人数指定
                                  final date=
                                    DateTime.now().toLocal().toIso8601String();
                                  await FirebaseFirestore.instance
                                    .collection('groups')
                                    .add({
                                      'count':1,
                                      'date':date,
                                    }).then((value) => {
                                      FirebaseFirestore.instance
                                        .collection('groups')
                                        .doc(value.id)
                                        .collection('users')
                                        .add({
                                          'uid':auth.currentUser!.uid,
                                        }),
                                        gid=value.id,
                                        groupid=gid
                                      }
                                    );
                                }
                                else{
                                  await FirebaseFirestore.instance
                                    .collection(pass)
                                    .add({
                                      'uid':auth.currentUser!.uid,
                                      });
                                      int c=count+1;
                                  await FirebaseFirestore.instance
                                    .collection('groups')
                                    .doc(id)
                                    .update({
                                      'count':c
                                    });
                                    gid=id;
                                    groupid=gid;
                                }
                                await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(auth.currentUser!.uid)
                                  .update({
                                    'email':email,
                                    'gid':gid,
                                    'verification':true
                                  });
                                ref.watch(userProvider.state).state=auth.currentUser;
                                ref.watch(groupidProvider.state).state=gid;
                                ref.watch(unamesProvider.state).state=[];
                                ref.watch(daProvider.state).state=[];
                                ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                                await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) {
                                  return ChatPage();
                                }),
                              );
                            }
                          }else{
                            ref.watch(infoTextProvider.state).state="メール認証をしてません";
                          }
                        }
                        


                        
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  }
                ),
              ),
              SizedBox(height:40),
              Container(
                width:double.infinity,
                height:30,
                color: Colors.white,
                child:OutlinedButton(
                  child:Text('登録をしていない方はこちら'),
                  onPressed: ()async{
                    try{
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return RegisterPage();
                        }),
                      );
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class TwitterLoginPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final infoText = ref.watch(infoTextProvider.state).state;
    final email= ref.watch(emailProvider.state).state;
    final password = ref.watch(passwordProvider.state).state;
    final username = ref.watch(usernameProvider.state).state;
    String groupid = ref.watch(groupidProvider.state).state;
    return Scaffold(
      body: Center(
        child:Container(
          padding:EdgeInsets.all(24),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:<Widget>[
              TextFormField(
                decoration:InputDecoration(labelText: 'メールアドレス'),
                onChanged: (String value){
                  ref.watch(emailProvider.state).state=value;
                },
              ),
              TextFormField(
                decoration:InputDecoration(labelText: 'パスワード'),
                obscureText: true,
                onChanged: (String value){
                  ref.watch(passwordProvider.state).state=value;
                },
              ),
              TextFormField(
                decoration:InputDecoration(labelText: 'ユーザー名'),
                onChanged: (String value){
                  ref.watch(usernameProvider.state).state=value;
                },
              ),
              Container(
                padding:EdgeInsets.all(8),
                child:Text(infoText),
              ),
              Container(
                width:double.infinity,
                child:ElevatedButton(
                  child:Text('ユーザー登録'),
                  onPressed: ()async{
                    try{
                      final twitterLogin = TwitterLogin(  
                        apiKey: 'JVlaFBVBeqlPQx1sPyOL1Rv4H',
                        apiSecretKey: 'kltfMpHuxWRWQIp4QI3nL2mxBFRHuwovt6zkR0oRJrcWdlvglx',
                        redirectURI: 'https://chat-3264d.firebaseapp.com/__/auth/handler',
                      );
                      final authResult = await twitterLogin.login();
                      switch (authResult.status) {
                        case TwitterLoginStatus.loggedIn:
                          // success
                          print('====== Login success ======');
                          break;
                        case TwitterLoginStatus.cancelledByUser:
                          // cancel
                          print('====== Login cancel ======');
                          break;
                        case TwitterLoginStatus.error:
                        case null:
                          // error
                          print('====== Login error ======');
                          break;
                      }
                      final FirebaseAuth auth=FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password
                        );
                        
                        int count;
                        int n=0;
                        String gid="";
                        final snapshots = FirebaseFirestore.instance
                        .collection('groups')
                        .orderBy('date', descending: true)
                        .limit(1)
                        .snapshots();
                        
                        final a=snapshots.take(1);//これやんないとなんかfor文でずっと繰り返される
                        await for (var snapshot in a){
                          count = snapshot.docs[0].data()['count'];
                          String id=snapshot.docs[0].id;
                          String pass="groups/"+id+"/users";
                          if(count>=300){//グループの人数指定
                            final date=
                              DateTime.now().toLocal().toIso8601String();
                            await FirebaseFirestore.instance
                              .collection('groups')
                              .add({
                                'count':1,
                                'date':date,
                              }).then((value) => {
                                FirebaseFirestore.instance
                                  .collection('groups')
                                  .doc(value.id)
                                  .collection('users')
                                  .add({
                                    'uid':result.user!.uid,
                                  }),
                                  gid=value.id,
                                  groupid=gid
                                }
                              );
                          }
                          else{
                            await FirebaseFirestore.instance
                              .collection(pass)
                              .add({
                                'uid':result.user!.uid,
                                });
                                int c=count+1;
                            await FirebaseFirestore.instance
                              .collection('groups')
                              .doc(id)
                              .update({
                                'count':c
                              });
                              gid=id;
                              groupid=gid;
                          }
                          break;
                        }
                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(result.user!.uid)
                          .set({
                            'username':username,
                            'email':email,
                            'gid':gid,
                          });
                        ref.watch(userProvider.state).state=result.user;
                        ref.watch(groupidProvider.state).state=gid;
                        ref.watch(unamesProvider.state).state=[];
                        ref.watch(daProvider.state).state=[];
                        ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                        await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ChatPage();
                        }),
                      );
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  },
                ),
              ),
              const SizedBox(height:8),
              Container(
                width:double.infinity,
                child:OutlinedButton(
                  child:Text('ログイン'),
                  onPressed: () async{
                    try{
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      await auth.signInWithEmailAndPassword(
                        email: email, 
                        password: password
                        );
                        ref.watch(userProvider.state).state=auth.currentUser;
                        final doc =await FirebaseFirestore.instance
                            .collection('users')
                            .doc(auth.currentUser!.uid)
                            .get();
                          ref.watch(groupidProvider.state).state=doc['gid'];
                        ref.watch(unamesProvider.state).state=[];
                        ref.watch(daProvider.state).state=[];
                        ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context){
                            return ChatPage();
                          })
                        );
                    }catch(e){
                      ref.read(infoTextProvider.state).state =
                      '失敗しました：${e.toString()}';
                      print(e.toString());
                    }
                  }
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}
