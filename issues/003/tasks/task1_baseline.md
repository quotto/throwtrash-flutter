# task1: ベースライン調査・worktree 確認

## 担当

manager

## 状態

完了

## 内容

- 作業用 worktree とブランチを確認する。
- 現在の Flutter/Dart/依存関係/CocoaPods/Ruby/gem/Codemagic 設定を記録する。
- `flutter analyze` と `flutter test` の更新前結果を記録する。

## 完了条件

- 作業場所が `/Volumes/extend/project/throwtrash-flutter-refactor-flutter-3-41` であることを確認している。
- ベースライン結果を `work/reports` または本タスクの実績に記録している。
- 更新前の analyze/test の状態が説明できる。

## 期待成果物

- ベースライン調査結果
- 更新対象ファイル一覧
- 作業前リスクの整理

## 実績

- 作業場所が `/Volumes/extend/project/throwtrash-flutter-refactor-flutter-3-41`、ブランチが `refactor/flutter-3-41-upgrade` であることを確認した。
- Flutter 3.38.1 / Dart 3.10.0 を更新前ベースラインとして確認した。
- Ruby 3.2.1、CocoaPods 1.16.2、xcodeproj 1.27.0 を確認した。
- `fvm flutter pub outdated` で 42 件の locked update、10 件の制約起因 update、`uni_links` discontinued を確認した。
- `PUB_CACHE` 指定後の `fvm flutter analyze` は error / warning なし、info 247 件だった。
- `.tmp` 作成後の `fvm flutter test` は 262 件すべて通過した。
- 詳細は `work/reports/issues_003_baseline.md` に記録した。
