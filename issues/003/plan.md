# issues/003 対応計画

## 対象

Flutter 3.41.0 への更新、依存関係更新、Codemagic 更新、deprecated / analyze info 指摘の解消を行う。

## 前提

- 実装前に本計画の承認を得る。
- 作業は `/Volumes/extend/project/throwtrash-flutter-refactor-flutter-3-41` で行う。
- 元の worktree `/Volumes/extend/project/throwtrash-flutter` は進行中の機能改修用として触らない。
- テストコードは原則修正しない。
- 計画以上の機能改修や仕様変更は行わない。
- コードコメントを追加・更新する場合は日本語で記載する。
- iOS ビルド前に `ios/.env` が必要である。

## エージェント編成

- manager: 要件管理、タスク分割、作業ブランチ/worktree 管理、最終統合判断。
- developer: Flutter SDK/依存関係更新、deprecated/analyze info 対応、ローカル検証。
- devops: Codemagic、CocoaPods、Ruby/gem、iOS ビルド手順の更新確認。
- reviewer: 差分レビュー、挙動変更リスク確認、テストコード非修正方針の逸脱確認。

## 実装方針

1. ベースラインを記録する。
   - `fvm flutter --version`
   - `fvm dart --version`
   - `fvm flutter analyze`
   - `fvm flutter test`
   - `fvm flutter pub outdated`
   - `pod --version`
   - `ruby --version`
   - `gem list cocoapods xcodeproj`
2. Flutter 3.41.0 に更新する。
   - `.fvmrc` を 3.41.0 に更新する。
   - `pubspec.yaml` の Flutter SDK 制約を更新する。
   - `fvm install 3.41.0` と `fvm use 3.41.0` の結果を確認する。
3. Dart/Flutter 依存関係を更新する。
   - `fvm flutter pub upgrade` または必要に応じて `--major-versions` を検討する。
   - major update は破壊的変更を確認し、必要最小限で適用する。
   - 生成コードが影響する場合のみ `fvm dart run build_runner build --delete-conflicting-outputs` を実行する。
4. iOS 依存関係を更新する。
   - `fvm flutter pub get`
   - `cd ios && pod repo update && pod install` または必要に応じて `pod update`
   - `ios/Podfile.lock` の差分を確認する。
5. Codemagic を更新する。
   - Flutter 3.41.0 / FVM 設定との整合を確認する。
   - CocoaPods / Ruby / Xcode 指定が Codemagic の提供環境と合うか確認する。
   - development / release workflow の差分を揃える。
6. deprecated API を解消する。
   - `flutter analyze` と IDE 相当の指摘をもとに、挙動変更が少ない置換から対応する。
   - 非推奨 API の置換で仕様が変わる場合は、対応前にタスクへ理由を記録する。
7. `flutter analyze` の `info` 指摘を解消する。
   - 機械的に安全な指摘から対応する。
   - 仕様や公開 API に関わる指摘は、残す理由または別対応計画を記録する。
8. 検証する。
   - `fvm flutter analyze`
   - `fvm flutter test`
   - iOS ビルドは環境変数が揃う場合のみ実行する。
   - 実行できない検証は理由と代替確認を記録する。
9. ドキュメントとタスクを更新する。
   - `issues/003/tasks/*.md`
   - 必要に応じて `work/reports/*.md`

## タスク一覧

| タスク | 担当 | 状態 | 完了条件 |
| --- | --- | --- | --- |
| task1: ベースライン調査・worktree 確認 | manager | 完了 | 現状バージョン、analyze/test/outdated の結果が記録されている |
| task2: Flutter SDK・Dart 依存関係更新 | developer | 完了 | Flutter 3.41.0 で `pub get` が通り、lockfile 差分が説明できる |
| task3: iOS/CocoaPods/gem 更新 | devops | 完了 | Pod 関連更新が完了し、iOS ビルド前提の差分が説明できる |
| task4: Codemagic 更新 | devops | 完了 | development/release workflow が Flutter 3.41.0 と整合している |
| task5: deprecated/analyze info 対応 | developer | 完了 | 可能な限り指摘を解消し、残件理由を記録している |
| task6: 検証・レビュー | reviewer | 完了 | analyze/test 結果、残リスク、テストコード非修正方針の逸脱有無が確認されている |

## 検証コマンド

```sh
fvm flutter --version
fvm dart --version
fvm flutter pub get
fvm flutter pub outdated
fvm flutter analyze
fvm flutter test
cd ios && pod install
```

必要に応じて実行する。

```sh
fvm dart run build_runner build --delete-conflicting-outputs
cd ios && pod update
fvm flutter build ios --flavor development --debug --dart-define=FLAVOR=development --dart-define=alarmApiKey=xxxxxxxxx
```

## リスクと対応

- Flutter 3.41.0 による Dart SDK 更新で依存パッケージの下限・上限に衝突する可能性がある。
  - `pub outdated` と `pub upgrade --dry-run` で更新幅を確認してから適用する。
- major update により実装 API が変わる可能性がある。
  - 破壊的変更のあるパッケージは個別に差分を確認する。
- CocoaPods / Ruby / Xcode の組み合わせが Codemagic とローカルで異なる可能性がある。
  - ローカル結果と CI 設定の両方を記録し、Codemagic 側でのみ必要な対応を分離する。
- analyze info を全解消しようとして仕様変更が混入する可能性がある。
  - 機械的・局所的な修正を優先し、仕様判断が必要なものは残件化する。
- テストコード非修正方針により、SDK 更新起因のテスト失敗が残る可能性がある。
  - 失敗原因を記録し、必要な場合はテスト修正タスクを追加提案する。

## 未確定事項

- Codemagic で利用可能な Xcode / Ruby / CocoaPods の最新指定値。
- Flutter 3.41.0 と組み合わせるべき最小 iOS deployment target。
- major update を許容する依存パッケージの範囲。
- iOS 実機または Simulator ビルドをこの作業内で実施するか。
