import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_profile.dart';
import '../models/roleplay.dart';
import '../models/api_models.dart';
import '../utils/constants.dart';

class OpenAIService {
  final Logger _logger = Logger();
  final http.Client _httpClient;

  OpenAIService({http.Client? httpClient}) 
      : _httpClient = httpClient ?? http.Client();

  // Generate roleplay titles (3 options)
  Future<List<RoleplayTitle>> generateRoleplayTitles({
    required UserProfile userProfile,
    required String selectedLevel,
    String? specialContext,
  }) async {
    try {
      _logger.i('Generating roleplay titles for level: $selectedLevel');
      
      final request = GenerateRoleplayTitlesRequest(
        userProfile: userProfile,
        selectedLevel: selectedLevel,
        currentDate: DateTime.now(),
        specialContext: specialContext,
      );

      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found. Please add OPENAI_API_KEY to your .env file');
      }

      final openAIRequest = OpenAIRequest(
        model: Constants.openAIModel,
        messages: [
          OpenAIMessage(
            role: 'system',
            content: '''You are an expert Arabic language tutor creating engaging roleplay scenarios. 
Always respond with valid JSON containing exactly 3 roleplay titles.''',
          ),
          OpenAIMessage(
            role: 'user',
            content: request.toPrompt(),
          ),
        ],
        temperature: 0.8,
        maxTokens: 2000,
        responseFormat: ResponseFormat.json(),
      );

      final response = await _makeApiCall(openAIRequest, apiKey);
      
      if (response.choices.isEmpty) {
        throw Exception('No response from OpenAI');
      }

      final content = response.choices.first.message.content;
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      
      _logger.d('Received ${jsonData['roleplays']?.length ?? 0} roleplay titles');
      
      final titlesResponse = GenerateRoleplayTitlesResponse.fromJson(jsonData);
      
      return titlesResponse.roleplays;
    } catch (e, stackTrace) {
      _logger.e('Failed to generate roleplay titles', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Generate conversation for selected roleplay
  Future<RoleplayOption> generateRoleplayConversation({
    required UserProfile userProfile,
    required RoleplayTitle selectedRoleplay,
  }) async {
    try {
      _logger.i('Generating conversation for roleplay: ${selectedRoleplay.title}');
      
      final request = GenerateRoleplayConversationRequest(
        userProfile: userProfile,
        selectedRoleplay: selectedRoleplay,
      );

      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final openAIRequest = OpenAIRequest(
        model: Constants.openAIModel,
        messages: [
          OpenAIMessage(
            role: 'system',
            content: '''You are an expert Arabic language tutor creating a conversation for language practice. 
For level 2, only generate the FIRST AI message to start the conversation. 
Keep it simple and appropriate for the student's level. Respond with valid JSON only.''',
          ),
          OpenAIMessage(
            role: 'user',
            content: request.toPrompt(),
          ),
        ],
        temperature: 0.7,
        maxTokens: 1000,
        responseFormat: ResponseFormat.json(),
      );

      final response = await _makeApiCall(openAIRequest, apiKey);
      
      if (response.choices.isEmpty) {
        throw Exception('No response from OpenAI');
      }

      final content = response.choices.first.message.content;
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      
      final conversationResponse = GenerateRoleplayConversationResponse.fromJson(jsonData);
      
      // Create RoleplayOption with messages
      return RoleplayOption(
        id: selectedRoleplay.id,
        title: selectedRoleplay.title,
        description: selectedRoleplay.description,
        scenario: selectedRoleplay.scenario,
        difficulty: selectedRoleplay.difficulty,
        targetVocabulary: selectedRoleplay.estimatedVocabulary,
        culturalContext: selectedRoleplay.culturalContext,
        messages: conversationResponse.messages,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to generate roleplay conversation', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<OpenAIResponse> _makeApiCall(OpenAIRequest request, String apiKey) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(Constants.openAIApiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200) {
        _logger.e('API call failed: ${response.statusCode} - ${response.body}');
        throw Exception('API call failed: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      return OpenAIResponse.fromJson(jsonResponse);
    } catch (e) {
      _logger.e('Error making API call', error: e);
      rethrow;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}