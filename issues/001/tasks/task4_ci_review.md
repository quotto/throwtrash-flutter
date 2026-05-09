# task4: CI/CD・レビュー・検証

## 担当

devops, reviewer

## 内容

- CI/CD に自動取り込み API の `--dart-define=trashSearchApiEndpoint` と `--dart-define=trashSearchApiKey` を追加する。
- GitHub Actions のシークレット名は `TRASH_SEARCH_API_ENDPOINT` と `TRASH_SEARCH_API_KEY` とする。
- 実装後に Copilot review を実行する。
- セキュリティ観点で API キー、入力情報、通知内容、ログ出力を確認する。

## 検証

- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test`
- `flutter analyze`
- 必要に応じて `dart fix --apply`

## 完了条件

- 主要検証コマンドが通る。
- レビュー指摘が解消または対応方針付きで記録される。
