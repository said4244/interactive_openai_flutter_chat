import 'package:json_annotation/json_annotation.dart';
import 'level2_models.dart';

part 'chat_message.g.dart';

enum MessageType { user, ai, system }
enum CharacterStatus { pending, correct, incorrect }

@JsonSerializable()
class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final InputState? inputState; // For level 1
  final ValidationState? validationState; // For level 2
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.inputState,
    this.validationState,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}

@JsonSerializable()
class InputState {
  final String expectedInput;
  final String currentInput;
  final List<CharacterState> characterStates;
  final bool isComplete;
  final int cursorPosition;

  InputState({
    required this.expectedInput,
    required this.currentInput,
    required this.characterStates,
    required this.isComplete,
    required this.cursorPosition,
  });

  factory InputState.fromJson(Map<String, dynamic> json) =>
      _$InputStateFromJson(json);

  Map<String, dynamic> toJson() => _$InputStateToJson(this);

  InputState copyWith({
    String? expectedInput,
    String? currentInput,
    List<CharacterState>? characterStates,
    bool? isComplete,
    int? cursorPosition,
  }) {
    return InputState(
      expectedInput: expectedInput ?? this.expectedInput,
      currentInput: currentInput ?? this.currentInput,
      characterStates: characterStates ?? this.characterStates,
      isComplete: isComplete ?? this.isComplete,
      cursorPosition: cursorPosition ?? this.cursorPosition,
    );
  }
}

@JsonSerializable()
class CharacterState {
  final int index;
  final String character;
  final CharacterStatus status;

  CharacterState({
    required this.index,
    required this.character,
    required this.status,
  });

  factory CharacterState.fromJson(Map<String, dynamic> json) =>
      _$CharacterStateFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterStateToJson(this);
}