import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../serivce/auth_service.dart';
import 'goal_setting_screen.dart';
import '../main.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('TASK FIT', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SvgPicture.asset('assets/logo.svg',width: 300,),
              const SizedBox(height: 60),
              const Text('로그인', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('취업 준비를 위한 첫걸음', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 116),
              TextButton(
                onPressed: () async {
                  // 실제 로그인 로직 호출
                  User? user = await AuthService().signInWithGoogle();

                  if (user != null) {
                    // 로그인 성공 시 다음 화면으로 이동
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const GoalSettingScreen()),
                      );
                    }
                  } else {
                    // 실패 시 알림 (예: 스낵바)
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('로그인에 실패했습니다.')),
                      );
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: SvgPicture.asset('assets/google_sign_in.svg', width: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
