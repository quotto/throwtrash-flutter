import 'package:flutter/material.dart';
import 'package:throwtrash/auto_import_dialog.dart';
import 'package:throwtrash/edit.dart';
import 'package:throwtrash/usecase/trash_data_service_interface.dart';
import 'package:throwtrash/viewModels/edit_model.dart';
import 'package:throwtrash/viewModels/list_model.dart';
import 'package:provider/provider.dart';
import 'package:throwtrash/view_common/app_feedback.dart';
import 'package:throwtrash/view_common/trash_color.dart';

class TrashList extends StatefulWidget {
  const TrashList({super.key});

  @override
  State<TrashList> createState() => _TrashListState();
}

class _TrashListState extends State<TrashList> {
  bool _importMessageLoaded = false;

  final _successSnackBar = AppFeedbackSnackBar.success(
    '削除しました',
    duration: Duration(seconds: 1),
  );
  final _failedSnackBar = AppFeedbackSnackBar.error(
    '削除に失敗しました',
    duration: Duration(seconds: 1),
  );

  Widget _identified(String id, Widget child) {
    return Semantics(identifier: id, child: child);
  }

  Widget _trashTypeMarker(String trashType) {
    return SizedBox(
      width: 1,
      height: 1,
      child: Semantics(
        container: true,
        identifier: 'trash-list-$trashType',
        label: 'trash-list-$trashType',
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_importMessageLoaded) {
      return;
    }
    _importMessageLoaded = true;
    final trashDataService = Provider.of<TrashDataServiceInterface>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final message = await trashDataService.consumeImportMessage();
      if (message != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppFeedbackSnackBar.importMessage(message));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_importMessageLoaded) {
      return;
    }
    _importMessageLoaded = true;
    final trashDataService = Provider.of<TrashDataServiceInterface>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final message = await trashDataService.consumeImportMessage();
      if (message != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(AppFeedbackSnackBar.importMessage(message));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('登録されているゴミ出し予定')),
      body: Consumer<ListModel>(
        builder: (context, list, child) {
          return ListView.separated(
            itemCount: list.trashList.length + 1,
            separatorBuilder: (context, index) =>
                Divider(color: Theme.of(context).dividerColor),
            itemBuilder: (context, index) {
              if (index == list.trashList.length) {
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    key: Key('open-auto-import-dialog'),
                    icon: Icon(Icons.cloud_download),
                    label: Text('自動取り込み（β）'),
                    onPressed: () {
                      showAutoImportDialog(context).then((_) {
                        list.reload();
                      });
                    },
                  ),
                );
              }
              TrashListData trashData = list.trashList[index];
              debugPrint('$index:${trashData.id}');
              return _identified(
                'trash-row-index-$index',
                _identified(
                  'trash-row-${trashData.id}',
                  Row(
                    key: Key('trash-row-${trashData.id}'),
                    children: [
                      _trashTypeMarker(trashData.type),
                      Expanded(
                        child: _identified(
                          'edit-trash-index-$index',
                          _identified(
                            'edit-trash-${trashData.id}',
                            Semantics(
                              button: true,
                              label: '編集',
                              child: Tooltip(
                                message: '編集',
                                child: InkWell(
                                  key: Key('edit-trash-${trashData.id}'),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        trashData.name,
                                        style: TextStyle(
                                          color: trashColor(
                                            trashData.type,
                                            Theme.of(context).brightness,
                                          ),
                                          fontSize: 24,
                                        ),
                                      ),
                                      Column(
                                        children: trashData.schedules
                                            .map<Widget>(
                                              (schedule) => Text(schedule),
                                            )
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    final trashDataService =
                                        Provider.of<TrashDataServiceInterface>(
                                          context,
                                          listen: false,
                                        );
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChangeNotifierProvider<
                                            EditModel
                                          >(
                                            create: (context) =>
                                                EditModel(trashDataService),
                                            child: EditItemMain.update(
                                              trashData.id,
                                            ),
                                          );
                                        },
                                      ),
                                    ).then((result) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      if (result != null && result) {
                                        list.reload();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _identified(
                          'copy-trash-index-$index',
                          _identified(
                            'copy-trash-${trashData.id}',
                            IconButton(
                              key: Key('copy-trash-${trashData.id}'),
                              tooltip: 'コピー',
                              icon: Icon(Icons.content_copy),
                              iconSize: 32,
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: () {
                                final trashDataService =
                                    Provider.of<TrashDataServiceInterface>(
                                      context,
                                      listen: false,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChangeNotifierProvider<EditModel>(
                                        create: (context) =>
                                            EditModel(trashDataService),
                                        child: EditItemMain.copyFrom(
                                          trashData.id,
                                        ),
                                      );
                                    },
                                  ),
                                ).then((result) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (result != null && result) {
                                    list.reload();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: _identified(
                          'delete-trash-index-$index',
                          _identified(
                            'delete-trash-${trashData.id}',
                            IconButton(
                              key: Key('delete-trash-${trashData.id}'),
                              tooltip: '削除',
                              icon: Icon(Icons.delete_forever),
                              iconSize: 32,
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () {
                                list.deleteTrashData(index).then((result) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (result) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(_successSnackBar);
                                  } else {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(_failedSnackBar);
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
