# issues/005 対応計画

## 対象

AI取り込みの完了/失敗通知を、アプリ内のバックグラウンド継続処理とローカル通知から、スケジュール検索 API が送信する FCM 通知へ切り替える。アプリ側では検索リクエストにプラットフォームと FCM 登録トークンを付加し、既存の FCM 受信/タップ処理を維持する。

## 要求分析

### 機能要件

1. スケジュール検索 API の `/search` リクエストに `client.platform` と `client.fcm_token` を付加する。
2. `client` の仕様は `/Volumes/extend/project/trash-schedule-search/docs/openapi.yaml` の `SearchClient` に従う。
3. FCM 登録トークンは既存の `FcmService.refreshDeviceToken()` を使って取得/保存する。
4. 受信メッセージの表示と通知タップ時の挙動は現行通り維持する。
5. AI取り込みの検索リクエストをバックグラウンドタスク化しない。
6. API 応答後に完了/失敗をローカル通知する処理は削除し、通知はサーバー FCM に一本化する。

### 非機能・運用要件

1. iOS バックグラウンド実行時間に依存しない通知経路にする。
2. トークン取得失敗時に検索 API を呼ばず、通知不能な取り込み開始を避ける。
3. FCM トークンをログやテスト出力へフル表示しない。
4. 既存の AI取り込み結果保存、取り込みメッセージ保存、画面表示の流れを維持する。
5. 実装後は単体テスト、Widget テスト、`flutter analyze` を通す。

## 現状整理

1. `TrashApi.searchTrashSchedule` は現在 `address` または `postal_code` のみを body に設定しており、`client` を送信していない。
2. `TrashApi` は既に `_platform` を持っており、既存 API では `ios` / `android` / `web` を使い分けている。
3. `FcmService.refreshDeviceToken()` は Firebase Messaging からトークンを取得し、`ConfigRepository` に保存する仕組みを持つ。
4. `AlarmService` は既に API 呼び出し前に `refreshDeviceToken()` を使うパターンを持つため、AI取り込みも同様の流れに寄せられる。
5. `TrashDataService.importTrashSchedule` には、バックグラウンドタスク実行とデバッグ用の遅延通知処理が残っている。
6. `TrashDataService` は API 応答後に `showLocalNotification('AI取り込み', ...)` を呼ぶため、サーバー FCM 化後は二重通知の原因になる。
7. FCM 受信処理は `FcmService.initialize` 内の `FirebaseMessaging.onMessage` と `onMessageOpenedApp` に実装済みである。

## 前提

- API 側の FCM 通知対応は完了済みとする。
- API は `client.platform == ios` の場合に検索終了通知ジョブを enqueue する。
- Android は現行の主要運用対象外だが、`SearchClient.platform` の enum には含まれるため、実装上は既存 `_platform` の値を使う。
- 通知文言やタップ時の画面遷移は既存 FCM 受信処理に従い、アプリ側で新しい通知 payload 解釈は追加しない。
- 今回は完了通知の遅延解消が目的であり、アプリ終了後の検索結果反映保証は対象外とする。

## エージェント編成

- manager: 要件管理、実装スコープ調整、タスク統合、進捗判断
- developer: API リクエスト変更、FCM トークン連携、バックグラウンドタスク削除、テスト更新
- reviewer: API 契約、通知重複、トークン取り扱い、回帰リスクのレビュー
- devops: iOS/Firebase 設定、ローカル検証、CI 実行結果確認

## 実装方針

1. `TrashApiInterface.searchTrashSchedule` の引数に FCM トークンを渡せるようにする。
2. `TrashApi.searchTrashSchedule` で既存の `address` / `postal_code` body に `client` を追加する。
3. `client.platform` は `TrashApi` の既存 `_platform` を利用する。ただし API 仕様上は `ios` / `android` のみであるため、テスト時や非モバイル環境での値の扱いを明確にする。
4. `TrashDataService.importTrashSchedule` は検索前に `FcmInterface.refreshDeviceToken()` を呼び、取得したトークンを `TrashApiInterface.searchTrashSchedule` に渡す。
5. iOS で FCM トークン取得に失敗した場合は検索 API を呼ばず、取り込み失敗として `TrashImportMessage.error` を保存する。
6. `BackgroundTaskInterface` を AI取り込み経路から削除し、`main.dart` の `BackgroundTaskService` 注入も廃止する。
7. 調査用の `_debugImportNotificationDelay` と `_debugNotifyOnlyImport` を削除する。
8. API 応答後の `showLocalNotification` 呼び出しを削除し、完了/失敗通知はサーバー FCM 由来の受信処理へ一本化する。
9. `FcmService.onMessage` と `onMessageOpenedApp` の動作は維持し、必要な範囲でテストだけ更新する。
10. FCM トークンのログ出力が追加される場合はマスクし、既存ログも今回触る範囲で安全な出力へ寄せる。

## タスク一覧

- [ ] task1: API 契約と実装方針の確定  
  完了条件: `SearchClient` 仕様、トークン取得失敗時の扱い、二重通知回避方針が文書化される。  
  期待成果物: `issues/005/tasks/task1_api_contract.md`
- [x] task2: FCM トークン付き検索リクエストの実装  
  完了条件: AI取り込みリクエストに `client.platform` と `client.fcm_token` が含まれ、関連単体テストが通る。  
  期待成果物: `TrashApiInterface` / `TrashApi` / `TrashDataService` の修正、単体テスト更新
- [x] task3: バックグラウンドタスク化とローカル完了通知の撤去  
  完了条件: AI取り込み経路から `BackgroundTaskService`、デバッグ遅延通知、API 応答後の完了/失敗ローカル通知が削除される。  
  期待成果物: `TrashDataService` / `main.dart` / 関連テストの修正
- [ ] task4: FCM 受信/タップ挙動の回帰確認  
  完了条件: 既存 FCM 受信処理が維持され、フォアグラウンド表示とタップ時ルート遷移のテストまたは手動検証観点が整備される。  
  期待成果物: Widget/単体テスト更新、手動検証手順
- [ ] task5: 検証、レビュー、運用確認  
  完了条件: `flutter analyze`、`flutter test`、必要な iOS/Firebase 手動確認が完了し、残リスクが文書化される。  
  期待成果物: `issues/005/tasks/task5_verification_review.md`、必要に応じた `work/reports/*`

## 検証方針

```sh
flutter analyze
flutter test
flutter build ios --simulator --debug --flavor development --dart-define=FLAVOR=development --dart-define=alarmApiKey=xxxxxxxxx
```

手動検証では以下を確認する。

1. AI取り込み開始時の `/search` request body に `client.platform` と `client.fcm_token` が含まれる。
2. アプリをバックグラウンドに移動しても、API 完了時にサーバー FCM 通知が表示される。
3. フォアグラウンド中に FCM を受信した場合、現行通りローカル通知表示へ変換される。
4. 通知タップ時にアプリのルート画面へ戻る。
5. API 応答後のローカル完了通知が発火せず、通知が二重にならない。

## リスクと対応

- FCM トークンを取得できない場合、サーバー FCM 通知を送れない。  
  - iOS では検索 API 呼び出し前に失敗として扱い、通知不能な取り込み開始を避ける。
- API 応答後のローカル通知を残すと、サーバー FCM と二重通知になる。  
  - 完了/失敗通知はサーバー FCM に一本化し、アプリ側は取り込み結果の保存と画面向けメッセージ保存だけを行う。
- アプリが OS に終了された場合、HTTP 応答を受け取れずローカルデータ反映が失われる可能性がある。  
  - 今回は通知信頼性改善に限定し、結果取得保証は別 issue で扱う。
- `_platform` がテスト環境で `web` になると API の enum と合わない。  
  - テスト用に platform を注入可能にするか、`client` 付与対象をモバイル platform に限定する。
- FCM トークンのログ出力は情報漏えいリスクがある。  
  - 新規ログではフルトークンを出さず、今回触る既存ログもマスクを検討する。

## 実装結果メモ

- `TrashApi.searchTrashSchedule` に `fcmToken` を渡せるようにし、`ios` / `android` の場合だけ `/search` request body に `client.platform` と `client.fcm_token` を付加する実装にした。
- `TrashDataService.importTrashSchedule` は検索前に `FcmInterface.refreshDeviceToken()` を呼び、トークン取得失敗時は検索 API を呼ばずに取り込み失敗メッセージを保存する。
- AI取り込み経路から `BackgroundTaskService`、iOS MethodChannel、デバッグ用遅延通知、API 応答後のローカル完了/失敗通知を削除した。
- 既存の FCM 受信/タップ処理は変更せず、通知 payload の新規解釈も追加していない。
- 自動検証として `fvm flutter test` と `fvm flutter analyze` は成功した。
- 通常の `fvm flutter build ios --simulator` は `/Users/takah` 側の空き容量不足により `xcodebuild` error 66 で失敗した。
- DerivedData を `.tmp/XcodeDerivedData` に移し、検証用に dSYM 生成を抑えた `xcodebuild` は成功した。
- サーバー FCM のバックグラウンド受信と通知タップの手動検証は未実施のため、実機または通知送信可能な環境で確認が必要。
