# task3: バックグラウンドタスク化とローカル完了通知の撤去

## 担当

- developer

## 目的

AI取り込み完了通知をサーバー FCM に一本化するため、アプリ側のバックグラウンドタスク化、調査用デバッグ処理、API 応答後のローカル完了/失敗通知を削除する。

## 作業内容

- [x] `TrashDataService.importTrashSchedule` から `BackgroundTaskInterface.runTask` 経由の実行を削除する。
- [x] `TrashDataService` の constructor から AI取り込み用の `BackgroundTaskInterface` 依存を削除する。
- [x] `main.dart` から `BackgroundTaskService` の注入を削除する。
- [x] `BackgroundTaskService` / `BackgroundTaskInterface` / iOS MethodChannel が他用途で使われていないか確認する。
- [x] 他用途がなければバックグラウンドタスク関連の不要コードを削除する。
- [x] `_debugImportNotificationDelay` と `_debugNotifyOnlyImport` を削除する。
- [x] API 応答後の `showLocalNotification('AI取り込み', ...)` 呼び出しを削除する。
- [x] 取り込み結果保存、`TrashImportMessage` 保存、`refreshTrashData()` の動作は維持する。
- [x] 関連する unit test / widget test の期待値を更新する。

## 完了条件

- AI取り込み経路に `BackgroundTaskService` 依存が残っていない。
- API 呼び出しを迂回するデバッグ遅延通知処理が残っていない。
- API 応答後のローカル完了/失敗通知が発火しない。
- 画面向けの取り込み結果メッセージは引き続き保存される。

## 期待成果物

- `lib/usecase/trash_data_service.dart`
- `lib/main.dart`
- 必要に応じてバックグラウンドタスク関連ファイルの削除
- 関連する unit test / widget test

## 進捗

- [x] 完了

## 実装メモ

- AI取り込み経路から `BackgroundTaskInterface` / `BackgroundTaskService` 依存を削除した。
- `lib/repository/background_task_service.dart`、`lib/usecase/repository/background_task_interface.dart`、関連単体テスト、iOS の `throwtrash/background_task` MethodChannel 実装を削除した。
- デバッグ用の 30 秒遅延通知処理を削除し、検索 API を迂回する経路をなくした。
- API 応答後の完了/失敗ローカル通知を削除し、通知はサーバー FCM に一本化した。
- 取り込み結果保存、`TrashImportMessage` 保存、`refreshTrashData()` の流れは維持している。
