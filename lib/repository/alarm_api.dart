import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:throwtrash/models/alarm.dart';
import 'package:throwtrash/repository/alarm_api_interface.dart';

class AlarmApi implements AlarmApiInterface {
  final FirebaseFirestore _firebaseFirestore;
  AlarmApi(this._firebaseFirestore);

  @override
  Future<bool> updateAlarm(String deviceToken, Alarm alarm) {
    DateTime utcDt = DateTime(DateTime.now().year, 0, 0, alarm.hour, alarm.minute).toUtc();
    Map<String, dynamic> updateAlarmValue = alarm.toJson();
    updateAlarmValue['hour'] = utcDt.hour;
    updateAlarmValue['minute'] = utcDt.minute;
    return _firebaseFirestore.collection('devices').doc(deviceToken).update({
      'alarm': updateAlarmValue,
      'updated': DateTime.now().toUtc()
    }).then((_)=>true).catchError((error){
      print(error);
      return false;
    });
  }

}