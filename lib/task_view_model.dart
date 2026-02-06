import 'package:flutter/material.dart';
import 'data/api_models.dart';
import 'data/taskfit_api.dart';

class TaskViewModel extends ChangeNotifier {
  final TaskFitApi api;
  List<dynamic> tasks = [];
  bool isLoading = false;

  // 선택된 목표 정보 (GoalSettingScreen에서 설정)
  String? selectedCompanyName;
  String? selectedJobRoleName;

  TaskViewModel({required this.api});

  void setGoal({required String companyName, required String jobRoleName}) {
    selectedCompanyName = companyName;
    selectedJobRoleName = jobRoleName;
    notifyListeners();
  }

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();
    try {
      // TaskListResponse: { items, total, page, page_size }
      final response = await api.getTasks(page: 1);
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
