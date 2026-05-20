# task4: Codemagic 更新

## 担当

devops

## 状態

完了

## 内容

- `codemagic.yaml` の development / release workflow を Flutter 3.41.0 対応に更新する。
- FVM、Xcode、Ruby、CocoaPods 指定の整合を確認する。
- analyze/test/build の実行順序と `--dart-define` の既存指定を維持する。

## 完了条件

- development / release workflow の設定差分が説明できる。
- Flutter 3.41.0 の利用方法が Codemagic 上で明確である。
- 既存の Firebase 復元、署名、DeployGate/TestFlight 配信手順を壊していない。
- 必要な環境変数や Codemagic 側設定の変更があれば記録されている。

## 期待成果物

- `codemagic.yaml`
- Codemagic 設定更新メモ

## 実績

- `codemagic.yaml` の development / release workflow で `xcodeproj 1.27.0` と `cocoapods 1.16.2` を明示インストールするよう更新した。
- release workflow にも `flutter analyze --no-fatal-infos` を追加し、development workflow と検証粒度を揃えた。
- iOS ビルド前に `flutter precache --ios` を実行する手順を追加した。
- 既存の FVM 利用、Firebase 復元、署名、DeployGate / TestFlight 配信手順は維持した。
