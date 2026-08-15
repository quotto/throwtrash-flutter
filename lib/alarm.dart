import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/view_common/app_feedback.dart';
import 'package:throwtrash/viewModels/alarm_model.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AlarmPage();
  }
}

class _AlarmPage extends State<AlarmPage> {
  late AlarmModel _alarmModel;

  @override
  Widget build(BuildContext context) {
    _alarmModel = AlarmModel(Provider.of<AlarmServiceInterface>(context));
    _alarmModel.initialize();
    _alarmModel.addListener(() {
      if (_alarmModel.submitState == AlarmSubmitState.COMPLETE) {
        final alarmStatusText = _alarmModel.isAlarmEnabled ? '設定' : '解除';
        ScaffoldMessenger.of(context).showSnackBar(
          AppFeedbackSnackBar.success('アラームを$alarmStatusTextしました'),
        );
      } else if (_alarmModel.submitState == AlarmSubmitState.ERROR) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppFeedbackSnackBar.error('エラーが発生しました'));
      }
    });
    return Scaffold(
      appBar: AppBar(title: Text('通知設定')),
      body: ListenableBuilder(
        listenable: _alarmModel,
        builder: (BuildContext context, Widget? child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text('ゴミ出しを通知する'),
                value: _alarmModel.isAlarmEnabled,
                onChanged: (value) {
                  _alarmModel.toggleAlarmEnabled();
                },
              ),
              SwitchListTile(
                title: Text('翌日のゴミ出しを通知する'),
                value: _alarmModel.nextDayNotificationEnabled,
                onChanged: (value) {
                  _alarmModel.toggleNextDayNotificationEnabled();
                },
              ),
              ListTile(
                title: Text('通知時刻'),
                trailing: Text(
                  '${_alarmModel.hourString}:${_alarmModel.minuteString}',
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: _alarmModel.hour,
                      minute: _alarmModel.minute,
                    ),
                  );
                  if (time != null) {
                    _alarmModel.setAlarmTime(time.hour, time.minute);
                  }
                },
              ),
              FilledButton(
                onPressed:
                    _alarmModel.submitState == AlarmSubmitState.SUBMITTING
                    ? null
                    : () async {
                        _alarmModel.submitAlarmTime();
                      },
                child: Text('設定'),
              ),
              if (_alarmModel.submitState == AlarmSubmitState.SUBMITTING)
                CircularProgressIndicator(),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 40),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(10),
                      color:
                          Theme.of(context).dialogTheme.backgroundColor ??
                          Theme.of(context).colorScheme.surface,
                    ),
                    child: Text(
                      '通知の設定および受信には、スマートフォンがインターネットに接続されている必要があります',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
