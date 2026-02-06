import 'package:taskfit/data/taskfit_api.dart';

import 'api_models.dart';


class TaskRepository {
  final TaskFitApi api;

  TaskRepository(this.api);

  // 기업 검색
  Future<List<dynamic>> searchCompanies(String query) async {
    try {
      final result = await api.searchCompanies(query, 20);
      return result is List ? result : [];
    } catch (e) {
      print("기업 검색 실패: $e");
      return [];
    }
  }

  // 직무 검색
  Future<List<dynamic>> searchJobRoles(String? category, String query) async {
    try {
      final result = await api.searchJobRoles(category, query);
      return result is List ? result : [];
    } catch (e) {
      print("직무 검색 실패: $e");
      return [];
    }
  }

  // 과제 제출 및 스레드 생성
  // 반환: SubmissionCreateResponse { submission, thread, first_message }
  Future<int?> submitTask(int taskId, String content) async {
    try {
      final response = await api.createSubmission(SubmissionCreateRequest(
        task_id: taskId,
        content: content,
        is_draft: false,
      ));
      // thread?.id에서 스레드 ID 추출
      return response?['thread']?['id'];
    } catch (e) {
      print("과제 제출 실패: $e");
      return null;
    }
  }
}
