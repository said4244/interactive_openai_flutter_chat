import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

enum ArabicLevel { beginner, intermediate, advanced }

@JsonSerializable()
class UserProfile {
  final String userId;
  final int age;
  final DateTime birthDate;
  final String motherCountry;
  final String motherCulture;
  final String strongestLanguage;
  final ArabicLevel arabicLevel;
  final String tryingToLearnThis;
  final List<String> learnedWords;
  final GrammarCapabilities grammarCapabilities;
  final List<String> completedRoleplays;
  final String selectedLevel; // "level1" or "level2"

  UserProfile({
    required this.userId,
    required this.age,
    required this.birthDate,
    required this.motherCountry,
    required this.motherCulture,
    required this.strongestLanguage,
    required this.arabicLevel,
    required this.tryingToLearnThis,
    required this.learnedWords,
    required this.grammarCapabilities,
    required this.completedRoleplays,
    this.selectedLevel = "level2",
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  bool canHandleBigSentences() {
    return arabicLevel == ArabicLevel.advanced || 
           (arabicLevel == ArabicLevel.intermediate && 
            grammarCapabilities.knowsVerbs && 
            grammarCapabilities.knowsAdjectives);
  }
}

@JsonSerializable()
class GrammarCapabilities {
  final bool knowsNouns;
  final bool knowsPronouns;
  final bool knowsVerbs;
  final bool knowsAdjectives;
  final bool knowsAdverbs;
  final bool knowsPrepositions;
  final bool knowsConjunctions;
  final bool knowsInterjections;

  GrammarCapabilities({
    required this.knowsNouns,
    required this.knowsPronouns,
    required this.knowsVerbs,
    required this.knowsAdjectives,
    required this.knowsAdverbs,
    required this.knowsPrepositions,
    required this.knowsConjunctions,
    required this.knowsInterjections,
  });

  factory GrammarCapabilities.fromJson(Map<String, dynamic> json) =>
      _$GrammarCapabilitiesFromJson(json);

  Map<String, dynamic> toJson() => _$GrammarCapabilitiesToJson(this);

  List<String> getKnownGrammarTypes() {
    final types = <String>[];
    if (knowsNouns) types.add('nouns');
    if (knowsPronouns) types.add('pronouns');
    if (knowsVerbs) types.add('verbs');
    if (knowsAdjectives) types.add('adjectives');
    if (knowsAdverbs) types.add('adverbs');
    if (knowsPrepositions) types.add('prepositions');
    if (knowsConjunctions) types.add('conjunctions');
    if (knowsInterjections) types.add('interjections');
    return types;
  }
}