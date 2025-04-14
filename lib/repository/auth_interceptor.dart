import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Firebase Authentication IDトークンをHTTPリクエストに設定するインターセプター
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;

  AuthInterceptor(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Get the current user from Firebase
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get a fresh ID token
        final idToken = await user.getIdToken(true);

        // Add the token to the Authorization header
        if (idToken != null) {
          request.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (e) {
      print('Error adding auth token to request: $e');
    }

    // Forward the request to the inner client
    return _inner.send(request);
  }
}
