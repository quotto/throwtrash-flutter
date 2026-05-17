class TrashImportMessage {
  final String message;
  final String type;

  const TrashImportMessage._({required this.message, required this.type});

  const TrashImportMessage.success(String message)
    : this._(message: message, type: 'success');

  const TrashImportMessage.error(String message)
    : this._(message: message, type: 'error');

  bool get isSuccess => type == 'success';

  Map<String, dynamic> toJson() => {'message': message, 'type': type};

  factory TrashImportMessage.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as String? ?? '';
    final type = json['type'] as String? ?? 'error';
    return type == 'success'
        ? TrashImportMessage.success(message)
        : TrashImportMessage.error(message);
  }

  factory TrashImportMessage.fromLegacyMessage(String message) {
    return message == 'ゴミ出し予定を取り込みました'
        ? TrashImportMessage.success(message)
        : TrashImportMessage.error(message);
  }
}
