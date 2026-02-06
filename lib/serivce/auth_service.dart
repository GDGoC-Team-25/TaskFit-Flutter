import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../data/api_models.dart';
import '../data/taskfit_api.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storage = const FlutterSecureStorage();

  Future<User?> signInWithGoogle(TaskFitApi api) async {
    try {
      await _googleSignIn.initialize(
        serverClientId: '1060861944023-01ai5fh1she3td57odrj7tdd6dbegjtc.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      print('구글 토큰');
      print(googleAuth.idToken);
      // 1. 백엔드 서버에 Google idToken 전달
      final response = await api.loginWithGoogle(
        GoogleLoginRequest(id_token: googleAuth.idToken!),
      );


      // 2. 서버에서 받은 JWT 토큰 저장
      if (response['access_token'] != null) {
        await storage.write(key: 'jwt_token', value: response['access_token']);
      }

      // 3. Firebase 로그인 수행
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Google Sign-In/Backend Auth Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await storage.delete(key: 'jwt_token');
  }
}