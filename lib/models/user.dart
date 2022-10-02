class User {
  final String _id;
  String _deviceToken;

  User(this._id, this._deviceToken);

  String get id => _id;
  String get deviceToken => _deviceToken;
}