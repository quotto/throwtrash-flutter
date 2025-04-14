import 'package:firebase_auth/firebase_auth.dart' as auth;

class User {
  final String _id;
  final bool _isAuthenticated;
  final String? _email;
  final String? _displayName;
  final String? _photoUrl;

  User(
    this._id, {
    bool isAuthenticated = false,
    String? email,
    String? displayName,
    String? photoUrl,
  })  : _isAuthenticated = isAuthenticated,
        _email = email,
        _displayName = displayName,
        _photoUrl = photoUrl;

  String get id => _id;
  bool get isAuthenticated => _isAuthenticated;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get photoUrl => _photoUrl;

  // Factory method to create a User from a FirebaseAuth user
  factory User.fromFirebaseUser(auth.User firebaseUser, {String? existingUserId}) {
    return User(
      existingUserId ?? firebaseUser.uid,
      isAuthenticated: !firebaseUser.isAnonymous,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Factory method for anonymous user
  factory User.anonymous(String userId) {
    return User(userId, isAuthenticated: false);
  }
}
