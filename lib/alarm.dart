  import 'package:flutter/material.dart';
  import 'package:flutter/widgets.dart';
  import 'package:provider/provider.dart';
  import 'package:throwtrash/viewModels/alarm_model.dart';
  class AlarmView extends StatefulWidget {
    @override
    _AlarmViewState createState() => _AlarmViewState();
  }

  class _AlarmViewState extends State<AlarmView> {
    final _failedSnackBar = SnackBar(
      backgroundColor: Colors.pink,
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

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('アラームの設定')
          ),
          body: Consumer<AlarmModel>(
        builder: (context, alarmModel, child) {
          return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('通知する'),
                        Switch(
                            value: alarmModel.alarm.enabled,
                            onChanged: (changedValue) {
                              alarmModel.changeEnabled(changedValue);
                            },
                          )
                      ]
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text('ゴミ出し予定が無い日も通知する'),
                        Checkbox(
                          value: alarmModel.alarm.everydayFlg,
                          onChanged: alarmModel.alarm.enabled ? (changedValue) {
                            alarmModel.changeEverydayFlag(changedValue!);
                          } : null,
                        )
                      ]
                    ),
                    Text('通知する時間'),
                    FractionallySizedBox(
                      widthFactor: 1.0,
                        child: Center(
                        child:TextField(
                          controller: TextEditingController(
                            text: alarmModel.alarmTime
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none
                          ),
                          style: TextStyle(
                            fontSize: 32
                          ),
                          textAlign: TextAlign.center,
                          readOnly: true,
                          onTap: alarmModel.alarm.enabled ? () async {
                            final selectedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: alarmModel.alarm.hour,
                                  minute: alarmModel.alarm.minute
                                )
                            );
                            if(selectedTime != null) {
                              alarmModel.changeTime(selectedTime);
                            }
                          } : null
                        )
                        )),
                    Expanded(
                      child: Center(
                          child: ElevatedButton(
                        child: Text('設定'),
                        onPressed:  alarmModel.state == AlarmState.PROCESSING ? null :
                            () async {
                              if(await alarmModel.setAlarm()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _successSnackBar);
                                await Future.delayed(Duration(milliseconds: 500));
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _failedSnackBar);
                                await Future.delayed(Duration(milliseconds: 500));
                              }
                            },
                      )
                    ))
                    ])
                    );
        }
      )
      );
    }
  }
