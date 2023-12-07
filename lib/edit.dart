import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:throwtrash/exclude_date.dart';
import 'package:throwtrash/models/trash_schedule.dart';
import 'package:throwtrash/usecase/trash_data_service.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/viewModels/exclude_date_model.dart';

class EditItemMain extends StatefulWidget {
  String _id = "";
  EditItemMain();
  EditItemMain.update(this._id);

  @override
  _EditItemMainState createState() {
    return _EditItemMainState(this._id);
  }
}

class _EditItemMainState extends State<EditItemMain> {
  final String _id;

  _EditItemMainState(this._id);


  final _failedSnackBar = SnackBar(
    backgroundColor: Colors.pinkAccent,
      content: Text('設定に失敗しました', style: TextStyle(color: Colors.white)),
    duration: Duration(
        seconds: 1
    ),
  );

  final _successSnackBar = SnackBar(
    backgroundColor: Colors.green,
    content: Text('設定しました',style: TextStyle(color: Colors.white),),
    duration: Duration(
        seconds: 1
    ),
  );


  final Map<String, Widget> _ScheduleTypeToggles = {
    "weekday":Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Text('毎週', textAlign: TextAlign.center)),
    "month":  Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Text('毎月同じ日', textAlign: TextAlign.center)),
    "biweek": Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Text('特定の週', textAlign: TextAlign.center)),
    "evweek": Padding(padding: EdgeInsets.symmetric(vertical: 10.0), child: Text('隔週', textAlign: TextAlign.center)),
  };



  final List<String> _WeekdayList = [
    '日曜日',
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日'
  ];

  final _formKey = GlobalKey<FormState>();

  Widget _scheduleInput(int scheduleNumber, TrashSchedule schedule) {
    EditModel model = Provider.of<EditModel>(context);
    switch (schedule.type) {
      case 'weekday':
        return DropdownButton<String>(
          value: schedule.value,
          items: new List.generate(7, (index) {
            return DropdownMenuItem(
              value: index.toString(),
              child: Text(_WeekdayList[index]),
            );
          }),
          onChanged: (changedValue) {
            if (changedValue != null) {
              model.changeValue(scheduleNumber, changedValue);
            }
          },
        );
      case 'month':
        return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text('毎月'),
          Expanded(
              child: TextFormField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            controller: TextEditingController(text: schedule.value),
            decoration: InputDecoration(hintText: '日にちを入力'),
            onChanged: (changedValue) {
              model.changeValue(scheduleNumber, changedValue);
            },
            validator: (String? inputValue) {
              try {
                return inputValue != null &&
                        int.parse(inputValue) > 0 &&
                        int.parse(inputValue) < 32
                    ? null
                    : '日にちは1～31の値で入力してください';
              } catch (Exception) {
                return '日にちは数字で入力してください';
              }
            },
          )),
          Expanded(child: Text('日'))
        ]);
      case 'biweek':
        List<String> initValue = schedule.value.split('-');
        return Row(children: [
          DropdownButton<int>(
            value: int.parse(initValue[1]),
            items: [1, 2, 3, 4, 5].map((index) {
              return DropdownMenuItem(value: index, child: Text('第$index'));
            }).toList(),
            onChanged: (int? changedValue) {
              if (changedValue != null) {
                model.changeValue(scheduleNumber,
                    '${initValue[0]}-${changedValue.toString()}');
              }
            },
          ),
          DropdownButton<String>(
              value: initValue[0],
              items: new List.generate(_WeekdayList.length, (index) {
                return DropdownMenuItem(
                    value: index.toString(), child: Text(_WeekdayList[index]));
              }).toList(),
              onChanged: (String? changedValue) {
                if (changedValue != null) {
                  model.changeValue(
                      scheduleNumber, '${changedValue}-${initValue[1]}');
                }
              })
        ]);
      case 'evweek':
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            DropdownButton<int>(
                value: schedule.value['interval'],
                items: [2, 3, 4].map((interval) {
                  return DropdownMenuItem(
                    value: interval,
                    child: Text('$interval週に1回'),
                  );
                }).toList(),
                onChanged: (int? changedValue) {
                  if (changedValue != null) {
                    model.changeEvweekValue(
                        scheduleNumber,
                        schedule.value['weekday'],
                        changedValue,
                        schedule.value['start']);
                  }
                }),
            Text('の'),
            DropdownButton<String>(
                value: schedule.value['weekday'],
                items: new List.generate(_WeekdayList.length, (index) {
                  return DropdownMenuItem(
                      value: index.toString(),
                      child: Text(_WeekdayList[index]));
                }).toList(),
                onChanged: (String? changedValue) {
                  if (changedValue != null) {
                    model.changeEvweekValue(scheduleNumber, changedValue,
                        schedule.value['interval'], schedule.value['start']);
                  }
                })
          ]),
          TextField(
            controller: TextEditingController(
              text: schedule.value['start'],
            ),
            decoration: InputDecoration(
              labelText: '直近のゴミ出し日を選択',
            ),
            readOnly: true,
            onTap: () async {
              final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 1));

              if (selectedDate != null) {
                model.changeEvweekValue(
                    scheduleNumber,
                    schedule.value['weekday'],
                    schedule.value['interval'],
                    selectedDate.toIso8601String().substring(0, 10));
              }
            },
          )
        ]);
      default:
        return Text('');
    }
  }

  Widget _scheduleForm(int scheduleNumber, TrashSchedule schedule) {
    EditModel model = Provider.of<EditModel>(context);
    return Container(
        decoration: BoxDecoration(
            color: (scheduleNumber + 1) % 2 == 0
                ? Colors.grey[200]
                : Theme.of(context).canvasColor),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width
                ),
                padding: EdgeInsets.fromLTRB(0,16,0,0),
                        child: CupertinoSegmentedControl<String>(
                      children: _ScheduleTypeToggles,
                      onValueChanged: ((String newValue){
                        model.changeScheduleType(scheduleNumber, newValue) ;
                      }),
                      groupValue: model.schedules[scheduleNumber].type,
                )
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      flex: 7,
                      child: Padding(
                              padding: EdgeInsets.only(left: 16,right:16),
                              child: _scheduleInput(scheduleNumber, schedule)
                            )
                      )
                  ,
                  Flexible(
                      flex: 3,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.delete_forever),
                          iconSize: 32,
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () => model.removeSchedule(scheduleNumber),
                        ))
                      )
                  ]
              ),
        ]));
  }

  Widget _allScheduleList(List<TrashSchedule> schedules) {
    EditModel model = Provider.of<EditModel>(context);
    List<Widget> children = [];
    int index = 0;
    schedules.forEach((schedule) {
      children.add(_scheduleForm(index, schedule));
      index++;
    });
    if (schedules.length < 3) {
      children.add(IconButton(
        icon: Icon(Icons.add_circle_outline),
        iconSize: 32,
        color: Theme.of(context).primaryColor,
        onPressed: () {
          model.addSchedule();
        },
      ));
    }

    return Expanded(
        flex: 1,
        child: ListView(
          children: children
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    EditModel model = Provider.of<EditModel>(context, listen: false);
    print('edit Id: $_id');
    if(_id.isNotEmpty) {
      if(!model.loadModel(_id)) {
        return Center(
            child: Text('データの読み込みに失敗しました')
        );
      }
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('編集'),
        ),
        body: Consumer<EditModel>(builder: (context, editModel, child) {
          return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        value: editModel.trash.type,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            editModel.changeTrashType(newValue);
                          }
                        },
                        items: TrashDataService.trashNameMap.keys
                            .map<DropdownMenuItem<String>>((key) {
                          return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                  TrashDataService.trashNameMap.containsKey(key)
                                      ? TrashDataService.trashNameMap[key]!
                                      : ''));
                        }).toList(),
                        style: TextStyle(
                            fontSize: 24,
                            color:
                                Theme.of(context).textTheme.bodyLarge!.color),
                        underline: Container(
                            height: 2, color: Theme.of(context).primaryColor),
                      ),
                      Visibility(
                          visible: editModel.trash.type == 'other',
                          child: Container(
                              height: 100,
                              child: TextFormField(
                                maxLength: 20,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  hintText: 'ゴミの名前を入力してください',
                                ),
                                validator: (String? value) {
                                  if (editModel.trash.type == 'other' &&
                                      (value != null && value.length == 0)) {
                                    return 'ゴミの名前を入力してください';
                                  }
                                  return null;
                                },
                                onChanged: (changedValue) {
                                  editModel.changeTrashName(changedValue);
                                },
                              )))
                    ]),
                _allScheduleList(editModel.schedules),
                Container(
                  padding: EdgeInsets.only(bottom: 32.0),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                    ),
                    onPressed: editModel.editState == EditState.PROCESSING ? null : () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                          ChangeNotifierProvider<ExcludeViewModel>(create: (create)=>
                            ExcludeViewModel.load(editModel.excludes),
                            child: ExcludeDateView(),
                          )
                        )
                      ).then((result){
                        if(result != null) {
                          editModel.setExcludeDate((result as ExcludeViewModel).excludeDates);
                        }
                      });
                    },
                    child: Text('例外日の設定',style: TextStyle(color:  Colors.white)),
                  )
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 32.0),
                  alignment: Alignment.center,
                    child: ElevatedButton(
                      key: Key('submit'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                      ),
                      onPressed: editModel.editState == EditState.PROCESSING ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          if(await editModel.submitTrashData()) {
                            ScaffoldMessenger.of(context).showSnackBar(_successSnackBar);
                            await Future.delayed(Duration(milliseconds: 500));
                            Navigator.pop(context, true);
                          } else if(editModel.editState == EditState.ERROR) {
                            ScaffoldMessenger.of(context).showSnackBar(_failedSnackBar);
                          }
                        }
                      },
                      child: editModel.editType == EditType.NEW ?
                        Text('登録',style: TextStyle(color:  Colors.white))  :
                        Text('更新',style: TextStyle(color:  Colors.white))

                    )
                )
              ]));
        }));
  }
}
