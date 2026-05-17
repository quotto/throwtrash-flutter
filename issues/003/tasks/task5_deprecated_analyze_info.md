# task5: deprecated/analyze info 対応

## 担当

developer

## 状態

完了

## 内容

- deprecated API を可能な限り最新 API に置き換える。
- `flutter analyze` の `info` 指摘を可能な限り解消する。
- 仕様変更やテストコード修正が必要な指摘は無理に対応せず、残件として記録する。

## 完了条件

- `fvm flutter analyze` の error / warning がない。
- `info` 指摘が可能な限り解消されている。
- 残す `info` 指摘は理由と対応案が記録されている。
- deprecated API の残件がある場合、理由と対応案が記録されている。
- テストコードを修正していない。修正が必要な場合は事前に計画を更新している。

## 期待成果物

- 実装コード差分
- analyze 指摘の解消結果
- 残件一覧

## 実績

- `fvm dart fix --apply` を実行し、機械的に安全な `prefer_const_constructors`、`unnecessary_this`、`unnecessary_new`、import 整理などを適用した。
- `fvm dart format lib` を実行した。
- `uni_links` を `app_links` に置き換え、初期リンク取得と URI stream 購読を更新した。
- `withOpacity`、`textScaleFactor`、`dialogBackgroundColor`、不要な `Container`、`print` など、局所的に置換できる deprecated / info 指摘を解消した。
- async 後に UI context を使う箇所へ `mounted` / `context.mounted` guard を追加した。
- `constant_identifier_names` は挙動互換とテストコード非修正方針を優先し、該当ファイルに lint directive を追加して明示的に許容した。
  - enum 値の大文字名は既存コード・テスト・表示状態との結合が広い。
  - SharedPreferences 等の永続化キー定数は値を変更しないことが重要で、識別子名の一括変更もテストコード修正を伴う。
- `flutter analyze` は `No issues found` で完了した。
- テストコードは修正していない。
