import 'package:flutter/material.dart';
import 'data/api_models.dart';
import 'data/taskfit_api.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskFitApi api;
  List<dynamic> tasks = [];
  bool isLoading = false;

  TaskViewModel({required this.api});

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();
    try {
      // 1. page 파라미터를 명시적으로 추가합니다. (기본값 1)
      final response = await api.getTasks(page: 1);

      // API 응답 구조에 따라 데이터를 리스트에 할당합니다.
      tasks = response['items'] as List<dynamic>? ?? [];
    } catch (e) {
      print("Fetch Tasks Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateNewTasks(int companyId, int jobId) async {
    try {
      await api.generateTasks(TaskGenerateRequest(
        company_id: companyId,
        job_role_id: jobId,
      ));
      await fetchTasks();
      return true;
    } catch (e) {
      return false;
    }
  }
}