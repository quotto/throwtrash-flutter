import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/viewModels/alarm_model.dart';

class AlarmPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AlarmPage();
  }
}

class _AlarmPage extends State<AlarmPage> {
  late AlarmModel _alarmModel;
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _alarmModel = AlarmModel(Provider.of<AlarmServiceInterface>(context));
    _alarmModel.addListener(() {
      if(_alarmModel.submitState == AlarmSubmitState.COMPLETE) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text('アラームを設定しました', style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
        ));
      } else if(_alarmModel.submitState == AlarmSubmitState.ERROR) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text('エラーが発生しました', style: TextStyle(color: Colors.white)),
          duration: Duration(seconds: 2),
        ));
      }
    });
    return Scaffold(
        appBar: AppBar(
          title: Text('アラーム設定'),
        ),
        body: ListenableBuilder(listenable: _alarmModel, builder: (BuildContext context, Widget? child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SwitchListTile(
                  title: Text('アラーム'),
                  value: _alarmModel.isAlarmEnabled,
                  onChanged: (value) {
                    _alarmModel.toggleAlarmEnabled();
                  },
                ),
                ListTile(
                  title: Text('アラーム時刻'),
                  trailing: Text('${_alarmModel.hour}:${_alarmModel.minute}'),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(hour: _alarmModel.hour, minute: _alarmModel.minute),
                    );
                    if(time != null) {
                      _alarmModel.setAlarmTime(time.hour, time.minute);
                    }
                  },
                ),
                FilledButton(
                  onPressed: _alarmModel.submitState == AlarmSubmitState.SUBMITTING ? null : () async {
                    _alarmModel.submitAlarmTime();
                  },
                  child: Text('設定'),
                ),
                if(_alarmModel.submitState == AlarmSubmitState.SUBMITTING)
                  CircularProgressIndicator()
              ],
            ),
          );
        })
    );
  }
}