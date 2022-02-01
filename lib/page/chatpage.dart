import 'package:chat/importer.dart';
import 'profilepage.dart';
import 'loginpage.dart';
import 'addPostPage.dart';
import 'chatViewpage.dart';

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
            SizedBox(height:50),
            Expanded(
              child:Scrollbar(
                child: FutureBuilder(
                  future:ref.watch(dProvider),
                  builder:(BuildContext context,AsyncSnapshot<List<dynamic>> b){
                    return RefreshIndicator(
                      onRefresh: ()async{
                        ref.watch(unamesProvider.state).state=[];
                        ref.watch(daProvider.state).state=[];
                        ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                      },
                      child:ListView.builder(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                          Text(ref.watch(daProvider.state).state[i]["text"]),
                                          SizedBox(height: 8,),
                                          Row(
                                            children: [
                                              Icon(Icons.chat_bubble,size:15),
                                              SizedBox(width:5),
                                              Text(ref.watch(daProvider.state).state[i]["count"].toString()=="0" ? "" : ref.watch(daProvider.state).state[i]["count"].toString()),
                                            ],
                                          ),
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
                                  child:SizedBox(height:10),
                                ),
                              ],
                            ),
                            onTap: ()async{
                              ref.watch(replypathProvider.state).state=ref.watch(daProvider.state).state[i].id;
                               ref.watch(replyDateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                               ref.watch(replyrouteProvider.state).state=FirebaseFirestore.instance
                                          .collection('groups')
                                          .doc(ref.watch(groupidProvider.state).state)
                                          .collection('chats')
                                          .doc(ref.watch(replypathProvider.state).state);
                              Map<String,dynamic> data={
                                'text':ref.watch(daProvider.state).state[i]['text'],
                                'date':ref.watch(daProvider.state).state[i]['date'],
                                'uid':ref.watch(daProvider.state).state[i]['uid'],
                                'username':ref.watch(unamesProvider.state).state[i],
                                'path':ref.watch(daProvider.state).state[i].id,
                                'future':ref.watch(replyrouteProvider.state).state
                              };
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context){
                                  return chatViewPage(data);
                                })
                              ).then((value){
                                ref.watch(replyrouteProvider.state).state="";
                                ref.watch(replysProvider.state).state=[];
                                ref.watch(replysunamesProvider.state).state=[];
                                ref.watch(replyDateProvider.state).state=[""];
                                ref.watch(replyPageProvider.state).state=0;
                              });
                            },
                          );
                          }
                          else{
                            return Text("err ConnectionState:${b.connectionState.toString()}");
                          }
                        },
                      ),
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
                      return RegisterPage();
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