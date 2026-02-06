import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'login_screen.dart';

void main() {
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
