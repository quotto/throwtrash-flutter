# task2: カレンダーセル表示制限と省略表示の実装

## 担当

developer

## 状態

- [x] 完了

## 作業内容

- `lib/calendar.dart` の日付セル描画処理を整理する。
- セル内に表示する `DisplayTrashData` を先頭3件に制限する。
- 4件以上ある場合は、下部に `...+{超過数}` を表示する。
- ゴミ名テキストが長い場合もセル内に収まるよう、必要に応じて `maxLines` と `TextOverflow.ellipsis` を指定する。
- 既存の `calendar-trash-{trashType}` Semantics マーカーは全月の対象ゴミ種別検出として維持する。

## 完了条件

- 3件以下の日付セルは従来通り対象ゴミ名を表示する。
- 4件以上の日付セルは先頭3件と超過数だけを表示する。
- セル内表示の上限により、ゴミ名が際限なく描画されない。

## 期待成果物

- `lib/calendar.dart` の修正。
- 必要に応じた helper/private Widget の追加。

## 実施結果

- `lib/calendar.dart` に `_calendarDayCell`、`_trashLabel`、`_overflowLabel` を追加し、日付セル描画を局所化した。
- セル内のゴミ名表示を `take(3)` に制限した。
- 4件以上ある場合に `...+{超過数}` を表示するようにした。
- ゴミ名は `maxLines: 1` と `TextOverflow.ellipsis` で長い名前が横にはみ出しにくいようにした。
