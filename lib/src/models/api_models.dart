import 'package:json_annotation/json_annotation.dart';
import 'user_profile.dart';
import 'roleplay.dart';

part 'api_models.g.dart';

// Request Models

@JsonSerializable()
class GenerateRoleplayTitlesRequest {
  final UserProfile userProfile;
  final String selectedLevel;
  final DateTime currentDate;
  final String? specialContext;

  GenerateRoleplayTitlesRequest({
    required this.userProfile,
    required this.selectedLevel,
    required this.currentDate,
    this.specialContext,
  });

  factory GenerateRoleplayTitlesRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateRoleplayTitlesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateRoleplayTitlesRequestToJson(this);

  String toPrompt() {
    final age = userProfile.age;
    final culture = userProfile.motherCulture;
    final country = userProfile.motherCountry;
    final arabicLevel = userProfile.arabicLevel.name;
    final completedRoleplays = userProfile.completedRoleplays.take(10).join(', ');
    final level = userProfile.selectedLevel;

    return '''
Generate 3 Arabic roleplay scenarios for:
- Age: $age, Culture: $culture ($country)
- Arabic Level: $arabicLevel
- Learning Level: $level
- Avoid these completed: $completedRoleplays
- Date: ${currentDate.toIso8601String()}${specialContext != null ? ', Context: $specialContext' : ''}

Create 3 engaging roleplay titles that are:
1. Age-appropriate daily life situations
2. Culturally relevant
3. Different from completed ones
4. Suitable for $level interaction

Return ONLY this JSON structure:
{
  "roleplays": [
    {
      "id": "greeting_1",
      "title": "Morning Greeting at School",
      "description": "Practice greeting your teacher and classmates",
      "scenario": "You arrive at school and meet your teacher",
      "difficulty": "easy",
      "estimatedVocabulary": ["مرحبا", "صباح", "معلم"],
      "culturalContext": "School greetings in Arab culture"
    }
  ]
}''';
  }
}

@JsonSerializable()
class GenerateRoleplayConversationRequest {
  final UserProfile userProfile;
  final RoleplayTitle selectedRoleplay;

  GenerateRoleplayConversationRequest({
    required this.userProfile,
    required this.selectedRoleplay,
  });

  factory GenerateRoleplayConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$GenerateRoleplayConversationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateRoleplayConversationRequestToJson(this);

  String toPrompt() {
    final age = userProfile.age;
    final arabicLevel = userProfile.arabicLevel.name;
    final grammarTypes = userProfile.grammarCapabilities.getKnownGrammarTypes();
    final learnedWords = userProfile.learnedWords.take(30).join(', ');
    final tryingToLearn = userProfile.tryingToLearnThis;
    final level = userProfile.selectedLevel;

    if (level == 'level2') {
      return '''
Generate the FIRST AI message to start this roleplay conversation:
- User: Age $age, Arabic Level: $arabicLevel
- Grammar: ${grammarTypes.join(', ')}
- Known words: $learnedWords
- Trying to learn: $tryingToLearn

Roleplay: "${selectedRoleplay.title}"
Description: ${selectedRoleplay.description}
Scenario: ${selectedRoleplay.scenario}
Difficulty: ${selectedRoleplay.difficulty}

Create ONE opening message from the AI that:
1. Sets up the scenario naturally
2. Is appropriate for the student's level
3. Incorporates the learning goal if possible
4. Invites a response

Return this JSON structure with just ONE message:
{
  "messages": [
    {
      "index": 0,
      "role": "ai",
      "arabicText": "السلام عليكم، كيف حالك اليوم؟",
      "transliteration": "as-salāmu ʿalaykum, kayf ḥāluk al-yawm?",
      "englishTranslation": "Peace be upon you, how are you today?",
      "keyVocabulary": ["السلام", "كيف", "حال"],
      "culturalNote": null
    }
  ]
}''';
    } else {
      // Level 1 - full conversation
      return '''
Generate a complete roleplay conversation for:
- User: Age $age, Arabic Level: $arabicLevel
- Grammar: ${grammarTypes.join(', ')}
- Known words: $learnedWords

Roleplay: "${selectedRoleplay.title}"
Description: ${selectedRoleplay.description}
Scenario: ${selectedRoleplay.scenario}
Difficulty: ${selectedRoleplay.difficulty}

Create exactly 20 messages (10 AI, 10 user) alternating AI-first.
Keep messages appropriate for the level and use known vocabulary when possible.

Return this JSON structure:
{
  "messages": [
    {
      "index": 0,
      "role": "ai",
      "arabicText": "السلام عليكم",
      "transliteration": "as-salāmu ʿalaykum",
      "englishTranslation": "Peace be upon you",
      "keyVocabulary": ["السلام"],
      "culturalNote": null
    },
    {
      "index": 1,
      "role": "user",
      "arabicText": "وعليكم السلام",
      "transliteration": "wa ʿalaykumu s-salām", 
      "englishTranslation": "And peace be upon you",
      "keyVocabulary": ["وعليكم"],
      "culturalNote": null
    }
  ]
}''';
    }
  }
}

// Response Models

@JsonSerializable()
class GenerateRoleplayTitlesResponse {
  final List<RoleplayTitle> roleplays;

  GenerateRoleplayTitlesResponse({
    required this.roleplays,
  });

  factory GenerateRoleplayTitlesResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateRoleplayTitlesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateRoleplayTitlesResponseToJson(this);
}

@JsonSerializable()
class GenerateRoleplayConversationResponse {
  final List<RoleplayMessage> messages;

  GenerateRoleplayConversationResponse({
    required this.messages,
  });

  factory GenerateRoleplayConversationResponse.fromJson(Map<String, dynamic> json) =>
      _$GenerateRoleplayConversationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GenerateRoleplayConversationResponseToJson(this);
}

// OpenAI API Models

@JsonSerializable()
class OpenAIRequest {
  final String model;
  final List<OpenAIMessage> messages;
  final double temperature;
  @JsonKey(name: 'max_tokens')
  final int maxTokens;
  @JsonKey(name: 'response_format')
  final ResponseFormat? responseFormat;

  OpenAIRequest({
    required this.model,
    required this.messages,
    this.temperature = 0.7,
    this.maxTokens = 16000,
    this.responseFormat,
  });

  factory OpenAIRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIRequestToJson(this);
}

@JsonSerializable()
class OpenAIMessage {
  final String role;
  final String content;

  OpenAIMessage({
    required this.role,
    required this.content,
  });

  factory OpenAIMessage.fromJson(Map<String, dynamic> json) =>
      _$OpenAIMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIMessageToJson(this);
}

@JsonSerializable()
class ResponseFormat {
  final String type;

  ResponseFormat({
    required this.type,
  });

  factory ResponseFormat.json() => ResponseFormat(type: 'json_object');

  factory ResponseFormat.fromJson(Map<String, dynamic> json) =>
      _$ResponseFormatFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseFormatToJson(this);
}

@JsonSerializable()
class OpenAIResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenAIChoice> choices;
  final OpenAIUsage? usage;

  OpenAIResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    this.usage,
  });

  factory OpenAIResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIResponseToJson(this);
}

@JsonSerializable()
class OpenAIChoice {
  final int index;
  final OpenAIMessage message;
  @JsonKey(name: 'finish_reason')
  final String? finishReason;

  OpenAIChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory OpenAIChoice.fromJson(Map<String, dynamic> json) =>
      _$OpenAIChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIChoiceToJson(this);
}

@JsonSerializable()
class OpenAIUsage {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  OpenAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenAIUsage.fromJson(Map<String, dynamic> json) =>
      _$OpenAIUsageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIUsageToJson(this);
}