class Alarm {
  final int hour;
  final int minute;
  final bool isEnable;
  final bool nextDayNotificationEnabled;

  Alarm(this.hour, this.minute, this.isEnable, [this.nextDayNotificationEnabled = false]) {
    if(hour < 0 || hour > 23) {
      throw(ArgumentError('時間の範囲は0-23です'));
    }
    if(minute < 0 || minute > 59)  {
      throw(ArgumentError('分の範囲は0-59です'));
    }
  }

  Alarm changeEnable(bool isEnable) {
    return Alarm(this.hour, this.minute, isEnable, this.nextDayNotificationEnabled);
  }

  Alarm changeTime(int hour, int minute) {
    return Alarm(hour, minute, this.isEnable, this.nextDayNotificationEnabled);
  }

  Alarm changeNextDayNotificationEnabled(bool enabled) {
    return Alarm(this.hour, this.minute, this.isEnable, enabled);
  }
}
