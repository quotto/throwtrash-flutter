class StartLinkException implements Exception {
  final String _message;
  const StartLinkException(this._message);

  @override
  String toString()=>_message;
}