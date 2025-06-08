import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interactive_arabic_chat_roleplay/interactive_arabic_chat_roleplay.dart';

// Add this provider definition
final chatControllerProvider = ChangeNotifierProvider<ChatController>((ref) {
  return ChatController(
    openAIService: OpenAIService(),
    userProfile: UserProfile(
      userId: 'user123',
      age: 12,
      birthDate: DateTime(2011, 5, 15),
      motherCountry: 'Egypt',
      motherCulture: 'Egyptian',
      strongestLanguage: 'English',
      arabicLevel: ArabicLevel.beginner,
      tryingToLearnThis: 'Basic Arabic',
      learnedWords: ['مرحبا', 'شكرا'],
      grammarCapabilities: 
        GrammarCapabilities(
        knowsNouns: true,
        knowsPronouns: false,
        knowsVerbs: false,
        knowsAdjectives: false,
        knowsAdverbs: false,
        knowsPrepositions: false,
        knowsConjunctions: false,
        knowsInterjections: true,
      ),
      completedRoleplays: [],
      selectedLevel: 'level1', // Use level 1 for this example
    ),
  );
});

// This example shows Level 1 functionality with forced typing for every message

class Level1Example extends ConsumerWidget {
  const Level1Example({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(chatControllerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Level 1 - Structured Typing'),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                return _buildChatMessage(message);
              },
            ),
          ),
          
          // Typing area with keyboard
          if (controller.currentInputState != null)
            Column(
              children: [
                // Expected text display
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Column(
                    children: [
                      const Text('Type this message:'),
                      const SizedBox(height: 8),
                      Text(
                        controller.currentInputState!.expectedInput,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Current progress
                      Text(
                        controller.currentInputState!.currentInput,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arabic keyboard
                ArabicKeyboardWidget(
                  currentInputState: controller.currentInputState,
                  highlightNextKey: true,
                  onKeyPressed: (character) {
                    final nextPos = controller.currentInputState!
                        .characterStates.length;
                    controller.processCharacterInput(character, nextPos);
                  },
                  onBackspace: controller.processBackspace,
                  onSpace: () {
                    final nextPos = controller.currentInputState!
                        .characterStates.length;
                    controller.processCharacterInput(' ', nextPos);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: const TextStyle(fontSize: 18),
            ),
            if (message.metadata?['translation'] != null)
              Text(
                message.metadata!['translation'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}