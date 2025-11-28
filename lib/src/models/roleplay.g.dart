// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roleplay.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleplayTitle _$RoleplayTitleFromJson(Map<String, dynamic> json) =>
    RoleplayTitle(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scenario: json['scenario'] as String,
      difficulty: json['difficulty'] as String,
      estimatedVocabulary: (json['estimatedVocabulary'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      culturalContext: json['culturalContext'] as String,
    );

Map<String, dynamic> _$RoleplayTitleToJson(RoleplayTitle instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'scenario': instance.scenario,
      'difficulty': instance.difficulty,
      'estimatedVocabulary': instance.estimatedVocabulary,
      'culturalContext': instance.culturalContext,
    };

RoleplayOption _$RoleplayOptionFromJson(Map<String, dynamic> json) =>
    RoleplayOption(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      scenario: json['scenario'] as String,
      difficulty: json['difficulty'] as String,
      targetVocabulary: (json['targetVocabulary'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      culturalContext: json['culturalContext'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) => RoleplayMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RoleplayOptionToJson(RoleplayOption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'scenario': instance.scenario,
      'difficulty': instance.difficulty,
      'targetVocabulary': instance.targetVocabulary,
      'culturalContext': instance.culturalContext,
      'messages': instance.messages,
    };

RoleplayMessage _$RoleplayMessageFromJson(Map<String, dynamic> json) =>
    RoleplayMessage(
      index: (json['index'] as num).toInt(),
      role: $enumDecode(_$MessageRoleEnumMap, json['role']),
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String,
      englishTranslation: json['englishTranslation'] as String,
      keyVocabulary: (json['keyVocabulary'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      culturalNote: json['culturalNote'] as String?,
    );

Map<String, dynamic> _$RoleplayMessageToJson(RoleplayMessage instance) =>
    <String, dynamic>{
      'index': instance.index,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'arabicText': instance.arabicText,
      'transliteration': instance.transliteration,
      'englishTranslation': instance.englishTranslation,
      'keyVocabulary': instance.keyVocabulary,
      'culturalNote': instance.culturalNote,
    };

const _$MessageRoleEnumMap = {
  MessageRole.ai: 'ai',
  MessageRole.user: 'user',
};
