
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//自身のユーザー情報
final userProvider = StateProvider((ref){
  return FirebaseAuth.instance.currentUser;
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

final groupProvider = StreamProvider.autoDispose((ref){
  return FirebaseFirestore.instance
    .collection('groups')
    .orderBy('date')
    .snapshots();
});

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ProviderScope(
      child: ChatApp()
    ),
  );
}

class ChatApp extends StatelessWidget {
  const ChatApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context, WidgetRef ref){
    final infoText = ref.watch(infoTextProvider.state).state;
    final email= ref.watch(emailProvider.state).state;
    final password = ref.watch(passwordProvider.state).state;
    final username = ref.watch(usernameProvider.state).state;
    final AsyncValue<QuerySnapshot> asyncGroupQuery=ref.watch(groupProvider);
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
                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(result.user!.uid)
                          .set({
                            'username':username,
                            'email':email
                          });
                        final snapshots = FirebaseFirestore.instance
                        .collection('groups/group/users')
                         .where("name", isEqualTo: "a")
                        .orderBy('date')
                        .limit(1)
                        .snapshots();
                        await for (var snapshot in snapshots){
                          for(var message in snapshot.docs){
                            print(message.data());
                          }
                        }
                        ref.watch(userProvider.state).state=result.user;
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
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context){
                            return ChatPage();
                          })
                        );
                    }catch(e){

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

class ChatPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){

    return Scaffold(

    );
  }
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
