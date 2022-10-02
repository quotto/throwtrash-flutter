import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:throwtrash/edit.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:provider/provider.dart';

class TrashList extends StatefulWidget {
  @override
  _TrashListState createState() => _TrashListState();
}

class _TrashListState extends State<TrashList> {
  final _successSnackBar = SnackBar(
    content: Text('削除しました'),
    duration: Duration(
      seconds: 1
    ),
  );
  final _failedSnackBar = SnackBar(
    content: Text('削除に失敗しました'),
    duration: Duration(
        seconds: 1
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('登録されているゴミ出し予定'),
      ),
      body: Container(
          child: Consumer<ListModel>(
            builder: (context, list, child) {
              return ListView.separated(
                  itemCount: list.trashList.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Theme
                          .of(context)
                          .dividerColor),
                  itemBuilder: (context, index) {
                    TrashListData trashData = list.trashList[index];
                    print('$index:${trashData.id}');
                    return Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(trashData.name,style: TextStyle(
                                  fontSize: 24
                                ),),
                                Column(
                                    children: trashData.schedules.map<Widget>((
                                        schedule) => Text(schedule)
                                    ).toList()
                                )
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context){
                                      return ChangeNotifierProvider<EditModel>(
                                        create: (context) => EditModel(
                                            Provider.of<TrashDataServiceInterface>(context, listen: false),
                                          ),
                                        child: EditItemMain.update(trashData.id)
                                      );
                                    },                                  )
                              ).then((result) {
                                if(result != null && result) {
                                  list.reload();
                                }
                              });
                            },
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: IconButton(
                          icon: Icon(Icons.delete_forever),
                          iconSize: 32,
                          color: Theme
                              .of(context)
                              .accentColor,
                          onPressed: () {
                            list.deleteTrashData(index).then((result){
                              if(result) {
                                ScaffoldMessenger.of(context).showSnackBar(_successSnackBar);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(_failedSnackBar);
                              }
                            });
                          },
                        ))
                      ],
                    );
                  }
              );
            },
          )
      ),
    );
  }
}
