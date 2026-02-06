import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'api_models.dart';

part 'taskfit_api.g.dart';

@RestApi(baseUrl: "https://taskfit-api-286917368950.asia-northeast3.run.app")
abstract class TaskFitApi {
  factory TaskFitApi(Dio dio, {String baseUrl}) = _TaskFitApi;

  // --- 인증 ---
  @POST("/auth/google")
  Future<dynamic> loginWithGoogle(@Body() GoogleLoginRequest request);

  @GET("/auth/me")
  Future<dynamic> getMe();

  // --- 기업 ---
  @GET("/companies")
  Future<dynamic> searchCompanies(
      @Query("q") String? query,
      @Query("limit") int limit
      );

  // --- 직무 ---
  @GET("/job-roles/categories")
  Future<dynamic> getJobCategories();

  @GET("/job-roles")
  Future<dynamic> searchJobRoles(
      @Query("category") String? category,
      @Query("q") String? query
      );

  // --- 과제 ---
  @POST("/tasks/generate")
  Future<dynamic> generateTasks(@Body() TaskGenerateRequest request);

  @GET("/tasks")
  Future<dynamic> getTasks({
    @Query("page") required int page,
    @Query("page_size") int? pageSize,
    @Query("company_id") int? companyId,
    @Query("job_role_id") int? jobRoleId,
    @Query("category") String? category,
    @Query("difficulty") String? difficulty,
  });

  @GET("/tasks/{task_id}")
  Future<dynamic> getTaskDetail(@Path("task_id") int taskId);

  // --- 제출 ---
  @POST("/submissions")
  Future<dynamic> createSubmission(@Body() SubmissionCreateRequest request);

  @PUT("/submissions/{submission_id}")
  Future<dynamic> updateSubmission(
      @Path("submission_id") int submissionId,
      @Body() SubmissionUpdateRequest request
      );

  @GET("/submissions/{submission_id}")
  Future<dynamic> getSubmission(@Path("submission_id") int submissionId);

  // --- 질의응답 ---
  @GET("/threads")
  Future<dynamic> getThreads({
    @Query("page") required int page,
    @Query("page_size") int? pageSize,
  });

  @GET("/threads/{thread_id}")
  Future<dynamic> getThreadDetail(@Path("thread_id") int threadId);

  @POST("/threads/{thread_id}/messages")
  Future<dynamic> sendMessage(
      @Path("thread_id") int threadId,
      @Body() MessageCreateRequest request
      );

  // --- 평가 ---
  @GET("/evaluations/{evaluation_id}")
  Future<dynamic> getEvaluationDetail(@Path("evaluation_id") int evaluationId);

  // --- 대시보드 ---
  @GET("/dashboard/summary")
  Future<dynamic> getDashboardSummary();

  // --- 프로필 ---
  @GET("/profile")
  Future<dynamic> getProfile();

  @PATCH("/profile")
  Future<dynamic> updateProfile(@Body() ProfileUpdateRequest request);
}
