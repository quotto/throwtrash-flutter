# AGENTS.md

このドキュメントは、Flutter アプリケーション開発エージェント向けのガイドラインを定義する。

## コードの書き方
- コードコメントは日本語で記載すること。
- コメントはコードの意図や動作を明確にするために記すこと。コードを見れば明らかな内容はコメントしないこと。
- Lint は `analysis_options.yaml`（`flutter_lints`）に従うこと。
- 非推奨 API は可能な限り最新 API に置き換えること。

## テストの実装
- コードを新規作成・修正した場合は、必ずテストコードも実装・更新すること。
- テストコードは、実装した機能が正しく動作することを確認するためのものである。
- カバレッジ 100% は必須ではないが、主要機能の動作を確認できるようにすること。
- テストは「単体テスト」と「UI テスト（Widget/Integration）」に分けて実装すること。
- 単体テストは業務ロジック（UseCase/Repository など）を中心に実装すること。
- UI テストはユーザー操作シナリオ単位で実装すること。

## 実装の進め方
- 計画で作成したタスク一覧に基づいて実装を行うこと。対応する計画ファイルの存在を確認すること。
- 記載されている以上の実装を行わないこと。
- コードの新規作成・修正が必要な場合、必ずテストコードも作成・修正すること。
- ソースコード修正後は `flutter analyze` を実行し、必要に応じて `dart fix --apply` を実施すること。
- 実装・テスト以外の作業（レビューや環境セットアップなど）で報告用の記録を作成する場合は `work/reports` 内に Markdown 形式で作成すること。
- テスト完了後、修正後コードとドキュメントに差異がないことを確認し、差異がある場合はドキュメントを修正すること。
- 実装完了時、または計画変更・状況変化が発生した場合はタスク一覧を更新すること。

## Flutter プロジェクト固有ルール
- 本プロジェクトは Flutter 製だが、運用対象は iOS 中心である。
- iOS ビルド前に `ios/.env` を準備すること。
- 環境変数は `--dart-define=KEY=VALUE` で指定し、`lib/repository/environment_provider.dart` で読み込むこと。
- リポジトリ管理可能な設定値は `json/{flavor}/config.json` で管理し、`lib/repository/app_config_provider.dart` で読み込むこと。
- 生成系コマンドの例:
  - Mock/JsonSerializable 更新: `dart run build_runner build --delete-conflicting-outputs`
  - アイコン生成: `dart run flutter_launcher_icons`
- iOS ビルドコマンドの例:
  - `flutter build ios --flavor development(or production) --debug(or --release) --dart-define=FLAVOR=development(or production) --dart-define=alarmApiKey=xxxxxxxxx`