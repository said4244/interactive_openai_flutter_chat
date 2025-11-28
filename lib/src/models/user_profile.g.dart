// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      userId: json['userId'] as String,
      age: (json['age'] as num).toInt(),
      birthDate: DateTime.parse(json['birthDate'] as String),
      motherCountry: json['motherCountry'] as String,
      motherCulture: json['motherCulture'] as String,
      strongestLanguage: json['strongestLanguage'] as String,
      arabicLevel: $enumDecode(_$ArabicLevelEnumMap, json['arabicLevel']),
      tryingToLearnThis: json['tryingToLearnThis'] as String,
      learnedWords: (json['learnedWords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      grammarCapabilities: GrammarCapabilities.fromJson(
          json['grammarCapabilities'] as Map<String, dynamic>),
      completedRoleplays: (json['completedRoleplays'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      selectedLevel: json['selectedLevel'] as String? ?? "level2",
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'age': instance.age,
      'birthDate': instance.birthDate.toIso8601String(),
      'motherCountry': instance.motherCountry,
      'motherCulture': instance.motherCulture,
      'strongestLanguage': instance.strongestLanguage,
      'arabicLevel': _$ArabicLevelEnumMap[instance.arabicLevel]!,
      'tryingToLearnThis': instance.tryingToLearnThis,
      'learnedWords': instance.learnedWords,
      'grammarCapabilities': instance.grammarCapabilities,
      'completedRoleplays': instance.completedRoleplays,
      'selectedLevel': instance.selectedLevel,
    };

const _$ArabicLevelEnumMap = {
  ArabicLevel.beginner: 'beginner',
  ArabicLevel.intermediate: 'intermediate',
  ArabicLevel.advanced: 'advanced',
};

GrammarCapabilities _$GrammarCapabilitiesFromJson(Map<String, dynamic> json) =>
    GrammarCapabilities(
      knowsNouns: json['knowsNouns'] as bool,
      knowsPronouns: json['knowsPronouns'] as bool,
      knowsVerbs: json['knowsVerbs'] as bool,
      knowsAdjectives: json['knowsAdjectives'] as bool,
      knowsAdverbs: json['knowsAdverbs'] as bool,
      knowsPrepositions: json['knowsPrepositions'] as bool,
      knowsConjunctions: json['knowsConjunctions'] as bool,
      knowsInterjections: json['knowsInterjections'] as bool,
    );

Map<String, dynamic> _$GrammarCapabilitiesToJson(
        GrammarCapabilities instance) =>
    <String, dynamic>{
      'knowsNouns': instance.knowsNouns,
      'knowsPronouns': instance.knowsPronouns,
      'knowsVerbs': instance.knowsVerbs,
      'knowsAdjectives': instance.knowsAdjectives,
      'knowsAdverbs': instance.knowsAdverbs,
      'knowsPrepositions': instance.knowsPrepositions,
      'knowsConjunctions': instance.knowsConjunctions,
      'knowsInterjections': instance.knowsInterjections,
    };
