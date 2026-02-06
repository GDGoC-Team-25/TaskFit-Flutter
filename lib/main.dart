import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskfit/presentation/login_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // 3. 이제 빨간 줄이 사라질 것입니다.
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TaskFitApp());
}

class TaskFitApp extends StatelessWidget {
  const TaskFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '직무 시험 AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BFF)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        fontFamily: 'Pretendard',
      ),
      home: const LoginScreen(),
    );
  }
}
