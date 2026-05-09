# task1: Domain/API 実装

## 担当

developer

## 状態

完了

## 内容

- 検索 API 用 Model を追加する。
- `TrashApiInterface` と `TrashApi` に検索 API 呼び出しを追加する。
- API レスポンスから既存 `TrashData` への変換処理を追加する。
- 入力値を郵便番号/住所へ分類するロジックを追加する。
- `trashSearchApiEndpoint` は `AppConfigProvider` から取得する。
- `trashSearchApiKey` は `EnvironmentProvider` から取得する。

## テスト

- 郵便番号判定の正常系・異常系。
- API 200 成功、`unsupported_schedule`、400、403、429、500 系。
- `TrashData` 変換の正常系。
- `unsupported` スケジュールを保存対象から除外すること。

## 完了条件

- 対象単体テストが通る。
- `openapi.yaml` の主要レスポンスに対応している。

## 実績

- `TrashSearchResult` と `TrashSearchInputType` を追加した。
- 検索 API の `/search` 呼び出し、API キー送信、エラーレスポンス変換を実装した。
- API レスポンスから既存 `TrashData` / `TrashSchedule` へ変換した。
- `unsupported` スケジュールは保存対象から除外した。
- 対象テスト: `test/unit/repository/trash_search_api_test.dart`
