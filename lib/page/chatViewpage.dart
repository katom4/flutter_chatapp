import 'package:chat/importer.dart';
import 'package:chat/page/addPostreplyPage.dart';
import 'chatpage.dart';

final replyDateProvider = StateProvider((ref){
return [""];
});

final replypathProvider = StateProvider((ref){
  return "";
});

final replysProvider = StateProvider((ref){
  return [];
});

final replysunamesProvider = StateProvider((ref){
  return [];
});

final replyPageProvider = StateProvider.autoDispose((ref){
  return 0;
});

final replyrouteProvider=StateProvider((ref){
  dynamic a;
  return a;
});

final popupProvider=StateProvider((ref){
  return false;
});

final replysfutureProvider = StateProvider.autoDispose.family<Future<List>,dynamic>((ref,reference)async{
  if(ref.watch(replyrouteProvider.state).state!=reference||ref.watch(replyDateProvider.state).state=="")return [];
  List<dynamic> datalist =[];
    await reference
                .collection('reply')
                .orderBy('date',descending: true)
                .limit(20)
                .startAfter([ref.watch(replyDateProvider.state).state])
                .get()
                .then((value){
                  
                  for(var s in value.docs){
                    datalist.add(s);
                    ref.watch(replysProvider.state).state.add(s);
                  }
                });
    for(var a in datalist){
      String i = await getuname(a["uid"]);
      ref.watch(replysunamesProvider.state).state.add(i);
    }
   return datalist;
});
class chatViewPage extends ConsumerWidget{
  chatViewPage(this.data);
  Map<String,dynamic> data;
  
  @override
  Widget build(BuildContext context, WidgetRef ref){
    return Scaffold(
      body:Center(
        child: Column(
          children: <Widget>[
            SizedBox(height:50),
            Container(
              child:Column(
                children: <Widget>[
                  Row(
                    children: [
                      SizedBox(width:15),
                      Icon(Icons.people,size:55),
                      SizedBox(width:5),
                      Text(
                        data['username'],
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Spacer(),
                      data['uid']==ref.watch(userProvider.state).state?.uid ? 
                      Column(
                        children: [
                          IconButton(
                            icon:new Icon(Icons.more_vert),
                            onPressed: ()async{
                              ref.watch(popupProvider.state).state=!ref.watch(popupProvider.state).state;
                            },
                          ),
                          ref.watch(popupProvider.state).state ?
                          ElevatedButton(
                            onPressed: ()async{
                              await ref.watch(replyrouteProvider.state).state.delete();
                              ref.watch(unamesProvider.state).state=[];
                              ref.watch(daProvider.state).state=[];
                              ref.watch(lastdateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                              ref.watch(replyrouteProvider.state).state="";
                              ref.watch(replysProvider.state).state=[];
                              ref.watch(replysunamesProvider.state).state=[];
                              ref.watch(replyDateProvider.state).state=[""];
                              ref.watch(replyPageProvider.state).state=0;
                              Navigator.of(context).pop();
                            },
                            child: Text("削除"),
                            ):Text("")
                        ],
                      ) :Text(""),
                      SizedBox(width:10)
                    ],
                  ),
                  Row(
                    children:<Widget>[
                      SizedBox(width:30),
                      Text(
                        data['text'],
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(getConversionDate(data['date'])),
                      IconButton(
                        icon: Icon(
                          Icons.chat_bubble,
                          size: 30,
                          color: Colors.blue,
                        ),
                        onPressed: ()async{
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (context){
                              return AddPostreplyPage();
                            })
                          ).then((value){
                            //ref.watch(replypathProvider.state).state="";
                            ref.watch(replyrouteProvider.state).state=data['future'];
                            ref.watch(replysProvider.state).state=[];
                            ref.watch(replysunamesProvider.state).state=[];
                            ref.watch(replyDateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                            ref.watch(replyPageProvider.state).state=0;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child:Scrollbar(
                child: FutureBuilder(
                  future:ref.watch(replysfutureProvider(data['future'])),
                  builder:(BuildContext context,AsyncSnapshot<List<dynamic>> b){
                    return RefreshIndicator(
                      onRefresh: ()async{
                        ref.watch(replyrouteProvider.state).state=data['future'];
                        ref.watch(replysProvider.state).state=[];
                        ref.watch(replysunamesProvider.state).state=[];
                        ref.watch(replyDateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                        ref.watch(replyPageProvider.state).state=0;
                      },
                      child:ListView.builder(
                        itemCount: ref.watch(replysProvider.state).state.length,
                        itemBuilder:(context,i){
                          Future<String> a;
                          WidgetsBinding.instance!.addPostFrameCallback((_) async{
                          if(i%19==0&&i!=0&&ref.watch(replyPageProvider.state).state<i){
                              ref.watch(replyDateProvider.state).state=[ref.watch(replysProvider.state).state[i]['date']];
                              ref.watch(replyPageProvider.state).state=i;
                            }
                          });
                          if(b.connectionState==ConnectionState.done||b.connectionState==ConnectionState.waiting){
                            return GestureDetector(
                            child:Column(
                              children: <Widget>[
                                Container(
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
                                              Text(ref.watch(replysunamesProvider.state).state[i]+"　　",
                                                      style: TextStyle(fontWeight: FontWeight.bold),),
                                              Text(getConversionDate(ref.watch(replysProvider.state).state[i]["date"])),
                                            ],
                                          ),
                                          Text(ref.watch(replysProvider.state).state[i]["text"]),
                                          SizedBox(height: 8,),
                                          Row(
                                            children: [
                                              Icon(Icons.chat_bubble,size:15),
                                              SizedBox(width:5),
                                              Text(ref.watch(replysProvider.state).state[i]["count"].toString()=='0' ? "" : ref.watch(replysProvider.state).state[i]["count"].toString()),
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
                                              Text(getConversionDate(ref.watch(replysProvider.state).state[i]["date"])),
                                            ],
                                          )
                                        ),
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          child:Text(ref.watch(replysProvider.state).state[i]["text"]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),*/
                              ],
                            ),
                            onTap: ()async{
                              
                              ref.watch(replyrouteProvider.state).state=data['future']
                                          .collection('reply')
                                          .doc(ref.watch(replysProvider.state).state[i].id);
                              //data['path']=await ref.watch(replysProvider.state).state[i].id;
                              
                              Map<String,dynamic> nextdata={
                                'text':ref.watch(replysProvider.state).state[i]['text'],
                                'date':ref.watch(replysProvider.state).state[i]['date'],
                                'uid':ref.watch(replysProvider.state).state[i]['uid'],
                                'username':ref.watch(replysunamesProvider.state).state[i],
                                'path':ref.watch(replysProvider.state).state[i].id,
                                'future':data['future']
                                .collection('reply')
                                          .doc(ref.watch(replysProvider.state).state[i].id)
                              };
                              
                              ref.watch(replyPageProvider.state).state=0;
                              ref.watch(replysProvider.state).state=[];
                              //ref.watch(replyDateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (context){
                                  return chatViewPage(nextdata);
                                })
                              ).then((value){
                                //ref.watch(replypathProvider.state).state="";
                                ref.watch(replyrouteProvider.state).state=data['future'];
                                ref.watch(replysProvider.state).state=[];
                                ref.watch(replysunamesProvider.state).state=[];
                                ref.watch(replyDateProvider.state).state=[DateTime.now().toLocal().toIso8601String()];
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
    );
  }
}