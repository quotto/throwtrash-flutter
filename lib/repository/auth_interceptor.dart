import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Firebase Authentication IDトークンをHTTPリクエストに設定するインターセプター
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final _logger = Logger();

  AuthInterceptor(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get the current user from Firebase
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated');
    }
    // Get a fresh ID token
    final idToken = await user.getIdToken(true);

    // Add the token to the Authorization header
    if (idToken != null) {
      request.headers['Authorization'] = idToken;
    }

    // Forward the request to the inner client
    return _inner.send(request);
  }
}
