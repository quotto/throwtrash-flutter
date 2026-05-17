# task5: 検証と運用切替

## 担当

reviewer

## 状態

Done

## 内容

- [x] ローカルの Maestro 実行結果を確認する。
- [x] `flutter analyze` と既存テスト結果を確認する。
- [x] 一時的な開発ブランチ trigger による GitHub Actions 実行結果を確認する。
- [x] 最終的に `release` push のみに trigger を戻したことを確認する。
- [x] 残課題、運用上の注意点、必要な secrets の整備状況を記録する。

## 検証結果

- CI artifact の再分析で、スクリーンショット上は `もえるゴミ` が表示済みだったが、iOS accessibility hierarchy ではカレンダー全体の `accessibilityText` に結合され、Maestro の `assertVisible: もえるゴミ` が単独要素として解決できないことを確認した。
- 対策として `lib/calendar.dart` のゴミ表示に `calendar-trash-{type}` の Semantics identifier を追加し、4 本の Maestro scenario は `assertVisible` / `assertNotVisible` を id 指定へ変更した。
- `test/widget/widget_test.dart` に `calendar-trash-burn` と `calendar-trash-unburn` の Semantics identifier が表示されることを確認する widget test を追加した。
- CI 再検証用に `.github/workflows/ios-maestro-e2e.yml` は一時的に `refactor/e2e-test` push でも起動するよう変更し、`codemagic.yaml` は同ブランチを `ios-development` push trigger から除外した。
- `tool/maestro/run_ios_e2e.sh` は Maestro の終了コードを保持して返すよう修正し、ローカル sandbox 用に `DISABLE_RUNNER_LOG_TEE=true` の場合は process substitution を使わず `runner.log` へ直接出力できるようにした。
- `bash -n tool/maestro/prepare_ios_ci_env.sh tool/maestro/run_ios_e2e.sh` は成功した。
- `JAVA_OPTS="-Duser.home=$PWD/.maestro-home" maestro check-syntax` は common / scenario の全 6 flow で成功した。
- `fvm flutter analyze` は成功した。
- `TMPDIR=$PWD/.tmp fvm flutter test` は成功し、全 267 件が通過した。
- XcodeBuildMCP 経由で iOS Simulator build / install / launch は成功した。
- Maestro MCP 経由で `01_basic_registration`、`02_edit_registered_data`、`03_delete_registered_data`、`04_copy_registered_data` の 4 flow を個別実行し、すべて成功した。
- GitHub Actions `iOS Maestro E2E` の run `25976322829` は `tool/maestro/run_ios_e2e.sh` の終了コード伝播により failure として正しく終了した。
- run `25976322829` では `01_basic_registration` と `03_delete_registered_data` は成功し、`02_edit_registered_data` と `04_copy_registered_data` は `Assertion is false: "もえないゴミ" is visible` で失敗した。
- run `25976322829` の artifact では、編集後の一覧スクリーンショット上に `もえないゴミ` が表示されていたが、iOS accessibility hierarchy では行全体の `accessibilityText` に結合され、Maestro のテキスト単独検証が失敗していた。
- 同 artifact により、コピー作成後は `TrashDataService.addTrashData()` が repository には保存する一方で in-memory の `_schedule` を更新せず、一覧へ戻っても新規行が表示されないことを確認した。
- 対策として `lib/list.dart` に `trash-list-{type}` の Semantics identifier を追加し、一覧画面のゴミ種別検証を id ベースへ変更した。
- 対策として `lib/usecase/trash_data_service.dart` の追加・更新・削除成功時に in-memory の `_schedule` も同期するよう修正した。
- `test/widget/trash_list_copy_test.dart` に一覧 marker の検証、`test/unit/usecase/trash_data_service_test.dart` に追加・更新・削除時の in-memory 反映テストを追加した。
- 修正後、`fvm flutter analyze`、`TMPDIR=$PWD/.tmp fvm flutter test`、Maestro syntax check、XcodeBuildMCP の iOS Simulator build は成功した。
- 修正後の Simulator install / Maestro ローカル再実行は、ホスト側 `/System/Volumes/Data` の空き容量が 154Mi しかなく `No space left on device` でブロックされた。
- GitHub Actions `iOS Maestro E2E` の run `25977275880` は success で完了した。
- run `25977275880` の artifact は `work/ios-maestro-e2e-run-25977275880` に展開し、`01_basic_registration`、`02_edit_registered_data`、`03_delete_registered_data`、`04_copy_registered_data` の JUnit がすべて `failures="0"` / `status="SUCCESS"` であることを確認した。
- run `25977275880` の `runner.log` では 4 flow すべて `[Passed]`、`status.txt` は `exit_status=0` だった。
- CI 検証完了後、`.github/workflows/ios-maestro-e2e.yml` は `release` push のみに戻し、`codemagic.yaml` の `refactor/e2e-test` 一時除外も削除した。
- 現在の shell 実行環境では `xcrun simctl` が断続的に CoreSimulatorService に接続できず、Maestro CLI も boot 済み simulator を connected として認識できないため、`tool/maestro/run_ios_e2e.sh` の shell からのローカル完走確認は未完了。
- ユーザー側でシミュレーター起動後に再確認し、`xcrun simctl list devices booted` は一度成功したが、その後の `simctl -j` / `maestro test --udid` は CoreSimulatorService 接続エラーまたは `0 devices connected` で実行できなかった。
- 過去のローカル検証では、`tool/maestro/run_ios_e2e.sh` が `xcodebuild -derivedDataPath` を使う構成に切り替えたことで iOS Simulator 向け build / install まで到達した。
- iOS Simulator build では不要な Crashlytics symbol upload build phase を skip するよう `ios/Runner.xcodeproj/project.pbxproj` を調整した。
- 過去のローカル検証では、iOS 18.6 simulator（`iPhone 16 Pro`）で `tool/maestro/run_ios_e2e.sh` を実行し、`01_basic_registration`、`02_edit_registered_data`、`03_delete_registered_data`、`04_copy_registered_data` の 4 flow がすべて成功した。
- GitHub Actions `iOS Maestro E2E` の run `25959379109` は workflow 自体は成功終了したが、artifact 内の JUnit では `01_basic_registration`、`02_edit_registered_data`、`03_delete_registered_data`、`04_copy_registered_data` がすべて `Assertion is false: "もえるゴミ" is visible` で失敗していた。
- `tool/maestro/run_ios_e2e.sh` では `wait "$maestro_pid"` の直後に `notice` を呼んでおり、Maestro の失敗終了コードが関数の返り値に反映されず、CI が偽陽性になっていた。
- 失敗原因の切り分けにより、`ios/development/GoogleService-Info.plist` の placeholder 設定や、一覧画面の編集導線が iOS accessibility 上でタップ可能要素として出ていない点を解消した。
- `tool/maestro/run_ios_e2e.sh` に Firebase 設定の fail-fast チェックを追加し、空の `firebase.json` や placeholder API_KEY を即座に検出できるようにした。
- 一覧画面の編集導線は `InkWell` + `Semantics` に切り替え、Maestro から `trash-row-index-0` を安定してタップできるようにした。
- CI 検証用に追加していた `refactor/e2e-test` trigger は一度削除済みだが、artifact 再確認で偽陽性が判明したため、再検証方針を見直す必要がある。
- GitHub Actions 検証中に一時停止していた Codemagic `ios-development` の push trigger は一度元に戻した。

## 未完了項目

- shell からの `tool/maestro/run_ios_e2e.sh` ローカル完走確認は、ホスト側 `/System/Volumes/Data` の空き容量不足により未完了。代替として `flutter analyze`、全体 `flutter test`、Maestro syntax check、XcodeBuildMCP の simulator build、GitHub Actions run `25977275880` の E2E success と artifact を確認済み。

## 完了条件

- ローカル / CI の検証結果が追跡できる。
- 最終 workflow の trigger が要件と一致している。
- 残リスクと運用前提が明文化されている。

## 期待成果物

- 検証結果メモ
- レビュー結果
- 必要に応じた `work/reports` の記録
