class Alarm {
  final int hour;
  final int minute;
  final bool isEnable;

  Alarm(this.hour, this.minute, this.isEnable) {
    if(hour < 0 || hour > 23) {
      throw(ArgumentError('時間の範囲は0-23です'));
    }
    if(minute < 0 || minute > 59)  {
      throw(ArgumentError('分の範囲は0-59です'));
    }
  }

  Alarm changeEnable(bool isEnable) {
    return Alarm(this.hour, this.minute, isEnable);
  }

  Alarm changeTime(int hour, int minute) {
    return Alarm(hour, minute, this.isEnable);
  }
}