import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//自身のユーザー情報
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
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: MyApp()
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loginCheck(),
    );
  }
}
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


class loginCheck extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){
    if(ref.watch(userProvider.state).state==null){
        
      return LoginPage();
    }
    else{
      if(ref.watch(groupidProvider.state).state=="")getu(ref);
      return ChatPage();
    }
  }
}

class LoginPage extends ConsumerWidget{
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
                          if(count>=1){//グループの人数指定
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
class ChatPage extends ConsumerWidget{
  ScrollController _controller=new ScrollController();
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final User user=ref.watch(userProvider.state).state!;
    _controller.addListener(() { 
      if (_controller.hasClients){
         _controller.jumpTo(0);
         print('err');
      }
    });
    return Scaffold(
      body:Center(
        child: Column(
          children: <Widget>[
            Container(
              padding:EdgeInsets.all(32),
              child:Text("ログイン情報${user.email}"),
            ),
            Expanded(
              child:Scrollbar(
                child: FutureBuilder(
                  future:ref.watch(dProvider),
                  builder:(BuildContext context,AsyncSnapshot<List<dynamic>> b){
                    return ListView.builder(
                      itemCount: ref.watch(daProvider.state).state.length,
                      itemBuilder:(context,i){
                        Future<String> a;
                        WidgetsBinding.instance!.addPostFrameCallback((_) async{
                        if(i%19==0&&i!=0&&ref.watch(nowPageProvider.state).state<i){
                            ref.watch(lastdateProvider.state).state=[ref.watch(daProvider.state).state[i]['date']];
                            ref.watch(nowPageProvider.state).state=i;
                          }
                        });
                        if(b.connectionState==ConnectionState.done||b.connectionState==ConnectionState.waiting){
                          return GestureDetector(
                          child:Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                padding:EdgeInsets.only(left:10,top:5),
                                child:Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.people,size:45),
                                    SizedBox(width:10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children:[
                                        Row(
                                          children: [
                                             Text(ref.watch(unamesProvider.state).state[i]+"　　",
                                                    style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text(getConversionDate(ref.watch(daProvider.state).state[i]["date"])),
                                          ],
                                        ),
                                        Text(ref.watch(daProvider.state).state[i]["text"])
                                      ]
                                    ),
                                  ],
                                )
                              ),
                              Container(
                                width:double.infinity,
                                decoration: BoxDecoration(
                                  border:const Border(
                                    bottom:const BorderSide(
                                      color:Colors.black12,
                                      width:1
                                    ),
                                  ),
                                ),
                                child:SizedBox(height:20),
                              ),
                              /*Container(
                                alignment: Alignment.centerLeft,
                                width:double.infinity,
                                padding:EdgeInsets.only(bottom:20),
                                decoration: BoxDecoration(
                                  border:const Border(
                                    bottom:const BorderSide(
                                      color:Colors.black12,
                                      width:1
                                    ),
                                  ),
                                ),
                                child:ListTile(
                                  leading: Icon(Icons.people),
                                  title:Column(
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.center,
                                        width:double.infinity,
                                        padding:EdgeInsets.only(top:5),
                                        child:Row(
                                          children: [
                                            Text(ref.watch(unamesProvider.state).state[i]+"　　",
                                                  style: TextStyle(fontWeight: FontWeight.bold),),
                                            Text(getConversionDate(ref.watch(daProvider.state).state[i]["date"])),
                                          ],
                                        )
                                      ),
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child:Text(ref.watch(daProvider.state).state[i]["text"]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),*/
                            ],
                          ),
                        );
                        }
                        else{
                          return Text("err ConnectionState:${b.connectionState.toString()}");
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              child: Text(ref.watch(usernameProvider.state).state),
            ),
            ListTile(
              title:Text("プロフィール"),
              onTap: ()async{
                final snapshot=await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(ref.watch(userProvider.state).state!.uid)
                                      .get();
                ref.watch(userinfoProvider.state).state=snapshot.data()!;
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context){
                    return ProfilePage();
                  })
                );
              },
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child:ListTile(
                title:Text("ログアウト"),
                  onTap: ()async{
                    await FirebaseAuth.instance.signOut();
                    ref.watch(userProvider.state).state=null;
                    ref.watch(groupidProvider.state).state="";
                    await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) {
                      return LoginPage();
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child:Icon(Icons.add),
        onPressed: ()async{
          await Navigator.of(context).push(
            MaterialPageRoute(builder:(context){
              return AddPostPage();
            }),
          );
        },
      ),
    );
  }
}

class AddPostPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final user = ref.watch(userProvider.state).state!;
    final messageText = ref.watch(messageProvider.state).state;
    return Scaffold(
      body:Center(
        child:Container(
          padding:EdgeInsets.all(32),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText:'投稿メッセージ'),
                keyboardType:TextInputType.multiline,
                maxLines: 3,
                onChanged: (String value){
                  ref.read(messageProvider.state).state=value;
                },
              ),
              const SizedBox(height:8),
              Container(
                width:double.infinity,
                child:ElevatedButton(
                  child:Text('投稿'),
                  onPressed: ()async{
                    if(messageText!=null){
                      final date=
                      DateTime.now().toLocal().toIso8601String();
                      final uid=user.uid;
                      await FirebaseFirestore.instance
                        .collection("groups")
                        .doc(ref.watch(groupidProvider.state).state)
                        .collection('chats')
                        .add({
                          'uid':uid,
                          'date':date,
                          'text':messageText,
                        });
                      ref.watch(unamesProvider.state).state=[];
                      ref.watch(daProvider.state).state=[];
                      ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                      Navigator.of(context).pop();
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

class ProfilePage extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Scaffold(
      body: Center(
        child:Container(
          padding: EdgeInsets.all(24),
            child: Column(
            children: <Widget>[
              SizedBox(height:32),
              Text("ユーザー名"),
              TextFormField(
                  keyboardType:TextInputType.multiline,
                  initialValue:ref.watch(userinfoProvider.state).state['username'],
                  onChanged: (String value){
                    ref.watch(changeUnameProvider.state).state=value;
                  },
              ),
              Container(
                child:ElevatedButton(
                  child:Text("変更"),
                  onPressed: ()async{
                    try{
                      ref.watch(usernameProvider.state).state=ref.watch(changeUnameProvider.state).state;
                      await FirebaseFirestore.instance
                        .collection('users')
                        .doc(ref.watch(userProvider.state).state!.uid)
                        .update({
                          "username": ref.watch(usernameProvider.state).state
                        })
                        .then((value){
                          ref.watch(unamesProvider.state).state=[];
                          ref.watch(daProvider.state).state=[];
                          ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                        });
                        Navigator.of(context).pop();
                    }catch(e){
                      ref.watch(messageProvider.state).state="エラー:${e.toString()}";
                    }
                  },
                ),
              ),
              Text(ref.watch(messageProvider.state).state),
            ]
          ),
        ),
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
