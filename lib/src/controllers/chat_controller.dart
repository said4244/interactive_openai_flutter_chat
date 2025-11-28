import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../models/roleplay.dart';
import '../models/user_profile.dart';
import '../api/openai_service.dart';
import 'input_validator.dart';

// Base chat controller for level 1 functionality
class ChatController extends ChangeNotifier {
  final OpenAIService _openAIService;
  final UserProfile userProfile;
  final Logger _logger = Logger();
  final _uuid = const Uuid();
  
  // State
  List<RoleplayTitle> _roleplayTitles = [];
  RoleplayTitle? _selectedRoleplayTitle;
  RoleplayOption? _selectedRoleplay;
  List<ChatMessage> _messages = [];
  InputState? _currentInputState;
  int _currentMessageIndex = 0;
  bool _isLoadingTitles = false;
  bool _isLoadingConversation = false;
  String? _error;
  
  // Controllers
  final InputValidator _inputValidator = InputValidator();
  
  // Streams
  final _messageStreamController = StreamController<ChatMessage>.broadcast();
  
  ChatController({
    required OpenAIService openAIService,
    required this.userProfile,
  }) : _openAIService = openAIService;

  // Getters
  List<RoleplayTitle> get roleplayTitles => _roleplayTitles;
  RoleplayOption? get selectedRoleplay => _selectedRoleplay;
  List<ChatMessage> get messages => _messages;
  InputState? get currentInputState => _currentInputState;
  bool get isLoading => _isLoadingTitles || _isLoadingConversation;
  bool get isLoadingTitles => _isLoadingTitles;
  bool get isLoadingConversation => _isLoadingConversation;
  String? get error => _error;
  Stream<ChatMessage> get messageStream => _messageStreamController.stream;

  // Load roleplay titles
  Future<void> loadRoleplayTitles({
    required String selectedLevel,
    String? specialContext,
  }) async {
    try {
      _setLoadingTitles(true);
      _error = null;
      
      _logger.i('Loading roleplay titles for level: $selectedLevel');
      
      _roleplayTitles = await _openAIService.generateRoleplayTitles(
        userProfile: userProfile,
        selectedLevel: selectedLevel,
        specialContext: specialContext,
      );
      
      _logger.i('Loaded ${_roleplayTitles.length} roleplay titles');
      notifyListeners();
    } catch (e) {
      _logger.e('Failed to load roleplay titles', error: e);
      _error = 'Failed to load roleplays: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoadingTitles(false);
    }
  }

  // Select roleplay and load conversation
  Future<void> selectRoleplayTitle(RoleplayTitle title) async {
    try {
      _selectedRoleplayTitle = title;
      _setLoadingConversation(true);
      _error = null;
      
      _logger.i('Loading conversation for roleplay: ${title.title}');
      
      _selectedRoleplay = await _openAIService.generateRoleplayConversation(
        userProfile: userProfile,
        selectedRoleplay: title,
      );
      
      _logger.i('Loaded conversation with ${_selectedRoleplay!.messages.length} messages');
      
      // Start the session
      _startSession();
    } catch (e) {
      _logger.e('Failed to load roleplay conversation', error: e);
      _error = 'Failed to load conversation: ${e.toString()}';
      _selectedRoleplayTitle = null;
      notifyListeners();
    } finally {
      _setLoadingConversation(false);
    }
  }

  void processCharacterInput(String character, int position) {
    if (_currentInputState == null || _selectedRoleplay == null) return;
    
    final expectedMessage = _selectedRoleplay!.messages[_currentMessageIndex];
    if (expectedMessage.role != MessageRole.user) return;
    
    final newState = _inputValidator.processCharacterInput(
      currentState: _currentInputState!,
      inputCharacter: character,
      position: position,
    );
    
    _currentInputState = newState;
    
    // Update the current message's input state
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      if (lastMessage.type == MessageType.user) {
        _messages[_messages.length - 1] = ChatMessage(
          id: lastMessage.id,
          content: newState.currentInput,
          type: lastMessage.type,
          timestamp: lastMessage.timestamp,
          inputState: newState,
          metadata: lastMessage.metadata,
        );
      }
    }
    
    notifyListeners();
  }
  
  void processBackspace() {
    if (_currentInputState == null) return;
    
    _logger.i('Processing backspace');
    
    final newState = _inputValidator.processBackspace(
      currentState: _currentInputState!,
    );
    
    _currentInputState = newState;
    
    // Update the current message's input state
    if (_messages.isNotEmpty) {
      final lastMessage = _messages.last;
      if (lastMessage.type == MessageType.user) {
        _messages[_messages.length - 1] = ChatMessage(
          id: lastMessage.id,
          content: newState.currentInput,
          type: lastMessage.type,
          timestamp: lastMessage.timestamp,
          inputState: newState,
          metadata: lastMessage.metadata,
        );
      }
    }
    
    notifyListeners();
  }

  bool canSendMessage() {
    return _currentInputState?.isComplete ?? false;
  }

  void sendMessage() {
    if (!canSendMessage() || _selectedRoleplay == null) return;
    
    _logger.i('Sending message at index $_currentMessageIndex');
    
    // Move to next message
    _currentMessageIndex++;
    
    if (_currentMessageIndex < _selectedRoleplay!.messages.length) {
      _showNextMessage();
    } else {
      _completeSession();
    }
  }

  void cancelSelection() {
    _logger.i('Cancelled roleplay selection');
    _selectedRoleplayTitle = null;
    _selectedRoleplay = null;
    _messages.clear();
    _currentMessageIndex = 0;
    _currentInputState = null;
    notifyListeners();
  }

  // Private methods
  void _startSession() {
    if (_selectedRoleplay == null) return;
    
    _messages.clear();
    _currentMessageIndex = 0;
    
    _showNextMessage();
  }

  void _showNextMessage() {
    if (_selectedRoleplay == null || 
        _currentMessageIndex >= _selectedRoleplay!.messages.length) return;
    
    final message = _selectedRoleplay!.messages[_currentMessageIndex];
    
    if (message.role == MessageRole.ai) {
      // Add AI message
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: message.arabicText,
        type: MessageType.ai,
        timestamp: DateTime.now(),
        metadata: {
          'transliteration': message.transliteration,
          'translation': message.englishTranslation,
          'vocabulary': message.keyVocabulary,
          'culturalNote': message.culturalNote,
        },
      );
      
      _messages.add(aiMessage);
      _messageStreamController.add(aiMessage);
      
      // If there's a next message and it's user's turn, prepare input
      if (_currentMessageIndex + 1 < _selectedRoleplay!.messages.length) {
        _currentMessageIndex++;
        _showNextMessage();
      }
    } else {
      // Prepare for user input
      final expectedMessage = _selectedRoleplay!.messages[_currentMessageIndex];
      
      _currentInputState = InputState(
        expectedInput: expectedMessage.arabicText,
        currentInput: '',
        characterStates: [],
        isComplete: false,
        cursorPosition: 0,
      );
      
      // Add placeholder user message
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        content: '',
        type: MessageType.user,
        timestamp: DateTime.now(),
        inputState: _currentInputState,
        metadata: {
          'expectedText': expectedMessage.arabicText,
          'transliteration': expectedMessage.transliteration,
          'translation': expectedMessage.englishTranslation,
        },
      );
      
      _messages.add(userMessage);
      _messageStreamController.add(userMessage);
    }
    
    notifyListeners();
  }

  void _completeSession() {
    _logger.i('Session completed');
    
    final completionMessage = ChatMessage(
      id: _uuid.v4(),
      content: 'تهانينا! لقد أكملت المحادثة بنجاح! 🎉',
      type: MessageType.system,
      timestamp: DateTime.now(),
      metadata: {
        'translation': 'Congratulations! You completed the conversation successfully!',
        'isCompletion': true,
      },
    );
    
    _messages.add(completionMessage);
    _messageStreamController.add(completionMessage);
    
    _currentInputState = null;
    notifyListeners();
  }

  void _setLoadingTitles(bool value) {
    _isLoadingTitles = value;
    notifyListeners();
  }
  
  void _setLoadingConversation(bool value) {
    _isLoadingConversation = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageStreamController.close();
    _openAIService.dispose();
    super.dispose();
  }
}