import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/models/trash_search_result.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';

Future<void> showAutoImportDialog(
  BuildContext context, {
  bool updateInitialDisplayStatus = false,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AutoImportDialog(
      updateInitialDisplayStatus: updateInitialDisplayStatus,
    ),
  );
}

class AutoImportDialog extends StatefulWidget {
  const AutoImportDialog({super.key, required this.updateInitialDisplayStatus});

  final bool updateInitialDisplayStatus;

  @override
  State<AutoImportDialog> createState() => _AutoImportDialogState();
}

class _AutoImportDialogState extends State<AutoImportDialog> {
  final TextEditingController _controller = TextEditingController();
  late final TapGestureRecognizer _noteTapRecognizer;

  @override
  void initState() {
    super.initState();
    _noteTapRecognizer = TapGestureRecognizer()..onTap = _showNoteDialog;
  }

  @override
  void dispose() {
    _noteTapRecognizer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showNoteDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('留意事項'),
        content: Text(
          '・AIによる自動登録機能であるため誤りを含む可能性があります。\n'
          '・現在登録済みのデータは削除されます。\n'
          '・住所を入力する際は番地等の詳細は入力しないでください。町名や丁目など、自治体で定められたゴミ出し予定の判別に必要十分な粒度で入力してください（例: 東京都新宿区西新宿2丁目）。\n'
          '・入力された情報はアプリ提供者側で一切保存・流用しません。また当機能に利用するAIは入力データの学習を無効化していますが、万が一当機能へのデータ入力により何らかの損害が発生した場合でもアプリ提供者は一切の責任を負いかねますのでご了承ください。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('閉じる'),
          ),
        ],
      ),
    );
  }

  Future<void> _markInitialDialogShown(
    TrashDataServiceInterface service,
  ) async {
    if (widget.updateInitialDisplayStatus) {
      await service.markInitialSearchDialogShown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<TrashDataServiceInterface>(
      context,
      listen: false,
    );
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('AI取り込み（β）'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: Key('auto-import-input'),
                controller: _controller,
                decoration: InputDecoration(labelText: '郵便番号または住所'),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                onChanged: (_) => setState(() {}),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  key: Key('auto-import-note-link'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _showNoteDialog,
                  child: Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '留意事項',
                          recognizer: _noteTapRecognizer,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: 'を読み、詳細な住所を入力しないようにしてください'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: Key('auto-import-cancel'),
            onPressed: () async {
              await _markInitialDialogShown(service);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text('キャンセル'),
          ),
          ElevatedButton(
            key: Key('auto-import-submit'),
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () async {
                    final input = _controller.text.trim();
                    unawaited(
                      service.importTrashSchedule(input).catchError((_) {
                        return TrashImportResult.failure('AI取り込みに失敗しました。');
                      }),
                    );
                    unawaited(_markInitialDialogShown(service));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '取り込みには数分かかる可能性があります。結果はゴミ出し予定一覧画面を開いて確認してください。',
                          ),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
            child: Text('実行'),
          ),
        ],
      ),
    );
  }
}
