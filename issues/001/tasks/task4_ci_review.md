# task4: CI/CD・レビュー・検証

## 担当

devops, reviewer

## 状態

完了

## 内容

- GitHub Actions と Codemagic に AI取り込みで利用する API の `--dart-define=trashSearchApiKey` を追加する。
- CI/CD のシークレット名は `TRASH_SEARCH_API_KEY` とする。
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

## 実績

- `.github/workflows/coverage.yml` に `trashSearchApiKey` の `--dart-define` を追加した。
- `codemagic.yaml` の development / production の iOS ビルドに `trashSearchApiKey` の `--dart-define` を追加した。
- Codemagic の `development` / `production` variable group に `TRASH_SEARCH_API_KEY` secret が必要。
- `fvm dart run build_runner build --delete-conflicting-outputs` を実行した。
- `TMPDIR=/Volumes/extend/project/throwtrash-flutter/.tmp fvm flutter test` を実行し、255 件の全テスト通過を確認した。
- `TMPDIR=/Volumes/extend/project/throwtrash-flutter/.tmp fvm flutter analyze` は error なし、既存を含む info 指摘 247 件あり。
- Copilot review を実行し、結果を `work/copilot_review_issues_001_002.md` に記録した。
- Copilot review の High 指摘 3 件（データ破壊リスク、未処理非同期、初回ダイアログ非表示条件）と主要な Medium 指摘に対応した。
