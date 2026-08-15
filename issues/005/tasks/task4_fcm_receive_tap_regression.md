# task4: FCM 受信/タップ挙動の回帰確認

## 担当

- developer
- reviewer

## 目的

サーバー FCM 化後も、受信メッセージの表示と通知タップ時の挙動を現行通り維持できていることを確認する。

## 作業内容

- [x] `FcmService.initialize` の `FirebaseMessaging.onMessage` 処理を維持する。
- [ ] フォアグラウンド受信時に `_showForegroundNotification` が呼ばれる挙動を確認する。
- [x] `FirebaseMessaging.onMessageOpenedApp` のルート画面遷移を維持する。
- [x] ローカル通知タップ時の `onDidReceiveNotificationResponse` のルート画面遷移を維持する。
- [x] 通知 payload の新規解釈や画面遷移追加を行っていないことを確認する。
- [x] テスト可能な箇所は unit / widget test で確認する。
- [x] Firebase 実機/シミュレータ検証が必要な箇所は手動検証手順として残す。

## 完了条件

- 既存 FCM 受信時の表示挙動が変わっていない。
- 通知タップ時にルート画面へ戻る挙動が変わっていない。
- API 応答後ローカル通知の撤去によって、FCM 受信処理が壊れていない。

## 期待成果物

- 関連する unit test / widget test
- 必要に応じた手動検証手順

## 進捗

- [ ] 一部完了

## 確認結果

- `FcmService.initialize` の `FirebaseMessaging.onMessage`、`onMessageOpenedApp`、ローカル通知タップ時のルート画面遷移処理は変更していない。
- 通知 payload の新規解釈や新しい画面遷移は追加していない。
- 自動テストでは、AI取り込み API 応答後のローカル通知が呼ばれないことを確認した。
- Firebase 経由のフォアグラウンド受信、バックグラウンド受信、通知タップの実機/シミュレータ手動検証は未実施。

## 手動検証手順

1. 実機または FCM 受信可能なシミュレータで development flavor を起動する。
2. AI取り込みを開始し、API の `/search` request body に `client.platform` と `client.fcm_token` が含まれることを確認する。
3. アプリをバックグラウンドへ移動し、サーバー FCM の完了/失敗通知が OS 通知として表示されることを確認する。
4. フォアグラウンドで同等の FCM を受信し、現行通りローカル通知表示へ変換されることを確認する。
5. 通知をタップし、アプリがルート画面へ戻ることを確認する。
6. API 応答後のローカル通知とサーバー FCM が二重表示されないことを確認する。
