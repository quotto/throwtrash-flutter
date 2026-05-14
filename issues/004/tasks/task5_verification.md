# task5: 検証と運用切替

## 担当

reviewer

## 状態

In Progress（ローカル検証完了、CI 実行確認待ち）

## 内容

- [x] ローカルの Maestro 実行結果を確認する。
- [x] `flutter analyze` と既存テスト結果を確認する。
- [ ] 一時的な開発ブランチ trigger による GitHub Actions 実行結果を確認する。
- [x] 最終的に `release` push のみに trigger を戻したことを確認する。
- [x] 残課題、運用上の注意点、必要な secrets の整備状況を記録する。

## 検証結果

- `fvm flutter analyze` は成功した。
- `TMPDIR=$PWD/.tmp fvm flutter test` は成功し、全 264 件が通過した。
- `tool/maestro/prepare_ios_ci_env.sh` と `tool/maestro/run_ios_e2e.sh` は `bash -n` で構文エラーがないことを確認した。
- `maestro check-syntax` は scenario / common の全 flow で成功した。
- `tool/maestro/run_ios_e2e.sh` は、`xcodebuild -derivedDataPath` を使う構成に切り替えたことで iOS Simulator 向け build / install まで到達した。
- iOS Simulator build では不要な Crashlytics symbol upload build phase を skip するよう `ios/Runner.xcodeproj/project.pbxproj` を調整した。
- iOS 18.6 simulator（`iPhone 16 Pro`）で `tool/maestro/run_ios_e2e.sh` を実行し、`01_basic_registration`、`02_edit_registered_data`、`03_delete_registered_data`、`04_copy_registered_data` の 4 flow がすべて成功した。
- 失敗原因の切り分けにより、`ios/development/GoogleService-Info.plist` の placeholder 設定や、一覧画面の編集導線が iOS accessibility 上でタップ可能要素として出ていない点を解消した。
- `tool/maestro/run_ios_e2e.sh` に Firebase 設定の fail-fast チェックを追加し、空の `firebase.json` や placeholder API_KEY を即座に検出できるようにした。
- 一覧画面の編集導線は `InkWell` + `Semantics` に切り替え、Maestro から `trash-row-index-0` を安定してタップできるようにした。

## 未完了項目

- GitHub Actions 実行はこのセッションでは起動していないため、artifact 実体と CI 上の Maestro 実行結果は未確認。

## 完了条件

- ローカル / CI の検証結果が追跡できる。
- 最終 workflow の trigger が要件と一致している。
- 残リスクと運用前提が明文化されている。

## 期待成果物

- 検証結果メモ
- レビュー結果
- 必要に応じた `work/reports` の記録
