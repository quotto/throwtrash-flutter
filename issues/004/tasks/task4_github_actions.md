# task4: GitHub Actions workflow の追加

## 担当

devops

## 状態

完了

## 内容

- [x] macOS ランナー上で Flutter と Maestro CLI をセットアップする workflow を作成する。
- [x] iOS シミュレータの起動、アプリのビルド / 起動、Maestro 実行を自動化する。
- [x] テスト結果、ログ、スクリーンショットを成果物として収集する。
- [x] アーティファクト保存期間を 7 日に設定する。
- [x] 一時的な開発ブランチ trigger と最終 `release` push trigger の切替手順を整理する。

## 実績

- `.github/workflows/ios-maestro-e2e.yml` を追加し、`release` ブランチ push を最終トリガーとして定義した。
- workflow から `tool/maestro/prepare_ios_ci_env.sh` と `tool/maestro/run_ios_e2e.sh` を呼び出す構成にし、設定復元から実行までを分離した。
- `.maestro-results` を artifact として収集し、保持期間を 7 日に設定した。

## 完了条件

- CI 上で E2E を再現できる workflow 定義がある。
- Maestro レポートが artifact として取得できる。
- 最終トリガー条件が要件どおり `release` push である。

## 期待成果物

- `.github/workflows/` の新規 workflow
- CI 実行用補助スクリプト
- artifact 収集定義
