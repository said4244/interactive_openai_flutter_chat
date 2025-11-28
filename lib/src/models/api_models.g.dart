// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenerateRoleplayTitlesRequest _$GenerateRoleplayTitlesRequestFromJson(
        Map<String, dynamic> json) =>
    GenerateRoleplayTitlesRequest(
      userProfile:
          UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>),
      selectedLevel: json['selectedLevel'] as String,
      currentDate: DateTime.parse(json['currentDate'] as String),
      specialContext: json['specialContext'] as String?,
    );

Map<String, dynamic> _$GenerateRoleplayTitlesRequestToJson(
        GenerateRoleplayTitlesRequest instance) =>
    <String, dynamic>{
      'userProfile': instance.userProfile,
      'selectedLevel': instance.selectedLevel,
      'currentDate': instance.currentDate.toIso8601String(),
      'specialContext': instance.specialContext,
    };

GenerateRoleplayConversationRequest
    _$GenerateRoleplayConversationRequestFromJson(Map<String, dynamic> json) =>
        GenerateRoleplayConversationRequest(
          userProfile:
              UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>),
          selectedRoleplay: RoleplayTitle.fromJson(
              json['selectedRoleplay'] as Map<String, dynamic>),
        );

Map<String, dynamic> _$GenerateRoleplayConversationRequestToJson(
        GenerateRoleplayConversationRequest instance) =>
    <String, dynamic>{
      'userProfile': instance.userProfile,
      'selectedRoleplay': instance.selectedRoleplay,
    };

GenerateRoleplayTitlesResponse _$GenerateRoleplayTitlesResponseFromJson(
        Map<String, dynamic> json) =>
    GenerateRoleplayTitlesResponse(
      roleplays: (json['roleplays'] as List<dynamic>)
          .map((e) => RoleplayTitle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GenerateRoleplayTitlesResponseToJson(
        GenerateRoleplayTitlesResponse instance) =>
    <String, dynamic>{
      'roleplays': instance.roleplays,
    };

GenerateRoleplayConversationResponse
    _$GenerateRoleplayConversationResponseFromJson(Map<String, dynamic> json) =>
        GenerateRoleplayConversationResponse(
          messages: (json['messages'] as List<dynamic>)
              .map((e) => RoleplayMessage.fromJson(e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$GenerateRoleplayConversationResponseToJson(
        GenerateRoleplayConversationResponse instance) =>
    <String, dynamic>{
      'messages': instance.messages,
    };

OpenAIRequest _$OpenAIRequestFromJson(Map<String, dynamic> json) =>
    OpenAIRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => OpenAIMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: (json['max_tokens'] as num?)?.toInt() ?? 16000,
      responseFormat: json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
              json['response_format'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIRequestToJson(OpenAIRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages,
      'temperature': instance.temperature,
      'max_tokens': instance.maxTokens,
      'response_format': instance.responseFormat,
    };

OpenAIMessage _$OpenAIMessageFromJson(Map<String, dynamic> json) =>
    OpenAIMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$OpenAIMessageToJson(OpenAIMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
    };

ResponseFormat _$ResponseFormatFromJson(Map<String, dynamic> json) =>
    ResponseFormat(
      type: json['type'] as String,
    );

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
    };

OpenAIResponse _$OpenAIResponseFromJson(Map<String, dynamic> json) =>
    OpenAIResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => OpenAIChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: json['usage'] == null
          ? null
          : OpenAIUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIResponseToJson(OpenAIResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.usage,
    };

OpenAIChoice _$OpenAIChoiceFromJson(Map<String, dynamic> json) => OpenAIChoice(
      index: (json['index'] as num).toInt(),
      message: OpenAIMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String?,
    );

Map<String, dynamic> _$OpenAIChoiceToJson(OpenAIChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message,
      'finish_reason': instance.finishReason,
    };

OpenAIUsage _$OpenAIUsageFromJson(Map<String, dynamic> json) => OpenAIUsage(
      promptTokens: (json['prompt_tokens'] as num).toInt(),
      completionTokens: (json['completion_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$OpenAIUsageToJson(OpenAIUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'completion_tokens': instance.completionTokens,
      'total_tokens': instance.totalTokens,
    };
