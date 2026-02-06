import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:taskfit/task_view_model.dart';
import 'core/api_client.dart';
import 'data/taskfit_api.dart';

import 'presentation/login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final apiClient = ApiClient();
  final taskFitApi = TaskFitApi(apiClient.dio);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: taskFitApi),
        ChangeNotifierProvider(create: (_) => TaskViewModel(api: taskFitApi)),
      ],
      child: const TaskFitApp(),
    ),
  );
}

class TaskFitApp extends StatelessWidget {
  const TaskFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskFit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B5BFF)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      ),
      home: const LoginScreen(),
    );
  }
}