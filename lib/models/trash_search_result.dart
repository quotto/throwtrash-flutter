import 'package:throwtrash/models/trash_data.dart';

enum TrashSearchInputType { postalCode, address }

class TrashSearchResult {
  TrashSearchResult.success(this.trashes, {this.message = 'ゴミ出し予定を取り込みました'})
    : success = true;

  TrashSearchResult.failure(this.message) : success = false, trashes = const [];

  final bool success;
  final List<TrashData> trashes;
  final String message;
}

class TrashImportResult {
  TrashImportResult.success([this.message = 'ゴミ出し予定を取り込みました']) : success = true;

  TrashImportResult.failure(this.message) : success = false;

  final bool success;
  final String message;
}
