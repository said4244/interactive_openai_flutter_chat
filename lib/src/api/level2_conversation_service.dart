import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/level2_models.dart';
import '../models/api_models.dart';
import '../utils/constants.dart';

class Level2ConversationService {
  final Logger _logger = Logger();
  final http.Client _httpClient;

  Level2ConversationService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  // Determine validation rules based on user's learning level
  Map<String, bool> getValidationRules(Map<String, dynamic> userContext) {
    final arabicLevel = userContext['arabicLevel'] ?? 'beginner';
    final grammarCapabilities = userContext['grammarCapabilities'] ?? {};
    final tryingToLearn = userContext['tryingToLearn'] ?? '';
    
    // Base rules for all levels
    final rules = {
      'checkSpelling': true,
      'checkHamza': false,  // أ إ آ ء ؤ ئ
      'checkTaaMarbouta': false,  // ة vs ه
      'checkAlefMaqsura': true,  // ى vs ي
      'checkTanween': false,  // ً ٌ ٍ
      'checkDiacritics': false,  // َ ُ ِ
      'checkShadda': false,  // ّ
      'checkSukoon': false,  // ْ
      'checkMadda': true,  // آ
      'checkLamAlef': true,  // لا
      'checkSentenceStructure': true,
      'checkGrammar': true,
      'checkGenderAgreement': false,
      'checkDualPlural': false,
      'checkVerbConjugation': false,
      'checkPronounAgreement': false,
    };

    // Adjust based on level
    if (arabicLevel == 'intermediate' || arabicLevel == 'advanced') {
      rules['checkGenderAgreement'] = true;
      rules['checkVerbConjugation'] = grammarCapabilities['knowsVerbs'] ?? false;
    }

    if (arabicLevel == 'advanced') {
      rules['checkDualPlural'] = true;
      rules['checkShadda'] = true;
      rules['checkSukoon'] = true;
    }

    // Check if user is specifically learning tanween
    //if (tryingToLearn.toLowerCase().contains('tanwin') || 
    //    tryingToLearn.toLowerCase().contains('تنوين')) {
    //  rules['checkTanween'] = true;
    //  rules['checkDiacritics'] = true;  // Need to check diacritics if learning tanween
    //}

    return rules;
  }

  Future<Level2ValidationResponse> validateUserResponse({
    required String userMessage,
    required String aiMessage,
    required Map<String, dynamic> userContext,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      // Get validation rules based on user's current level
      final validationRules = getValidationRules(userContext);
      
      _logger.i('Validation rules for user: $validationRules');

      final prompt = '''
You are an Arabic language tutor helping a ${userContext['age']} year old student learn proper Arabic.
The student's profile: ${jsonEncode(userContext)}

AI's message: "$aiMessage"
Student's response: "$userMessage"

VALIDATION RULES FOR THIS STUDENT:
${jsonEncode(validationRules)}

IMPORTANT INSTRUCTIONS:
1. ONLY check for errors in features marked as 'true' in the validation rules
2. IGNORE errors in features marked as 'false' - the student hasn't learned these yet
3. Be encouraging and focus on what the student knows

For example:
- If checkTanween is false, ignore missing tanween marks (ً ٌ ٍ)
- If checkDiacritics is false, ignore missing vowel marks (َ ُ ِ)
- If checkGenderAgreement is false, don't mark مذكر/مؤنث errors

Mark as INVALID only if there are errors in the ENABLED checks:
${validationRules.entries.where((e) => e.value).map((e) => '- ${e.key}').join('\n')}

Mark as VALID if:
1. No errors in the enabled validation rules
2. Natural conversation that fits the roleplay context
3. Age and culturally appropriate

IGNORE these (student hasn't learned yet):
${validationRules.entries.where((e) => !e.value).map((e) => '- ${e.key}').join('\n')}

When providing examples for invalid responses:
- First: The user's message with ONLY the checked features corrected
- Second & third: Related variations using vocabulary the student knows

Examples based on current rules:
- If checkTanween=false and user writes "شكرا": VALID (ignore missing tanween)
- If checkTanween=false and user writes "شكرا جدا": VALID (ignore both missing tanweens)
- If checkTanween=true and user writes "شكرا": INVALID (provide "شكراً")
- If checkHamza=true and user writes "اريد": INVALID (provide "أريد")
- If checkDiacritics=false and user writes "كتب": VALID (ignore missing diacritics)
- If checkGenderAgreement=false and user writes "البنت جميل": VALID (ignore gender mismatch)

Remember: The goal is progressive learning. Don't overwhelm beginners with advanced rules!

If invalid, provide:
- Clear, encouraging feedback about the specific error
- 3 example responses that:
  a) Fix the user's intended message with correct spelling/grammar
  b) Are relevant to what the user was trying to say
  c) Show variations of the corrected response

For example, if user wrote "اريد كولا" (missing hamza), provide:
- "أريد كولا" (what they meant to say, corrected)
- "أريد عصيراً" (alternative beverage option)
- "أريد ماءً" (another beverage option)

Respond in JSON format:
{
  "isValid": boolean,
  "feedback": "specific error explanation based on ENABLED checks only",
  "examples": [
    "corrected version fixing ONLY checked features",
    "related alternative that fits the context", 
    "another related alternative"
  ] (only if invalid, must be relevant to user's intent),
  "correctedText": "user's message with ONLY enabled features corrected",
  "analysis": {
    "spelling": "correct/has_errors",
    "grammar": "correct/has_errors", 
    "sentenceStructure": "correct/has_errors",
    "contextRelevance": "fits_perfectly/acceptable/off_topic",
    "ageAppropriateness": "yes/no",
    "culturalAppropriateness": "yes/no",
    "uncheckedErrors": ["list of errors found in disabled validation rules - for teacher reference only"]
  }
}
''';

      final request = OpenAIRequest(
        model: Constants.level2Model,
        messages: [
          OpenAIMessage(
            role: 'system',
            content: '''You are an Arabic language tutor implementing a progressive learning system.
CRITICAL: Only check for errors in features that are marked as 'true' in the validation rules.
Ignore ALL errors in features marked as 'false' - the student hasn't learned these yet.
This allows students to focus on mastering current concepts before moving to advanced ones.
Be encouraging and celebrate what they know rather than pointing out what they haven't learned.
When providing corrections, fix ONLY the features being checked, leave unchecked features as written.
Balance strictness on enabled features with flexibility on conversational flow.''',
          ),
          OpenAIMessage(
            role: 'user',
            content: prompt,
          ),
        ],
        temperature: 0.3,
        maxTokens: 500,
        responseFormat: ResponseFormat.json(),
      );

      final response = await _makeApiCall(request, apiKey);
      final content = response.choices.first.message.content;
      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      return Level2ValidationResponse.fromJson(jsonData);
    } catch (e, stackTrace) {
      _logger.e('Failed to validate user response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<String> generateAIResponse({
    required String roleplayContext,
    required List<ConversationTurn> conversationHistory,
    required Map<String, dynamic> userProfile,
    required String lastUserMessage,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      // Build conversation history for context
      final historyText = conversationHistory.map((turn) => 
        '${turn.role}: ${turn.message}'
      ).join('\n');

      final prompt = '''
You are in this roleplay scenario: $roleplayContext
Student profile: ${jsonEncode(userProfile)}

IMPORTANT: Based on the student's level:
- Beginner: Use very simple vocabulary, no complex grammar, minimal diacritics
- Intermediate: Can use more vocabulary, basic verb conjugations, some diacritics
- Advanced: Full range of vocabulary, all grammar structures, proper diacritics

Conversation so far:
$historyText
User: $lastUserMessage

Guidelines for your response:
1. Continue the conversation naturally based on what the student said
2. If they shifted topics but it fits the scenario, go with their flow
3. Keep responses short and age-appropriate (1-2 sentences)
4. Match complexity to their level - don't use grammar they haven't learned
5. Be encouraging and friendly
6. If they changed topics appropriately (like toys in a market), engage with that

Examples:
- For beginner: "نعم! عندي ألعاب جميلة" (simple, no diacritics)
- For intermediate: "أكيد! عندي ألعابٌ كثيرة" (tanween on ألعاب)
- For advanced: "بالتأكيد! لديّ ألعابٌ متنوّعةٌ للأطفال" (full diacritics, complex)

Respond with just the Arabic text, no translation.
''';

      final request = OpenAIRequest(
        model: Constants.level2Model,
        messages: [
          OpenAIMessage(
            role: 'system',
            content: '''You are a friendly Arabic tutor in a roleplay conversation with a child.
Be encouraging and natural while maintaining correct Arabic.
Follow the child's conversational lead when it makes sense in the context.
Your role is to help them practice Arabic through engaging, natural dialogue.''',
          ),
          OpenAIMessage(
            role: 'user',
            content: prompt,
          ),
        ],
        temperature: 0.7, // Moderate temperature for balanced responses
        maxTokens: 150,
      );

      final response = await _makeApiCall(request, apiKey);
      return response.choices.first.message.content.trim();
    } catch (e, stackTrace) {
      _logger.e('Failed to generate AI response', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OpenAIResponse> _makeApiCall(OpenAIRequest request, String apiKey) async {
    final response = await _httpClient.post(
      Uri.parse(Constants.openAIApiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('API call failed: ${response.statusCode} - ${response.body}');
    }

    return OpenAIResponse.fromJson(jsonDecode(response.body));
  }

  void dispose() {
    _httpClient.close();
  }
}