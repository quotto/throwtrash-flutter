# task5: 検証、レビュー、運用確認

## 担当

- reviewer
- devops
- manager

## 目的

実装後の静的解析、テスト、iOS/Firebase 手動確認、レビュー観点を整理し、FCM 化による回帰や運用リスクを確認する。

## 作業内容

- [x] `flutter analyze` を実行する。
- [x] `flutter test` を実行する。
- [x] 必要に応じて iOS simulator build を実行する。
- [x] `/search` の request body に `client.platform` と `client.fcm_token` が含まれることを確認する。
- [ ] アプリをバックグラウンドへ移動した状態で、API 完了時にサーバー FCM 通知が表示されることを確認する。
- [ ] フォアグラウンド受信時に現行通り通知表示されることを確認する。
- [ ] 通知タップ時にルート画面へ戻ることを確認する。
- [x] 通知が二重に表示されないことを確認する。
- [x] FCM トークンがログへフル出力されていないことを確認する。
- [x] API 応答後のデータ反映がアプリ終了時に保証されない残リスクを必要に応じて記録する。

## 完了条件

- 静的解析と自動テストが成功している。
- FCM 通知の受信/タップ挙動が手動または自動で確認されている。
- セキュリティ/運用上の残リスクが文書化されている。
- 実装内容と `issues/005` のドキュメントに差異がない。

## 期待成果物

- 検証結果の記録
- 必要に応じた `work/reports/*`
- 更新済みの `issues/005` ドキュメント

## 進捗

- [ ] 一部完了

## 検証結果

- `fvm dart run build_runner build --delete-conflicting-outputs`
  - 完了。
  - `--delete-conflicting-outputs` は現在の build_runner では無視されるという警告が出た。
  - `json_annotation` の制約に関する警告が出たが、既存の依存関係警告であり今回の変更による失敗ではない。
- `TMPDIR=$PWD/.tmp fvm flutter test`
  - 成功。全テストが通過した。
- `TMPDIR=$PWD/.tmp fvm flutter analyze`
  - 成功。`No issues found!`
- `TMPDIR=$PWD/.tmp fvm flutter build ios --simulator --debug --flavor development --dart-define=FLAVOR=development --dart-define=alarmApiKey=dummy`
  - 失敗。`xcodebuild` が error 66 で終了したため詳細確認を実施した。
- `xcodebuild -workspace ios/Runner.xcworkspace -scheme development -configuration Debug-development -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO`
  - 失敗。Xcode DerivedData と `.xcactivitylog` 書き込みで `No space left on device` が発生した。
  - コンパイルエラーではなく、ホスト環境の空き容量不足による失敗と判断する。
- `df -h /Users/takah /Volumes/extend`
  - `/Users/takah` 側は空き容量が約 180MB までしか回復しておらず、通常の Flutter/Xcode ビルドが使う DerivedData やログ出力先としては不足している。
  - `/Volumes/extend` 側には約 8GB 以上の空きがあるため、DerivedData をプロジェクト配下へ移して追加確認した。
- `xcodebuild -workspace ios/Runner.xcworkspace -scheme development -configuration Debug-development -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' -derivedDataPath .tmp/XcodeDerivedData build CODE_SIGNING_ALLOWED=NO COMPILER_INDEX_STORE_ENABLE=NO DEBUG_INFORMATION_FORMAT=dwarf`
  - 成功。`** BUILD SUCCEEDED **`
  - `DEBUG_INFORMATION_FORMAT=dwarf` は検証時の dSYM 生成を抑えるために指定した。通常設定では gRPC-Core の dSYM 生成時に空き容量不足の影響を受ける可能性が残る。
  - 警告は既存 Pods の iOS Simulator deployment target が Xcode のサポート範囲より低いこと、Run Script phase に output がないこと、AppIntents metadata extraction のスキップであり、今回変更によるコンパイルエラーではない。

## 残確認

- サーバー FCM のバックグラウンド通知表示は、実機または FCM 受信可能なシミュレータで未確認。
- フォアグラウンド受信時のローカル通知変換と通知タップ時のルート画面遷移は、既存コードを維持しているが手動確認は未実施。
- アプリが OS に終了された場合、サーバー FCM 通知は届いても API 応答後のローカルデータ反映は保証されない。この制約は今回の通知経路変更では解消しない。
