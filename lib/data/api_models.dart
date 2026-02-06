import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

// --- 인증 관련 ---
@JsonSerializable()
class GoogleLoginRequest {
  final String id_token;
  GoogleLoginRequest({required this.id_token});
  factory GoogleLoginRequest.fromJson(Map<String, dynamic> json) => _$GoogleLoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GoogleLoginRequestToJson(this);
}

// --- 기업 및 직무 관련 ---
@JsonSerializable()
class Company {
  final int id;
  final String name;
  final String? logo_url;
  Company({required this.id, required this.name, this.logo_url});
  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
}

@JsonSerializable()
class JobRole {
  final int id;
  final String name;
  final String category;
  JobRole({required this.id, required this.name, required this.category});
  factory JobRole.fromJson(Map<String, dynamic> json) => _$JobRoleFromJson(json);
}

// --- 과제 생성 및 조회 ---
@JsonSerializable()
class TaskGenerateRequest {
  final int company_id;
  final int job_role_id;
  final int count;
  TaskGenerateRequest({required this.company_id, required this.job_role_id, this.count = 5});
  Map<String, dynamic> toJson() => _$TaskGenerateRequestToJson(this);
}

// --- 제출 관련 ---
@JsonSerializable()
class SubmissionCreateRequest {
  final int task_id;
  final String content;
  final bool is_draft;
  final int? time_spent_seconds;
  SubmissionCreateRequest({required this.task_id, required this.content, this.is_draft = false, this.time_spent_seconds});
  Map<String, dynamic> toJson() => _$SubmissionCreateRequestToJson(this);
}

@JsonSerializable()
class SubmissionUpdateRequest {
  final String content;
  final bool is_draft;
  final int? time_spent_seconds;
  SubmissionUpdateRequest({required this.content, this.is_draft = false, this.time_spent_seconds});
  Map<String, dynamic> toJson() => _$SubmissionUpdateRequestToJson(this);
}

// --- 질의응답(채팅) 관련 ---
@JsonSerializable()
class MessageCreateRequest {
  final String content;
  MessageCreateRequest({required this.content});
  Map<String, dynamic> toJson() => _$MessageCreateRequestToJson(this);
}

// --- 프로필 관련 ---
@JsonSerializable()
class ProfileUpdateRequest {
  final String? name;
  final String? bio;
  ProfileUpdateRequest({this.name, this.bio});
  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);
}
