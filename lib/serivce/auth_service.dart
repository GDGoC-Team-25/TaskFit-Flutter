import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/api_models.dart';
import '../data/taskfit_api.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();

  Future<User?> signInWithGoogle(TaskFitApi api) async {
    try {
      String? idToken;
      UserCredential userCredential;

      if (kIsWeb) {
        // 웹: Firebase Auth의 signInWithPopup 사용
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await _auth.signInWithPopup(googleProvider);
        // OAuth credential에서 Google ID 토큰 추출 (Firebase 토큰이 아닌 Google 토큰)
        final oauthCredential = userCredential.credential as OAuthCredential?;
        idToken = oauthCredential?.idToken;
      } else {
        // 모바일: google_sign_in 패키지 사용
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize(
          serverClientId: '1060861944023-01ai5fh1she3td57odrj7tdd6dbegjtc.apps.googleusercontent.com',
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        idToken = googleAuth.idToken;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      print('구글 토큰: $idToken');

      if (idToken == null) return null;

      // 백엔드 서버에 idToken 전달 → JWT 발급
      final response = await api.loginWithGoogle(
        GoogleLoginRequest(id_token: idToken),
      );

      // 서버에서 받은 JWT 토큰 저장
      if (response['access_token'] != null) {
        await storage.write(key: 'jwt_token', value: response['access_token']);
      }

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In/Backend Auth Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
    await storage.delete(key: 'jwt_token');
  }
}
