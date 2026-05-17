# task3: iOS/CocoaPods/gem 更新

## 担当

devops

## 状態

完了

## 内容

- Flutter 3.41.0 と更新後依存パッケージに合わせて CocoaPods を更新する。
- `ios/Podfile` と `ios/Podfile.lock` の差分を確認する。
- Ruby/gem の扱いを確認し、Codemagic の install 手順と整合させる。
- Gemfile 追加が必要か判断する。

## 完了条件

- `cd ios && pod install` が成功する。
- `ios/Podfile.lock` の差分が説明できる。
- CocoaPods / xcodeproj / Ruby の指定方針が Codemagic と矛盾していない。
- Gemfile を追加しない場合、その判断理由が記録されている。

## 期待成果物

- `ios/Podfile`
- `ios/Podfile.lock`
- 必要に応じて Gemfile / Gemfile.lock
- CocoaPods/gem 更新メモ

## 実績

- ローカル CocoaPods は 1.16.2、xcodeproj は 1.27.0 を継続利用した。
- `CP_HOME_DIR=/private/tmp/throwtrash-cocoapods-home` を指定して CocoaPods のホーム書き込み権限問題を回避した。
- `pod install` は Firebase 12.8.0 系 lockfile と FlutterFire 12.12.x 要求の不整合で失敗したため、Firebase 関連 Pod を対象に `pod update ... --no-repo-update` を実行した。
- `ios/Podfile.lock` を更新し、Firebase 12.12.x 系と `app_links (7.0.0)` が反映された。
- `ios/Podfile` は変更不要だった。
- Gemfile は追加しない。プロジェクトに既存 Gemfile がなく、Codemagic 側で Ruby / CocoaPods / xcodeproj を明示する方針で整合できるため。
- iOS release framework の `flutter precache --ios` / `--macos` はローカルディスク不足で完走しなかったため、iOS 実機ビルドは未実施。Pod 更新自体は完了している。
