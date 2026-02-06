import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // 싱글톤 인스턴스를 사용합니다.
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithGoogle() async {
    try {
      // 1. 전달해주신 클라이언트 ID로 초기화를 수행합니다.
      // 안드로이드 환경에서는 이 serverClientId가 필수적으로 요구됩니다.
      await _googleSignIn.initialize(
        serverClientId: '1060861944023-01ai5fh1she3td57odrj7tdd6dbegjtc.apps.googleusercontent.com',
      );

      // 2. 구글 인증창을 띄워 사용자의 계정 선택을 받습니다.
      // 7.x 버전의 소스 코드에 명시된 authenticate 메서드를 사용합니다.
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        print("사용자가 로그인을 취소했습니다.");
        return null;
      }

      // 3. 계정으로부터 인증 정보를 가져옵니다.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Firebase 인증에 필요한 자격 증명(Credential)을 생성합니다.
      // 보내주신 소스 구조에 맞춰 idToken만을 사용합니다.
      print('구글 id token');
      print(googleAuth.idToken);
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      print('구글 로그인');
      print(credential);
      // 5. 생성된 자격 증명으로 Firebase에 로그인을 수행합니다.
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      // 설정 문제나 네트워크 오류 시 이곳에서 에러가 캡처됩니다.
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // 로그아웃 메서드도 함께 구성해 두면 관리하기 편합니다.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}