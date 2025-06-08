// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$MessageTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      inputState: json['inputState'] == null
          ? null
          : InputState.fromJson(json['inputState'] as Map<String, dynamic>),
      validationState: $enumDecodeNullable(
          _$ValidationStateEnumMap, json['validationState']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'inputState': instance.inputState,
      'validationState': _$ValidationStateEnumMap[instance.validationState],
      'metadata': instance.metadata,
    };

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.ai: 'ai',
  MessageType.system: 'system',
};

const _$ValidationStateEnumMap = {
  ValidationState.notValidated: 'notValidated',
  ValidationState.validating: 'validating',
  ValidationState.valid: 'valid',
  ValidationState.invalid: 'invalid',
  ValidationState.correctionRequired: 'correctionRequired',
};

InputState _$InputStateFromJson(Map<String, dynamic> json) => InputState(
      expectedInput: json['expectedInput'] as String,
      currentInput: json['currentInput'] as String,
      characterStates: (json['characterStates'] as List<dynamic>)
          .map((e) => CharacterState.fromJson(e as Map<String, dynamic>))
          .toList(),
      isComplete: json['isComplete'] as bool,
      cursorPosition: (json['cursorPosition'] as num).toInt(),
    );

Map<String, dynamic> _$InputStateToJson(InputState instance) =>
    <String, dynamic>{
      'expectedInput': instance.expectedInput,
      'currentInput': instance.currentInput,
      'characterStates': instance.characterStates,
      'isComplete': instance.isComplete,
      'cursorPosition': instance.cursorPosition,
    };

CharacterState _$CharacterStateFromJson(Map<String, dynamic> json) =>
    CharacterState(
      index: (json['index'] as num).toInt(),
      character: json['character'] as String,
      status: $enumDecode(_$CharacterStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$CharacterStateToJson(CharacterState instance) =>
    <String, dynamic>{
      'index': instance.index,
      'character': instance.character,
      'status': _$CharacterStatusEnumMap[instance.status]!,
    };

const _$CharacterStatusEnumMap = {
  CharacterStatus.pending: 'pending',
  CharacterStatus.correct: 'correct',
  CharacterStatus.incorrect: 'incorrect',
};
