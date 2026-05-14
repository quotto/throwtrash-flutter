# issues/004 対応計画

## 対象

Maestro を用いた iOS 向け E2E テスト基盤を追加し、ローカル実行手順と GitHub Actions 実行フローを整備する。対象シナリオは「基本動作」「編集」「削除」「コピー」で、最終的な GitHub Actions のトリガーは `release` ブランチへの push とする。

## 要求分析

### 機能要件

1. iOS 向け E2E テストを Maestro で実装する。
2. 以下 4 シナリオを正常終了まで自動化する。
   - 基本動作
   - 登録済みデータの編集
   - 登録済みデータの削除
   - コピー機能の動作
3. GitHub Actions 上で Maestro CLI を用いてテストを実行する。
4. テスト結果レポートを GitHub Actions のアーティファクトとして 7 日保存する。

### 非機能・運用要件

1. ローカル環境で同一シナリオが再実行できること。
2. GitHub Actions 検証時のみ一時的に開発ブランチ push をトリガーに使い、確認後は `release` ブランチ push に戻すこと。
3. iOS 実行環境は macOS ランナー + iOS シミュレータを前提とする。

### 現状整理

1. GitHub Actions は `.github/workflows/coverage.yml` のみ存在し、E2E 用 workflow は未作成。
2. Maestro 用ディレクトリやフロー定義は未作成。
3. アプリのゴミ出し予定データは `SharedPreferences` に保存されるため、E2E ではシナリオごとにデータ初期化戦略が必要。
4. 画面遷移文言は既存 UI に存在するが、Maestro で安定して扱える key は一部画面に限られるため、必要に応じてセレクタ安定化を行う。

## 前提

- 実装は本 issue の要件内に限定し、機能追加は行わない。
- iOS ビルド前に `ios/.env` が必要である。
- Firebase 初期化を含むため、ローカル/CI ともに必要な設定ファイル・秘密情報の復元方法を明示する。
- E2E シナリオは再現性を優先し、各フローの開始前にアプリ状態をクリーンにする。

## エージェント編成

- manager: 要件管理、計画更新、タスク統合、最終判断
- developer: Maestro シナリオ実装、必要なアプリ側テスト補助、ローカル検証
- devops: GitHub Actions workflow、iOS シミュレータ実行、アーティファクト出力設計
- reviewer: シナリオ網羅性、CI 運用リスク、最終トリガー切替の確認

## 実装方針

1. 既存アプリの画面遷移・セレクタ・永続化方式を確認し、E2E の前提条件を洗い出す。
2. Maestro 用ディレクトリを追加し、共通起動処理・シナリオ別フロー・ローカル実行手順を整理する。
3. シナリオごとに独立実行できるよう、アプリ再インストールまたはデータ削除による初期化手順を用意する。
4. カレンダー表示確認、追加、編集、削除、コピーの各フローを安定して再実行できる形で実装する。
5. GitHub Actions に macOS ランナーの workflow を追加し、Flutter セットアップ、iOS シミュレータ起動、アプリ起動、Maestro 実行、結果保存までを自動化する。
6. GitHub Actions 検証は一時的な開発ブランチ trigger で確認し、確認後に `release` push のみに戻す差分を管理する。
7. 実装後は `flutter analyze`、既存テスト、ローカル Maestro 実行、必要に応じた CI 実行結果を反映してドキュメントを更新する。

## タスク一覧

- [x] task1: 前提調査と E2E 実行戦略の確定  
  完了条件: 必要な secrets / 設定ファイル / 実行コマンド / データ初期化方針が説明できる。  
  期待成果物: `issues/004/tasks/task1_baseline.md`
- [x] task2: Maestro フローと共通実行資産の実装  
  完了条件: 4 シナリオをローカルで個別実行できるフロー構成が定義される。  
  期待成果物: Maestro フロー群、ローカル実行手順、必要なテスト補助コード
- [x] task3: アプリ側の E2E 安定化対応  
  完了条件: Maestro から安定して操作・検証できるセレクタと初期化手段が整備される。  
  期待成果物: 必要最小限の UI key / テスト補助実装、関連テスト更新
- [x] task4: GitHub Actions workflow の追加  
  完了条件: macOS ランナー上で iOS シミュレータ + Maestro CLI により E2E を実行し、レポートを 7 日保持で保存できる。  
  期待成果物: `.github/workflows/*`、artifact 出力定義、必要な補助 script
- [ ] task5: 検証と運用切替（CI 実行確認待ち）  
  完了条件: ローカル実行結果、一時的な開発ブランチ trigger での CI 検証結果、最終 `release` trigger 反映方針が記録される。  
  期待成果物: `issues/004/tasks/task5_verification.md`、必要に応じた `work/reports/*`

## 検証方針

```sh
flutter analyze
flutter test
flutter build ios --simulator --debug --flavor development --dart-define=FLAVOR=development --dart-define=alarmApiKey=xxxxxxxxx
maestro test <flow-directory-or-file>
```

GitHub Actions では一時的に開発ブランチ push で workflow を確認し、その後 `release` push のみへ戻す。

## リスクと対応

- SharedPreferences に前回データが残るとシナリオが不安定になる。  
  - シナリオ開始時にアプリ再インストールまたは保存データ削除を行う。
- カレンダー表示やメニュー遷移が文言依存だと将来の UI 変更で壊れやすい。  
  - 既存 key を優先し、不足箇所のみ安定した識別子を追加する。
- Firebase / 通知まわりの初期化で CI 実行が失敗する可能性がある。  
  - `ios/.env` と関連設定ファイルの復元を workflow に含め、不足 secret を事前に列挙する。
- iOS シミュレータ起動や Maestro 実行は macOS ランナー上で時間がかかる。  
  - ビルド、起動、テスト実行、成果物保存を段階分けし、失敗点を切り分けやすい構成にする。

## 進捗メモ

- task1〜task4 は完了し、Maestro フロー、アプリ側識別子、GitHub Actions workflow、README 更新まで反映済み。
- `fvm flutter analyze` と `TMPDIR=$PWD/.tmp fvm flutter test` は成功した。
- `tool/maestro/run_ios_e2e.sh` は `xcodebuild -derivedDataPath` ベースに更新し、simulator build では Crashlytics symbol upload を skip するよう調整した。
- `maestro check-syntax` は scenario / common の全 flow で成功した。
- iOS 18.6 simulator（`iPhone 16 Pro`）で `tool/maestro/run_ios_e2e.sh` を実行し、4 flow がすべて成功した。
- Firebase 設定の placeholder 問題は解消済みで、`tool/maestro/run_ios_e2e.sh` の fail-fast チェックにより再発時も即座に検出できる。
- 一覧画面の編集導線は `InkWell` + `Semantics` に切り替え、iOS accessibility 経由でも安定して編集画面へ遷移できるようにした。

## 未確定事項

- GitHub Actions 上での実行結果と artifact 内容の実確認
- ローカル検証で利用するシミュレータ機種 / OS バージョンの最終固定
