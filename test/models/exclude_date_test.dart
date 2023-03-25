import 'dart:convert';

import 'package:throwtrash/models/exclude_date.dart';
import 'package:test/test.dart';

void main() {
  test('ExcludeDateからJsonに変換',(){
    ExcludeDate excludeDate = ExcludeDate(1, 30);
    expect(excludeDate.toJson().toString(), '{month: 1, date: 30}');
  });
  test('JsonからExcludeDateに変換',(){
    ExcludeDate excludeDate = ExcludeDate.fromJson(jsonDecode('{"month": 1, "date": 30}'));
    expect(excludeDate.month, 1);
    expect(excludeDate.date, 30);
  });
}