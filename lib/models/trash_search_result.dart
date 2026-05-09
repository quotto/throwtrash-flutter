import 'package:throwtrash/models/trash_data.dart';

enum TrashSearchInputType { postalCode, address }

class TrashSearchResult {
  TrashSearchResult.success(this.trashes) : success = true, message = '';

  TrashSearchResult.failure(this.message) : success = false, trashes = const [];

  final bool success;
  final List<TrashData> trashes;
  final String message;
}

class TrashImportResult {
  TrashImportResult.success() : success = true, message = '自動取り込みが完了しました';

  TrashImportResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}
