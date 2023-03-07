import 'dart:io';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/models/trash_data.dart';
import 'package:throwtrash/usecase/alarm_service_interface.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/usecase/user_service_interface.dart';
import 'package:throwtrash/repository/alarm_repository_interface.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
class AlarmService implements AlarmServiceInterface {
  final UserServiceInterface _userService;
  final AlarmRepositoryInterface _alarmRepository;
  final TrashDataServiceInterface _trashDataService;
  final _logger = Logger();

  AlarmService(
      this._userService,
      this._alarmRepository,
      this._trashDataService
  );

  @override
  bool isEnabledToUseAlarm() {
    return this._userService.user.deviceToken.isNotEmpty &&
            this._userService.user.id.isNotEmpty;
  }

  @override
  Future<bool> setAlarm(Alarm alarm) async {
    if(alarm.hour >= 0 && alarm.hour <= 23 && alarm.minute >= 0 && alarm.minute <= 59) {
      if(await _alarmRepository.setAlarm(alarm)) {
        try {
          if(alarm.enabled) {
            await _reserveNextAlarm(alarm);
          } else {
            await _cancelAlarm();
          }
          return true;
        } on Exception catch(e) {
          print(e);
          _logger.e(e);
        }
      }
    }
    return false;
  }

  @override
  String createAlarmMessage(List<TrashData> allTrashData) {
    String message = "今日出せるゴミはありません";
    if(allTrashData.isNotEmpty) {
      List<String> trashNameList = allTrashData.map((trashData){
        String trashName = _trashDataService.getTrashName(type: trashData.type, trashVal: trashData.trash_val);
        return trashName;
      }).toList();
      message = trashNameList.join("\n");
    }
    return message;
  }

  @override
  Future<void> reserveNextAlarm() async {
   Alarm? alarm = await _alarmRepository.getAlarm();
   if(alarm != null) {
      await _reserveNextAlarm(alarm);
   }
  }

  Future<void> _cancelAlarm() async {
    print("Cancel Alarm");
    try {
      await Workmanager().cancelAll();
    } catch(error) {
      print(error);
      _logger.e(error);
    }
  }

  Future<void> _reserveNextAlarm(Alarm alarm) async {
    await _cancelAlarm();
    DateTime now = DateTime.now();
    DateTime next = DateTime.now();
    if(now.hour > alarm.hour || (now.hour == alarm.hour && now.minute >= alarm.minute)) {
      next = now.add(Duration(days: 1));
      next = DateTime(next.year, next.month, next.day, alarm.hour, alarm.minute);
    } else {
      next = DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    }
    Duration duration = next.difference(now);
    String taskId = Uuid().v4();
    _logger.d("Set alarm, next is after ${duration.inSeconds} seconds, task id is $taskId");
    print("Set alarm, next is after ${duration.inSeconds} seconds, task id is $taskId");
    await Workmanager().cancelAll();
    // if(Platform.isAndroid) {
      await Workmanager().registerOneOffTask(
        // taskId,
          "com.codegemz.helloWorld",
          "今日のゴミ出しアラーム",
          initialDelay: duration);
    // } else {
    //   MethodChannel channel = MethodChannel("net.mythrowtrash/alarm");
    //   var result = await channel.invokeMethod("reserveNextAlarm",{"duration": duration.inSeconds.toString(),"hour": alarm.hour.toString(), "minute": alarm.minute.toString(),"content": "test"});
    //   print(result);
    // }
  }
}