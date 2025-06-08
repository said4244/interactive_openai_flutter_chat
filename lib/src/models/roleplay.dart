import 'package:json_annotation/json_annotation.dart';

part 'roleplay.g.dart';

enum MessageRole { ai, user }
enum UserLevel { level1, level2 }

@JsonSerializable()
class RoleplayTitle {
  final String id;
  final String title;
  final String description;
  final String scenario;
  final String difficulty;
  final List<String> estimatedVocabulary;
  final String culturalContext;

  RoleplayTitle({
    required this.id,
    required this.title,
    required this.description,
    required this.scenario,
    required this.difficulty,
    required this.estimatedVocabulary,
    required this.culturalContext,
  });

  factory RoleplayTitle.fromJson(Map<String, dynamic> json) =>
      _$RoleplayTitleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleplayTitleToJson(this);
}

@JsonSerializable()
class RoleplayOption {
  final String id;
  final String title;
  final String description;
  final String scenario;
  final String difficulty;
  final List<String> targetVocabulary;
  final String culturalContext;
  final List<RoleplayMessage> messages;

  RoleplayOption({
    required this.id,
    required this.title,
    required this.description,
    required this.scenario,
    required this.difficulty,
    required this.targetVocabulary,
    required this.culturalContext,
    required this.messages,
  });

  factory RoleplayOption.fromJson(Map<String, dynamic> json) =>
      _$RoleplayOptionFromJson(json);

  Map<String, dynamic> toJson() => _$RoleplayOptionToJson(this);

  // For level 2, we only need the initial message
  RoleplayMessage get initialMessage => messages.isNotEmpty 
      ? messages.first 
      : throw Exception('No initial message available');
}

@JsonSerializable()
class RoleplayMessage {
  final int index;
  final MessageRole role;
  final String arabicText;
  final String transliteration;
  final String englishTranslation;
  final List<String> keyVocabulary;
  final String? culturalNote;

  RoleplayMessage({
    required this.index,
    required this.role,
    required this.arabicText,
    required this.transliteration,
    required this.englishTranslation,
    required this.keyVocabulary,
    this.culturalNote,
  });

  factory RoleplayMessage.fromJson(Map<String, dynamic> json) =>
      _$RoleplayMessageFromJson(json);

  Map<String, dynamic> toJson() => _$RoleplayMessageToJson(this);
}