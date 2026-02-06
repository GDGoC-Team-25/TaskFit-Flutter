// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleLoginRequest _$GoogleLoginRequestFromJson(Map<String, dynamic> json) =>
    GoogleLoginRequest(id_token: json['id_token'] as String);

Map<String, dynamic> _$GoogleLoginRequestToJson(GoogleLoginRequest instance) =>
    <String, dynamic>{'id_token': instance.id_token};

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  logo_url: json['logo_url'] as String?,
);

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logo_url': instance.logo_url,
};

JobRole _$JobRoleFromJson(Map<String, dynamic> json) => JobRole(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$JobRoleToJson(JobRole instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
};

TaskGenerateRequest _$TaskGenerateRequestFromJson(Map<String, dynamic> json) =>
    TaskGenerateRequest(
      company_id: (json['company_id'] as num).toInt(),
      job_role_id: (json['job_role_id'] as num).toInt(),
      count: (json['count'] as num?)?.toInt() ?? 5,
    );

Map<String, dynamic> _$TaskGenerateRequestToJson(
  TaskGenerateRequest instance,
) => <String, dynamic>{
  'company_id': instance.company_id,
  'job_role_id': instance.job_role_id,
  'count': instance.count,
};

SubmissionCreateRequest _$SubmissionCreateRequestFromJson(
  Map<String, dynamic> json,
) => SubmissionCreateRequest(
  task_id: (json['task_id'] as num).toInt(),
  content: json['content'] as String,
  is_draft: json['is_draft'] as bool? ?? false,
  time_spent_seconds: (json['time_spent_seconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$SubmissionCreateRequestToJson(
  SubmissionCreateRequest instance,
) => <String, dynamic>{
  'task_id': instance.task_id,
  'content': instance.content,
  'is_draft': instance.is_draft,
  'time_spent_seconds': instance.time_spent_seconds,
};

SubmissionUpdateRequest _$SubmissionUpdateRequestFromJson(
  Map<String, dynamic> json,
) => SubmissionUpdateRequest(
  content: json['content'] as String,
  is_draft: json['is_draft'] as bool? ?? false,
  time_spent_seconds: (json['time_spent_seconds'] as num?)?.toInt(),
);

Map<String, dynamic> _$SubmissionUpdateRequestToJson(
  SubmissionUpdateRequest instance,
) => <String, dynamic>{
  'content': instance.content,
  'is_draft': instance.is_draft,
  'time_spent_seconds': instance.time_spent_seconds,
};

MessageCreateRequest _$MessageCreateRequestFromJson(
  Map<String, dynamic> json,
) => MessageCreateRequest(content: json['content'] as String);

Map<String, dynamic> _$MessageCreateRequestToJson(
  MessageCreateRequest instance,
) => <String, dynamic>{'content': instance.content};

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ProfileUpdateRequest(
  name: json['name'] as String?,
  bio: json['bio'] as String?,
);

Map<String, dynamic> _$ProfileUpdateRequestToJson(
  ProfileUpdateRequest instance,
) => <String, dynamic>{'name': instance.name, 'bio': instance.bio};
