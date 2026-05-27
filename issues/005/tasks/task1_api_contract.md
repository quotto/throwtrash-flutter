# task1: API 契約と実装方針の確定

## 担当

- manager
- developer

## 目的

スケジュール検索 API の FCM 通知仕様をアプリ実装へ正しく反映するため、リクエスト body、トークン取得失敗時の扱い、通知経路の整理方針を確定する。

## 作業内容

- [ ] `/Volumes/extend/project/trash-schedule-search/docs/openapi.yaml` の `SearchRequest` / `SearchClient` を再確認する。
- [ ] 住所検索時の request body を確定する。
- [ ] 郵便番号検索時の request body を確定する。
- [ ] `client.platform` に設定する値とテスト環境での扱いを確定する。
- [ ] `client.fcm_token` の取得元を `FcmService.refreshDeviceToken()` として確定する。
- [ ] FCM トークン取得失敗時は検索 API を呼ばず、取り込み失敗として扱う方針を実装へ反映する。
- [ ] サーバー FCM と API 応答後ローカル通知の二重通知を避けるため、ローカル完了/失敗通知を撤去する方針を確認する。
- [ ] アプリ終了時に検索結果反映が保証されない点を今回スコープ外の残リスクとして整理する。

## 完了条件

- `SearchClient` 仕様に基づくリクエスト body が実装タスクで迷わない粒度で明文化されている。
- トークン取得失敗時のユーザー向け挙動が決まっている。
- ローカル通知撤去と FCM 受信処理維持の境界が明確になっている。

## 期待成果物

- `issues/005/requirements.md` と `issues/005/plan.md` の更新
- 実装時に参照する API リクエスト例

## 進捗

- [ ] 未着手
