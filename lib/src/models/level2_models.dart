import 'package:json_annotation/json_annotation.dart';

part 'level2_models.g.dart';

@JsonSerializable()
class Level2ValidationRequest {
  final String userMessage;
  final String aiMessage;
  final Map<String, dynamic> userContext;

  Level2ValidationRequest({
    required this.userMessage,
    required this.aiMessage,
    required this.userContext,
  });

  factory Level2ValidationRequest.fromJson(Map<String, dynamic> json) =>
      _$Level2ValidationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$Level2ValidationRequestToJson(this);
}

@JsonSerializable()
class Level2ValidationResponse {
  final bool isValid;
  final String? feedback;
  final List<String> examples;
  final String? correctedText;
  final Map<String, dynamic>? analysis;

  Level2ValidationResponse({
    required this.isValid,
    this.feedback,
    this.examples = const [],
    this.correctedText,
    this.analysis,
  });

  factory Level2ValidationResponse.fromJson(Map<String, dynamic> json) =>
      _$Level2ValidationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$Level2ValidationResponseToJson(this);
}

@JsonSerializable()
class Level2ConversationRequest {
  final String roleplayContext;
  final List<ConversationTurn> conversationHistory;
  final Map<String, dynamic> userProfile;
  final String lastUserMessage;

  Level2ConversationRequest({
    required this.roleplayContext,
    required this.conversationHistory,
    required this.userProfile,
    required this.lastUserMessage,
  });

  factory Level2ConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$Level2ConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$Level2ConversationRequestToJson(this);
}

@JsonSerializable()
class ConversationTurn {
  final String role;
  final String message;
  final DateTime timestamp;

  ConversationTurn({
    required this.role,
    required this.message,
    required this.timestamp,
  });

  factory ConversationTurn.fromJson(Map<String, dynamic> json) =>
      _$ConversationTurnFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationTurnToJson(this);
}

enum ValidationState {
  notValidated,
  validating,
  valid,
  invalid,
  correctionRequired,
}