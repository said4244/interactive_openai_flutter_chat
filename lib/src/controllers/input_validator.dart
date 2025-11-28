import '../models/chat_message.dart';

class InputValidator {
  
  InputState processCharacterInput({
    required InputState currentState,
    required String inputCharacter,
    required int position,
  }) {
    // Validate position
    if (position < 0 || position >= currentState.expectedInput.length) {
      return currentState;
    }
    
    // Get expected character at this position
    final expectedChar = currentState.expectedInput[position];
    final isCorrect = inputCharacter == expectedChar;
    
    // Create new character states list
    final newCharacterStates = List<CharacterState>.from(currentState.characterStates);
    
    // Find if we already have a state for this position
    final existingIndex = newCharacterStates.indexWhere((s) => s.index == position);
    
    final newCharState = CharacterState(
      index: position,
      character: inputCharacter,
      status: isCorrect ? CharacterStatus.correct : CharacterStatus.incorrect,
    );
    
    if (existingIndex >= 0) {
      // Update existing state
      newCharacterStates[existingIndex] = newCharState;
    } else {
      // Add new state
      newCharacterStates.add(newCharState);
    }
    
    // Sort by index to maintain order
    newCharacterStates.sort((a, b) => a.index.compareTo(b.index));
    
    // Build current input string
    final currentInputBuilder = StringBuffer();
    for (int i = 0; i < currentState.expectedInput.length; i++) {
      final charState = newCharacterStates.firstWhere(
        (s) => s.index == i,
        orElse: () => CharacterState(
          index: i,
          character: '',
          status: CharacterStatus.pending,
        ),
      );
      
      if (charState.status != CharacterStatus.pending) {
        currentInputBuilder.write(charState.character);
      }
    }
    
    final newCurrentInput = currentInputBuilder.toString();
    
    // Check if complete (all characters are correct)
    final isComplete = newCharacterStates.length == currentState.expectedInput.length &&
        newCharacterStates.every((s) => s.status == CharacterStatus.correct);
    
    return currentState.copyWith(
      currentInput: newCurrentInput,
      characterStates: newCharacterStates,
      isComplete: isComplete,
      cursorPosition: position + 1,
    );
  }
  
  InputState processBackspace({
    required InputState currentState,
  }) {
    if (currentState.characterStates.isEmpty) {
      return currentState;
    }
    
    // Find the last incorrect character to remove
    // If no incorrect characters, remove the last character
    final incorrectStates = currentState.characterStates
        .where((s) => s.status == CharacterStatus.incorrect)
        .toList();
    
    CharacterState? stateToRemove;
    
    if (incorrectStates.isNotEmpty) {
      // Remove the first incorrect character (leftmost)
      stateToRemove = incorrectStates.reduce((a, b) => a.index < b.index ? a : b);
    } else {
      // Remove the last correct character
      stateToRemove = currentState.characterStates.reduce((a, b) => 
        a.index > b.index ? a : b);
    }
    
    if (stateToRemove == null) return currentState;
    
    // Create new character states without the removed character
    final newCharacterStates = currentState.characterStates
        .where((s) => s.index != stateToRemove!.index)
        .toList();
    
    // Rebuild current input
    final currentInputBuilder = StringBuffer();
    for (final state in newCharacterStates) {
      if (state.status != CharacterStatus.pending) {
        currentInputBuilder.write(state.character);
      }
    }
    
    return currentState.copyWith(
      currentInput: currentInputBuilder.toString(),
      characterStates: newCharacterStates,
      isComplete: false,
      cursorPosition: stateToRemove.index,
    );
  }
  
  bool hasIncorrectCharacters(InputState state) {
    return state.characterStates.any((s) => s.status == CharacterStatus.incorrect);
  }
  
  int getNextInputPosition(InputState state) {
    // Find the first position without a character state
    for (int i = 0; i < state.expectedInput.length; i++) {
      if (!state.characterStates.any((s) => s.index == i)) {
        return i;
      }
    }
    // If all positions have states, find the first incorrect one
    final incorrectState = state.characterStates
        .firstWhere((s) => s.status == CharacterStatus.incorrect, 
                    orElse: () => CharacterState(index: state.expectedInput.length, 
                                                 character: '', 
                                                 status: CharacterStatus.pending));
    return incorrectState.index;
  }
  
  List<int> getIncorrectPositions(InputState state) {
    return state.characterStates
        .where((s) => s.status == CharacterStatus.incorrect)
        .map((s) => s.index)
        .toList();
  }
}