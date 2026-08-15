# Flutter 3.41.0 対応リファクタリング要件

## 概要

Flutter を安定版 3.41.0 に更新し、iOS 中心の運用に必要な依存関係、CocoaPods、Ruby gem、Codemagic 設定を追従させる。あわせてコード上の deprecated API と `flutter analyze` の `info` 指摘を可能な限り解消する。

## 背景

- 現在の `.fvmrc` は Flutter 3.38.1 を指定している。
- `pubspec.yaml` の Flutter SDK 制約も `^3.38.1` である。
- Codemagic は `flutter: fvm` を利用しており、CI の Flutter バージョンはリポジトリ内の FVM 設定に依存する。
- 既存の `issues/001/tasks/task4_ci_review.md` によると、現時点で `flutter analyze` は error なしだが info 指摘が 247 件ある。
- Flutter 3.41.0 は公式の Flutter release notes に stable release として掲載されている。

## 対象範囲

- Flutter SDK 設定
  - `.fvmrc`
  - `pubspec.yaml`
  - `pubspec.lock`
- Dart/Flutter 依存パッケージ
  - `dependencies`
  - `dev_dependencies`
  - 生成コードが必要な場合の `build_runner` 実行
- iOS 依存関係
  - `ios/Podfile`
  - `ios/Podfile.lock`
  - CocoaPods 関連設定
- Ruby gem
  - プロジェクト内に Gemfile が存在しないため、Codemagic 上の Ruby/CocoaPods/gem install 手順を中心に確認する。
  - Gemfile を追加する必要がある場合は、理由と影響範囲を計画変更として記録してから実施する。
- Codemagic
  - `codemagic.yaml`
  - development / release 両 workflow
- Dart/Flutter コード
  - deprecated API の置き換え
  - `flutter analyze` の `info` 指摘の解消

## 対象外

- 新機能追加
- 画面仕様や業務仕様の変更
- テストコードの原則的な修正
- 既存テストの期待値変更による挙動変更の追認
- 本対応に直接関係しないリファクタリング

## テストコードの扱い

- テストコードの修正は原則行わない。
- Flutter/依存関係更新後にテストが失敗した場合は、まず原因を分類する。
  - SDK・依存パッケージ更新による API 変更
  - 実装コードの deprecated 解消に伴う挙動変化
  - テスト側の古い API 利用
  - 既存実装の潜在不具合の顕在化
- テストコード修正が必要と判断した場合は、実装前に `issues/003` のタスクと計画を更新し、修正理由を明記する。

## 作業場所

- 現在のディレクトリでは機能改修が進行中のため、直接作業しない。
- 現在のブランチ `feature/schedule-search` から作成した worktree で作業する。
- 作業用 worktree:
  - `/Volumes/extend/project/throwtrash-flutter-refactor-flutter-3-41`
- 作業ブランチ:
  - `refactor/flutter-3-41-upgrade`

## 完了条件

- Flutter SDK が 3.41.0 に更新されている。
- 依存パッケージ、CocoaPods、必要な Ruby gem/Codemagic 設定が Flutter 3.41.0 に整合している。
- `flutter analyze` の error / warning がない。
- `flutter analyze` の `info` 指摘が可能な限り解消され、残すものは理由を記録している。
- deprecated API が可能な限り解消され、残すものは理由を記録している。
- `flutter test` の結果を確認している。
- テスト失敗が残る場合は、原因分析と改修計画を `issues/003` または `work/reports` に記録している。
- Codemagic の development / release workflow の更新方針と差分が説明できる。
- 実装完了時に `issues/003/tasks/` の状態と実績が更新されている。

## 参照

- Flutter release notes: https://docs.flutter.dev/release/release-notes
- Flutter 3.41.0 release notes: https://docs.flutter.dev/release/release-notes/release-notes-3.41.0
