# issues/001 対応計画

## 対象

ゴミ出し予定検索 API を利用し、郵便番号または住所からゴミ出し予定を自動取り込みする機能を実装する。

## 前提

- 実装前に本計画の承認を得る。
- 実装は TDD で進め、先に失敗する単体テスト・Widget テストを追加する。
- API エンドポイントは `json/{flavor}/config.json` から読み込む。
- API キーはビルド時の `--dart-define` から読み込む。
  - `--dart-define=trashSearchApiKey=...`
- API 仕様は `issues/001/openapi.yaml` を正とする。
- 取り込み完了・エラー通知は端末上のローカル通知で行う。
- 現在登録済みのゴミ出し予定は、正常レスポンス反映時に全削除して API レスポンス内容へ置き換える。
- 反映後はリモート同期待ち状態にする。
- 初回起動時の自動取り込みダイアログは、実行・キャンセルに関わらず一度閉じたら次回以降のアプリ起動では表示しない。
- 編集画面で表示する取り込み完了・エラーメッセージは取り込み処理直後のみ表示し、次回以降は表示しない。

## 影響範囲

- `lib/repository/environment_provider.dart`
- `lib/repository/trash_api.dart`
- `lib/usecase/repository/trash_api_interface.dart`
- `lib/usecase/trash_data_service.dart`
- `lib/usecase/trash_data_service_interface.dart`
- `lib/repository/trash_repository.dart`
- `lib/usecase/repository/trash_repository_interface.dart`
- `lib/repository/fcm_service.dart` またはローカル通知用の新規 Repository/Service
- `lib/main.dart`
- `lib/calendar.dart`
- `lib/list.dart`
- `lib/edit.dart`
- `lib/models/`
- `lib/viewModels/`
- `test/unit/`
- `test/widget/`
- CI/CD 定義ファイル

## 実装方針

1. API レスポンスを表す Model を追加する。
   - `TrashSearchResponse`
   - `TrashSearchItem`
   - `TrashSearchSchedule`
   - `TrashSearchErrorType`
2. 入力値判定ロジックを UseCase に置く。
   - 日本国内郵便番号は `^\d{3}-?\d{4}$` で判定する。
   - 郵便番号以外は住所として扱う。
   - 入力は 50 文字制限、空文字は実行不可とする。
3. `TrashApi` に検索 API 呼び出しを追加する。
   - `search` エンドポイントへ POST する。
   - `x-api-key` と `content-type: application/json` を設定する。
   - 200 は部分成功を含めて JSON として処理する。
   - 400/500/502/504 は `ErrorResponse` として処理する。
   - 403/429 など Gateway 形式のエラーはユーザー向けメッセージへ変換する。
4. API レスポンスから既存 `TrashData` へ変換する。
   - 対応する `type`: `burn`, `unburn`, `resource`, `plastic`, `bin`, `can`, `petbottle`, `coarse`, `paper`, `other`
   - `other` は `trash_name` を `trashVal` に格納する。
   - 対応する `schedule`: `weekday`, `biweek`, `month`, `evweek`
   - `unsupported` は保存対象から除外する。
5. 正常反映処理を UseCase に追加する。
   - 既存データ削除。
   - 変換済みデータ登録。
   - グローバル例外日は現時点では API 仕様にないため維持する。
   - リモート同期待ち状態へ変更。
   - ローカルキャッシュを更新する。
6. 取り込み UI を追加する。
   - アプリ初回起動時のみ自動取り込みダイアログを表示する。
   - ゴミ出し予定一覧画面最下部に取り込みボタンを追加する。
   - ダイアログにはタイトル、入力欄、実行、キャンセル、注釈リンクを配置する。
   - 実行またはキャンセルで閉じた時点で、以降の初回起動ダイアログを表示しない状態に更新する。
7. 非同期実行と結果通知を実装する。
   - 実行直後に「取り込みには数分かかる可能性がある」「結果は一覧画面で確認する」旨を表示してダイアログを閉じる。
   - 処理完了時にローカル通知を表示する。
   - エラー時もローカル通知を表示する。
8. 編集画面でメッセージを表示する。
   - 正常レスポンス反映後は取り込み完了メッセージを表示する。
   - エラーの場合はエラー内容を表示する。
   - メッセージは取り込み処理直後のみ表示し、表示後に消す。
9. CI/CD を修正する。
   - 自動取り込み API のエンドポイントを config で、API キーを `--dart-define` で渡せるようにする。
   - GitHub Actions のシークレット名は `TRASH_SEARCH_API_KEY` とする。

## エージェント編成

- manager: 計画管理、要求整合、タスク更新、最終確認。
- developer: Model/Repository/UseCase/UI/テスト実装。TDD と verification-loop を担当。
- reviewer: 実装後レビュー、セキュリティ観点、Copilot review の実行。
- devops: CI/CD の dart-define 追加、必要時に GitHub Actions の結果監視。

## 実装順序

1. Model と変換ロジックの失敗テストを追加する。
2. API クライアントの失敗テストを追加する。
3. Repository/UseCase の失敗テストを追加する。
4. Widget テストを追加する。
5. Model/API/UseCase を実装する。
6. UI と初回表示状態を実装する。
7. 通知と編集画面メッセージを実装する。
8. CI/CD を更新する。
9. `dart run build_runner build --delete-conflicting-outputs` を必要に応じて実行する。
10. `flutter test` と `flutter analyze` を実行する。
11. タスク一覧を更新し、実装内容とドキュメントの差異を確認する。

## 未確定事項

- 既存データ削除時にグローバル例外日も削除するか。
  - 初期案: API 仕様に含まれないため維持する。
- API の処理が数分かかる場合、モバイル OS のバックグラウンド制約下で完了通知を保証できるか。
  - 初期案: アプリプロセス内 Future とローカル通知で実装し、バックグラウンド保証はしない。

## 命名

- Config
  - `trashSearchApiEndpoint`
- Dart define
  - `trashSearchApiKey`
- GitHub Actions secrets
  - `TRASH_SEARCH_API_KEY`
