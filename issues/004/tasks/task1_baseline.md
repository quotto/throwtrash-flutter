# task1: 前提調査と E2E 実行戦略の確定

## 担当

manager

## 状態

完了

## 内容

- [x] 既存の画面遷移、主要文言、利用可能な widget key を棚卸しする。
- [x] SharedPreferences ベースの永続化項目を確認し、クリーン状態の作り方を決める。
- [x] ローカル実行に必要な `ios/.env`、`--dart-define`、Firebase 関連設定の前提を洗い出す。
- [x] GitHub Actions で必要になる secrets と依存ツールを列挙する。

## 完了条件

- ローカル実行と CI 実行の前提差分が説明できる。
- シナリオ開始前のデータ初期化手順が決まっている。
- Maestro 実行対象の画面・操作・検証点が一覧化されている。

## 期待成果物

- E2E 実行前提メモ
- secrets / 設定ファイル一覧
- セレクタ候補一覧

## 実績

### ベースライン

- `.fvmrc` は Flutter `3.41.0` を指定している。
- `fvm flutter analyze` は `No issues found!` で成功した。
- `fvm flutter test` は 262 件すべて成功した。
- ローカル環境には `iPhone 17 (iOS 26.4)` シミュレータが起動済みで、Maestro からも iOS simulator として認識されている。

### ローカル実行前提

- `ios/.env` は未配置だった。`ios/.env.example` を元にローカル用ファイルを作成する必要がある。
- `ios/.env` には `FIREBASE_APP_ID=...` を設定する。
- `EnvironmentProvider` は `--dart-define=FLAVOR=development` 未指定時でも `development` を既定値として扱う。
- iOS / E2E 実行では少なくとも `--dart-define=alarmApiKey=...` が必要で、検索系を通す場合は `--dart-define=trashSearchApiKey=...` も必要。
- `json/development/config.json` / `json/production/config.json` はコミット済み設定値として利用される。

### CI で復元が必要な設定・ secrets

- `FIREBASE_INFO`
- `GOOGLE_SERVICE_INFO_PLIST`
- `FIREBASE_OPTIONS`
- `FIREBASE_APP_ID`
- `ALARM_API_KEY`
- `TRASH_SEARCH_API_KEY`

Codemagic では上記を使って以下を復元しているため、GitHub Actions でも同等の復元が必要。

- `ios/development/firebase.json` または `ios/production/firebase.json`
- `ios/<flavor>/GoogleService-Info.plist`
- `lib/firebase_options.dart`
- `ios/.env`

### データ初期化方針

- ゴミ出し予定、同期状態、共通例外日、初回ダイアログ表示状態は `SharedPreferences` に保存される。
- シナリオ独立性を担保するため、各フロー開始時にアプリをクリーンインストールする方針とする。
- 補助的に `stopApp` / `launchApp` だけでは不十分なため、ローカル補助スクリプトや CI では simulator 上の app uninstall / reinstall を前提にする。

### セレクタ候補

- 既存で利用可能
  - `calendar_column_0`
  - `weekday_label_0`
  - `submit`
  - `open-auto-import-dialog`
  - `copy-trash-<id>`
  - `delete-trash-<id>`
- 文言で利用可能
  - ドロワー: `追加`, `編集`
  - 一覧画面: `登録されているゴミ出し予定`
  - 編集画面: `編集`, `コピー作成`, `登録`, `更新`
  - スケジュール種別: `毎週`, `毎月同じ日`, `特定の週`, `隔週`
- E2E の安定性向上のため、ドロワー操作・編集フォーム入力・スケジュール行に識別子を追加する方針とする。
