# 今日ゴミ出し（iOSアプリ）

iOS用のゴミ出しアプリです。Flutterで作成していますが訳あってiOSのみの対応です。

[AppStoreでアプリを公開しています。](https://apps.apple.com/jp/app/%E4%BB%8A%E6%97%A5%E3%81%AE%E3%82%B4%E3%83%9F%E5%87%BA%E3%81%97-%E3%82%B9%E3%83%9E%E3%83%BC%E3%83%88%E3%82%B9%E3%83%94%E3%83%BC%E3%82%AB%E3%83%BC%E9%80%A3%E6%90%BA/id6450391257)

## 開発メモ
### ビルド
- ビルド前にios/.envファイルを作成してください。このファイルはXCode内のRun Scriptで読み込まれます。
- ビルド時に必要なパラメータは`Build Settings`タブの`User-Defined`セクションに追加してください。
- ビルドのコマンドは`flutter build ios --flavor development(or production) --debug(or --release) --dart-define=FLAVOR=development(or production) --dart-define=alarmApiKey=xxxxxxxxx`です。

### アプリ内で利用する外部パラメーター
- 環境変数はビルドパラメータに`--dart-define=KEY=VALUE`を追加します。値の読み込みは`lib/repository/environment_provider.dart`を利用します。
- リポジトリコミット可能なパラメーター値は`json/{flavor}/config.json`に保存します。これらの値は`lib/repository/confiv_provider.dart`を利用します。

### その他
- Mockの追加やJsonSerializableの追加時: `dart run build_runner build --delete-conflicting-outputs`を実行
- アイコンの生成: `dart run flutter_launcher_icons`
