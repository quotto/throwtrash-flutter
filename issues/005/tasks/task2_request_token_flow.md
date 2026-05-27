# task2: FCM トークン付き検索リクエストの実装

## 担当

- developer

## 目的

AI取り込み開始時に既存の FCM トークン更新処理を使い、スケジュール検索 API の request body へ `client.platform` と `client.fcm_token` を付加する。

## 作業内容

- [x] `TrashApiInterface.searchTrashSchedule` に FCM トークンを渡せるようにする。
- [x] `TrashApi.searchTrashSchedule` の body へ `client` を追加する。
- [x] 住所検索と郵便番号検索の両方で `client` が付加されるようにする。
- [x] `TrashDataService.importTrashSchedule` で検索前に `FcmInterface.refreshDeviceToken()` を呼び出す。
- [x] 取得した FCM トークンを `TrashApiInterface.searchTrashSchedule` に渡す。
- [x] FCM トークン取得失敗時は検索 API を呼ばず、`TrashImportMessage.error` を保存して失敗結果を返す。
- [x] FCM トークンをログ出力する場合はマスクする。
- [x] 住所検索 payload の単体テストを更新/追加する。
- [x] 郵便番号検索 payload の単体テストを更新/追加する。
- [x] トークン取得失敗時に API が呼ばれない単体テストを追加する。

## 完了条件

- API リクエスト body に以下が含まれる。

```json
{
  "client": {
    "platform": "ios",
    "fcm_token": "FCM_REGISTRATION_TOKEN"
  }
}
```

- 既存の検索成功/失敗結果処理が維持される。
- FCM トークン取得失敗時の挙動がテストで確認できる。

## 期待成果物

- `lib/usecase/repository/trash_api_interface.dart`
- `lib/repository/trash_api.dart`
- `lib/usecase/trash_data_service.dart`
- 関連する unit test

## 進捗

- [x] 完了

## 実装メモ

- `TrashApiInterface.searchTrashSchedule` に optional named parameter `fcmToken` を追加した。
- `TrashApi.searchTrashSchedule` は `fcmToken` が空でなく、platform が `ios` または `android` の場合だけ `client` を送信する。`web` など API enum 外の platform では `client` を付加しない。
- `TrashDataService.importTrashSchedule` は検索前に `FcmInterface.refreshDeviceToken()` を呼び、取得できない場合は検索 API を呼ばずに `TrashImportMessage.error` を保存する。
- `FcmService.refreshDeviceToken()` のログはトークン全体を出さず、先頭/末尾のみのマスク表示に変更した。
- `trash_search_api_test` で住所検索と郵便番号検索の payload を確認し、`trash_search_import_test` でトークン取得失敗時に API が呼ばれないことを確認した。
