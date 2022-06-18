import 'package:chat/importer.dart';
import 'chatViewpage.dart';

class AddPostreplyPage extends ConsumerWidget{
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
                      final snapshots =  await ref.watch(replyrouteProvider.state).state.get();
                      int inc=snapshots.data()['count']+1;
                      await ref.watch(replyrouteProvider.state).state
                        .update({
                          'count':inc
                        });
                      await ref.watch(replyrouteProvider.state).state
                        .collection('reply')
                        .add({
                          'uid':uid,
                          'date':date,
                          'text':messageText,
                          'count':0
                        });
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
