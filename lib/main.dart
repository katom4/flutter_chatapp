import 'importer.dart';
import 'page/chatpage.dart';
import 'page/loginpage.dart';
import 'state.dart';
import 'func.dart';

//自身のユーザー情報
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
      appBar: AppBar(
        
      ),
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
