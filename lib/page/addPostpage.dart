import 'package:chat/importer.dart';

class AddPostPage extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){
    final user = ref.watch(userProvider.state).state!;
    final messageText = ref.watch(messageProvider.state).state;
    return Scaffold(
      appBar: AppBar(
        
      ),
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