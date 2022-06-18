import 'package:chat/importer.dart';

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