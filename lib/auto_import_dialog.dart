import 'dart:async';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        title: Text('自動取り込み（β）'),
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
                child: TextButton(
                  key: Key('auto-import-note-link'),
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('留意事項'),
                        content: Text(
                          'AIによる自動判別機能であるため誤りを含む可能性があります。\n'
                          '現在登録済みのデータは削除されます。\n'
                          '住所は番地等の詳細まで入力せず、識別可能な粒度で入力してください。\n'
                          '入力された情報は管理側では保存・流用しませんが、入力は自己責任で行ってください。',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('閉じる'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('留意事項'),
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
                    await _markInitialDialogShown(service);
                    final input = _controller.text.trim();
                    unawaited(
                      service.importTrashSchedule(input).catchError((_) {
                        return TrashImportResult.failure('自動取り込みに失敗しました。');
                      }),
                    );
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
