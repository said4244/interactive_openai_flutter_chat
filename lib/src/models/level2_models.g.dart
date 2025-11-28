// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level2_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Level2ValidationRequest _$Level2ValidationRequestFromJson(
        Map<String, dynamic> json) =>
    Level2ValidationRequest(
      userMessage: json['userMessage'] as String,
      aiMessage: json['aiMessage'] as String,
      userContext: json['userContext'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$Level2ValidationRequestToJson(
        Level2ValidationRequest instance) =>
    <String, dynamic>{
      'userMessage': instance.userMessage,
      'aiMessage': instance.aiMessage,
      'userContext': instance.userContext,
    };

Level2ValidationResponse _$Level2ValidationResponseFromJson(
        Map<String, dynamic> json) =>
    Level2ValidationResponse(
      isValid: json['isValid'] as bool,
      feedback: json['feedback'] as String?,
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      correctedText: json['correctedText'] as String?,
      analysis: json['analysis'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$Level2ValidationResponseToJson(
        Level2ValidationResponse instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'feedback': instance.feedback,
      'examples': instance.examples,
      'correctedText': instance.correctedText,
      'analysis': instance.analysis,
    };

Level2ConversationRequest _$Level2ConversationRequestFromJson(
        Map<String, dynamic> json) =>
    Level2ConversationRequest(
      roleplayContext: json['roleplayContext'] as String,
      conversationHistory: (json['conversationHistory'] as List<dynamic>)
          .map((e) => ConversationTurn.fromJson(e as Map<String, dynamic>))
          .toList(),
      userProfile: json['userProfile'] as Map<String, dynamic>,
      lastUserMessage: json['lastUserMessage'] as String,
    );

Map<String, dynamic> _$Level2ConversationRequestToJson(
        Level2ConversationRequest instance) =>
    <String, dynamic>{
      'roleplayContext': instance.roleplayContext,
      'conversationHistory': instance.conversationHistory,
      'userProfile': instance.userProfile,
      'lastUserMessage': instance.lastUserMessage,
    };

ConversationTurn _$ConversationTurnFromJson(Map<String, dynamic> json) =>
    ConversationTurn(
      role: json['role'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ConversationTurnToJson(ConversationTurn instance) =>
    <String, dynamic>{
      'role': instance.role,
      'message': instance.message,
      'timestamp': instance.timestamp.toIso8601String(),
    };
