import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/roleplay.dart';
import '../models/user_profile.dart';
import '../models/level2_models.dart';
import '../api/openai_service.dart';
import '../api/level2_conversation_service.dart';
import 'input_validator.dart';

class Level2ChatController extends ChangeNotifier {
  final OpenAIService _openAIService;
  final Level2ConversationService _level2Service;
  final UserProfile userProfile;
  final Logger _logger = Logger();
  final _uuid = const Uuid();

  // State
  List<RoleplayTitle> _roleplayTitles = [];
  RoleplayOption? _selectedRoleplay;
  List<ChatMessage> _messages = [];
  List<ConversationTurn> _conversationHistory = [];
  bool _isLoadingTitles = false;
  bool _isLoadingResponse = false;
  bool _isValidating = false;
  String? _error;
  
  // Level 2 specific state
  ValidationState _currentValidationState = ValidationState.notValidated;
  Level2ValidationResponse? _lastValidation;
  int _failedAttempts = 0;
  String? _forcedTypingText;
  InputState? _forcedInputState;
  
  // TODO: In the future, validation rules can be:
  // 1. Loaded from user's learning progress
  // 2. Configured by teachers
  // 3. Adjusted dynamically based on performance
  // 4. Stored in user profile or separate progress tracking
  
  // Controllers
  final InputValidator _inputValidator = InputValidator();

  Level2ChatController({
    required OpenAIService openAIService,
    required Level2ConversationService level2Service,
    required this.userProfile,
  }) : _openAIService = openAIService,
       _level2Service = level2Service;

  // Getters
  List<RoleplayTitle> get roleplayTitles => _roleplayTitles;
  RoleplayOption? get selectedRoleplay => _selectedRoleplay;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoadingTitles || _isLoadingResponse || _isValidating;
  String? get error => _error;
  ValidationState get validationState => _currentValidationState;
  Level2ValidationResponse? get lastValidation => _lastValidation;
  bool get isInForcedTypingMode => _forcedTypingText != null;
  String? get forcedTypingText => _forcedTypingText;
  InputState? get forcedInputState => _forcedInputState;
  
  // Get current validation rules for UI display
  Map<String, bool> get currentValidationRules {
    return _level2Service.getValidationRules({
      'arabicLevel': userProfile.arabicLevel.name,
      'grammarCapabilities': userProfile.grammarCapabilities.toJson(),
      'tryingToLearn': userProfile.tryingToLearnThis,
    });
  }

  // Load roleplay options
  Future<void> loadRoleplayTitles() async {
    try {
      _isLoadingTitles = true;
      _error = null;
      notifyListeners();

      _roleplayTitles = await _openAIService.generateRoleplayTitles(
        userProfile: userProfile,
        selectedLevel: 'level2',
      );

      notifyListeners();
    } catch (e) {
      _logger.e('Failed to load roleplay titles', error: e);
      _error = 'Failed to load roleplays: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoadingTitles = false;
      notifyListeners();
    }
  }

  // Select and start a roleplay
  Future<void> selectRoleplay(RoleplayTitle title) async {
    try {
      _isLoadingResponse = true;
      _error = null;
      notifyListeners();

      // For level 2, we only need to generate the initial AI message
      final roleplayOption = await _openAIService.generateRoleplayConversation(
        userProfile: userProfile,
        selectedRoleplay: title,
      );

      _selectedRoleplay = roleplayOption;
      _messages.clear();
      _conversationHistory.clear();
      _failedAttempts = 0;

      // Add the first AI message
      final firstMessage = roleplayOption.initialMessage;
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: firstMessage.arabicText,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        metadata: {
          'transliteration': firstMessage.transliteration,
          'translation': firstMessage.englishTranslation,
          'vocabulary': firstMessage.keyVocabulary,
        },
      );

      _messages.add(aiMessage);
      _conversationHistory.add(ConversationTurn(
        role: 'ai',
        message: firstMessage.arabicText,
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _logger.e('Failed to start roleplay', error: e);
      _error = 'Failed to start roleplay: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoadingResponse = false;
      notifyListeners();
    }
  }

  // Send user message
  Future<void> sendUserMessage(String message) async {
    if (message.trim().isEmpty || _selectedRoleplay == null) return;

    try {
      // Add user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: message,
        type: MessageType.user,
        timestamp: DateTime.now(),
        validationState: ValidationState.validating,
      );
      _messages.add(userMessage);
      _currentValidationState = ValidationState.validating;
      _isValidating = true;
      notifyListeners();

      // Get the last AI message for context
      final lastAiMessage = _messages
          .where((m) => m.type == MessageType.ai)
          .lastOrNull;

      if (lastAiMessage == null) {
        throw Exception('No AI message found for validation');
      }

      // Validate the response
      final validation = await _level2Service.validateUserResponse(
        userMessage: message,
        aiMessage: lastAiMessage.content,
        userContext: {
          'age': userProfile.age,
          'arabicLevel': userProfile.arabicLevel.name,
          'learnedWords': userProfile.learnedWords,
          'tryingToLearn': userProfile.tryingToLearnThis,
          'grammarCapabilities': userProfile.grammarCapabilities.toJson(),
        },
      );

      _lastValidation = validation;
      _isValidating = false;

      if (validation.isValid) {
        // Valid response - continue conversation
        _failedAttempts = 0;
        _currentValidationState = ValidationState.valid;
        
        // Update user message validation state
        final index = _messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: userMessage.id,
            content: userMessage.content,
            type: userMessage.type,
            timestamp: userMessage.timestamp,
            validationState: ValidationState.valid,
          );
        }

        _conversationHistory.add(ConversationTurn(
          role: 'user',
          message: message,
          timestamp: DateTime.now(),
        ));

        notifyListeners();

        // Generate AI response
        await _generateAIResponse();
      } else {
        // Invalid response
        _failedAttempts++;
        _currentValidationState = ValidationState.invalid;

        // Update user message with validation feedback
        final index = _messages.indexWhere((m) => m.id == userMessage.id);
        if (index != -1) {
          _messages[index] = ChatMessage(
            id: userMessage.id,
            content: userMessage.content,
            type: userMessage.type,
            timestamp: userMessage.timestamp,
            validationState: ValidationState.invalid,
            metadata: {
              'feedback': validation.feedback,
              'examples': validation.examples,
              'failedAttempts': _failedAttempts,
            },
          );
        }

        // Check if we need forced typing mode after 3 language errors
        if (_failedAttempts >= 3 && validation.examples.isNotEmpty) {
          _enterForcedTypingMode(validation.examples);
        }

        notifyListeners();
      }
    } catch (e) {
      _logger.e('Failed to send message', error: e);
      _error = 'Failed to send message: ${e.toString()}';
      _isValidating = false;
      _currentValidationState = ValidationState.notValidated;
      notifyListeners();
    }
  }

  // Generate AI response
  Future<void> _generateAIResponse() async {
    try {
      _isLoadingResponse = true;
      notifyListeners();

      final response = await _level2Service.generateAIResponse(
        roleplayContext: _selectedRoleplay!.scenario,
        conversationHistory: _conversationHistory,
        userProfile: {
          'age': userProfile.age,
          'arabicLevel': userProfile.arabicLevel.name,
          'tryingToLearn': userProfile.tryingToLearnThis,
          'learnedWords': userProfile.learnedWords,
        },
        lastUserMessage: _conversationHistory.last.message,
      );

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response,
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
      _conversationHistory.add(ConversationTurn(
        role: 'ai',
        message: response,
        timestamp: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      _logger.e('Failed to generate AI response', error: e);
      _error = 'Failed to generate response: ${e.toString()}';
      notifyListeners();
    } finally {
      _isLoadingResponse = false;
      notifyListeners();
    }
  }

  // Forced typing mode
  void _enterForcedTypingMode(List<String> examples) {
    if (examples.isEmpty) return;

    // Pick a random example
    final randomIndex = DateTime.now().millisecond % examples.length;
    _forcedTypingText = examples[randomIndex];

    // Initialize forced input state
    _forcedInputState = InputState(
      expectedInput: _forcedTypingText!,
      currentInput: '',
      characterStates: [],
      isComplete: false,
      cursorPosition: 0,
    );

    _currentValidationState = ValidationState.correctionRequired;
    notifyListeners();
  }

  // Process character input for forced typing
  void processForcedCharacterInput(String character, int position) {
    if (_forcedInputState == null || _forcedTypingText == null) return;

    final newState = _inputValidator.processCharacterInput(
      currentState: _forcedInputState!,
      inputCharacter: character,
      position: position,
    );

    _forcedInputState = newState;

    if (newState.isComplete) {
      _completeForcedTyping();
    }

    notifyListeners();
  }

  // Process backspace for forced typing
  void processForcedBackspace() {
    if (_forcedInputState == null) return;

    final newState = _inputValidator.processBackspace(
      currentState: _forcedInputState!,
    );

    _forcedInputState = newState;
    notifyListeners();
  }

  // Complete forced typing
  void _completeForcedTyping() {
    if (_forcedTypingText == null) return;

    // Add the corrected message
    final correctedMessage = ChatMessage(
      id: _uuid.v4(),
      content: _forcedTypingText!,
      type: MessageType.user,
      timestamp: DateTime.now(),
      validationState: ValidationState.valid,
      metadata: {
        'wasCorrected': true,
      },
    );

    _messages.add(correctedMessage);
    _conversationHistory.add(ConversationTurn(
      role: 'user',
      message: _forcedTypingText!,
      timestamp: DateTime.now(),
    ));

    // Reset forced typing state
    _forcedTypingText = null;
    _forcedInputState = null;
    _failedAttempts = 0;
    _currentValidationState = ValidationState.valid;

    notifyListeners();

    // Generate AI response
    _generateAIResponse();
  }

  // Helper method to determine expected response type
  String _determineExpectedResponseType(String aiMessage) {
    // Keep it simple - we're just having a conversation
    return 'natural_conversation_response';
  }

  // Cancel current roleplay
  void cancelRoleplay() {
    _selectedRoleplay = null;
    _messages.clear();
    _conversationHistory.clear();
    _failedAttempts = 0;
    _forcedTypingText = null;
    _forcedInputState = null;
    _currentValidationState = ValidationState.notValidated;
    _lastValidation = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _openAIService.dispose();
    _level2Service.dispose();
    super.dispose();
  }
}