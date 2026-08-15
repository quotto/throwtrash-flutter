# task2: Flutter SDK・Dart 依存関係更新

## 担当

developer

## 状態

完了

## 内容

- Flutter SDK を 3.41.0 に更新する。
- `pubspec.yaml` の SDK 制約を更新する。
- Dart/Flutter パッケージを Flutter 3.41.0 に整合する範囲で更新する。
- 必要な場合のみ生成コードを更新する。

## 完了条件

- `.fvmrc` が Flutter 3.41.0 を指している。
- `pubspec.yaml` の Flutter SDK 制約が Flutter 3.41.0 と整合している。
- `fvm flutter pub get` が成功する。
- `pubspec.lock` の差分が説明できる。
- 生成コードを更新した場合、その理由が記録されている。

## 期待成果物

- `.fvmrc`
- `pubspec.yaml`
- `pubspec.lock`
- 必要な場合のみ生成ファイル

## 実績

- `.fvmrc` と `.fvm/fvm_config.json` を Flutter 3.41.0 に更新した。
- `pubspec.yaml` の Flutter SDK 制約を `^3.41.0` に更新した。
- `PUB_CACHE=/private/tmp/throwtrash-pub-cache` を指定して Flutter 3.41.0 / Dart 3.11.0 で依存解決を行った。
- `fvm flutter pub upgrade` と `fvm flutter pub upgrade --major-versions` を実行し、`pubspec.lock` を更新した。
- discontinued の `uni_links` を削除し、後継の `app_links` へ移行した。
- `flutter_local_notifications` 21 系の API 変更に合わせて `FcmService` を更新した。
- `fvm flutter pub outdated` 相当では、現在の制約で解決可能な更新は適用済み。残り 14 package は `analyzer` / `test` 系などの上限制約により最新へ上げられない。
- 生成コードは `app_links` 導入に伴う plugin registrant の更新のみ。`build_runner` は JSON/model の生成入力を変更していないため実行していない。
