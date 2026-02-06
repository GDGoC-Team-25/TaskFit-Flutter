import 'package:taskfit/data/taskfit_api.dart';

import 'api_models.dart';


class TaskRepository {
  final TaskFitApi api;

  TaskRepository(this.api);

  // 기업 검색
  Future<List<dynamic>> searchCompanies(String query) async {
    try {
      return await api.searchCompanies(query, 20);
    } catch (e) {
      print("기업 검색 실패: $e");
      return [];
    }
  }

  // 직무 검색
  Future<List<dynamic>> searchJobRoles(String? category, String query) async {
    try {
      return await api.searchJobRoles(category, query);
    } catch (e) {
      print("직무 검색 실패: $e");
      return [];
    }
  }

  // 과제 제출 및 스레드 생성
  Future<int?> submitTask(int taskId, String content) async {
    try {
      final response = await api.createSubmission(SubmissionCreateRequest(
        task_id: taskId,
        content: content,
        is_draft: false,
      ));
      return response['thread_id']; // 생성된 채팅방 ID 반환
    } catch (e) {
      print("과제 제출 실패: $e");
      return null;
    }
  }
}