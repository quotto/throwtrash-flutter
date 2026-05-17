# task3: アプリ側の E2E 安定化対応

## 担当

developer

## 状態

完了

## 内容

- [x] Maestro で不安定になりやすい操作箇所を洗い出す。
- [x] 必要最小限の widget key やテスト補助を追加する。
- [x] 初期データ削除またはクリーン起動を実現する方法を実装する。
- [x] 追加した補助コードに対応するテストを更新する。

## 実績

- `lib/calendar.dart` `lib/edit.dart` `lib/list.dart` に E2E 用の安定した識別子を追加した。
- `launchApp: { clearState: true }` と install 前提の実行スクリプトにより、SharedPreferences に依存しないクリーン起動方針を反映した。
- `test/widget/widget_test.dart` `test/widget/edit_item_main_test.dart` `test/widget/trash_list_copy_test.dart` を更新し、追加した識別子の存在を検証できるようにした。
- iOS accessibility でカレンダー全体のラベルへ結合されるゴミ名を Maestro が単独テキストとして検出できないため、カレンダーの各ゴミ表示に `calendar-trash-{type}` の Semantics identifier を追加した。
- iOS accessibility で一覧行のゴミ名も行全体のラベルへ結合されるため、一覧行に `trash-list-{type}` の Semantics identifier を追加した。
- コピー作成後に一覧へ戻った際、repository への追加結果が in-memory の予定一覧へ反映されない不整合を修正した。

## 完了条件

- シナリオ実行に必要な UI 要素を安定して特定できる。
- 各シナリオが前回実行結果に依存せず開始できる。
- 本番挙動を変えない範囲でテスト容易性が向上している。

## 期待成果物

- アプリ本体の最小差分
- 関連する unit / widget test 更新
- E2E 安定化方針メモ
