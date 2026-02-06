import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'api_models.dart';

part 'taskfit_api.g.dart';

@RestApi(baseUrl: "https://taskfit-api-286917368950.asia-northeast3.run.app")
abstract class TaskFitApi {
  factory TaskFitApi(Dio dio, {String baseUrl}) = _TaskFitApi;

  // 반환 타입을 Map<String, dynamic> 대신 dynamic으로 설정하여
  // 생성기가 .fromJson을 찾지 않도록 합니다.

  @POST("/auth/google")
  Future<dynamic> loginWithGoogle(@Body() GoogleLoginRequest request);

  @GET("/auth/me")
  Future<dynamic> getMe();

  @GET("/companies")
  Future<dynamic> searchCompanies(
      @Query("q") String? query,
      @Query("limit") int limit
      );

  @GET("/job-roles/categories")
  Future<List<String>> getJobCategories();

  @GET("/job-roles")
  Future<dynamic> searchJobRoles(
      @Query("category") String? category,
      @Query("q") String? query
      );

  @POST("/tasks/generate")
  Future<void> generateTasks(@Body() TaskGenerateRequest request);

  @GET("/tasks")
  Future<dynamic> getTasks({
    @Query("page") required int page,
    @Query("company_id") int? companyId
  });

  @GET("/tasks/{task_id}")
  Future<dynamic> getTaskDetail(@Path("task_id") int taskId);

  @POST("/submissions")
  Future<dynamic> createSubmission(@Body() SubmissionCreateRequest request);

  @GET("/submissions/{submission_id}")
  Future<dynamic> getSubmission(@Path("submission_id") int submissionId);

  @GET("/threads")
  Future<dynamic> getThreads({@Query("page") required int page});

  @GET("/threads/{thread_id}")
  Future<dynamic> getThreadDetail(@Path("thread_id") int threadId);

  @POST("/threads/{thread_id}/messages")
  Future<dynamic> sendMessage(
      @Path("thread_id") int threadId,
      @Body() MessageCreateRequest request
      );

  @GET("/evaluations/{evaluation_id}")
  Future<dynamic> getEvaluationDetail(@Path("evaluation_id") int evaluationId);

  @GET("/dashboard/summary")
  Future<dynamic> getDashboardSummary();

  @GET("/profile")
  Future<dynamic> getProfile();

  @PATCH("/profile")
  Future<dynamic> updateProfile(@Body() ProfileUpdateRequest request);
}