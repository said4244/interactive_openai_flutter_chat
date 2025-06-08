import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interactive_arabic_chat_roleplay/interactive_arabic_chat_roleplay.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Providers
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService();
});

final level2ServiceProvider = Provider<Level2ConversationService>((ref) {
  return Level2ConversationService();
});

final level2ChatControllerProvider = ChangeNotifierProvider<Level2ChatController>((ref) {
  final userProfile = UserProfile(
    userId: 'user123',
    age: 12,
    birthDate: DateTime(2011, 5, 15),
    motherCountry: 'Egypt',
    motherCulture: 'Egyptian',
    strongestLanguage: 'English',
    arabicLevel: ArabicLevel.beginner,
    tryingToLearnThis: 'Alif fatha tanwin',
    learnedWords: ['مرحبا', 'شكرا', 'من فضلك', 'نعم', 'لا', 'كيف حالك'],
    grammarCapabilities: GrammarCapabilities(
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
    selectedLevel: 'level2',
  );

  return Level2ChatController(
    openAIService: ref.watch(openAIServiceProvider),
    level2Service: ref.watch(level2ServiceProvider),
    userProfile: userProfile,
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  runApp(
    const ProviderScope(
      child: InteractiveArabicChatApp(),
    ),
  );
}

class InteractiveArabicChatApp extends StatelessWidget {
  const InteractiveArabicChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Arabic Chat - Level 2',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const Level2HomePage(),
    );
  }
}

class Level2HomePage extends ConsumerStatefulWidget {
  const Level2HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<Level2HomePage> createState() => _Level2HomePageState();
}

class _Level2HomePageState extends ConsumerState<Level2HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(level2ChatControllerProvider).loadRoleplayTitles();
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(level2ChatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Arabic Chat - Level 2'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Show validation rules info
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showValidationRulesDialog(context, controller);
            },
          ),
        ],
      ),
      body: controller.selectedRoleplay == null
          ? _buildRoleplaySelection(controller)
          : _buildChatInterface(controller),
    );
  }

  void _showValidationRulesDialog(BuildContext context, Level2ChatController controller) {
    final rules = controller.currentValidationRules;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Current Validation Rules'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'The system is currently checking for:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...rules.entries.map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      entry.value ? Icons.check_circle : Icons.cancel,
                      color: entry.value ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFeatureName(entry.key),
                        style: TextStyle(
                          color: entry.value ? Colors.black : Colors.grey,
                          decoration: entry.value ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
              const SizedBox(height: 16),
              const Text(
                'Note: Unchecked features will not be marked as errors, allowing progressive learning.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  String _getFeatureName(String key) {
    final featureNames = {
      'checkSpelling': 'Basic Spelling',
      'checkHamza': 'Hamza (أ إ آ ء ؤ ئ)',
      'checkTaaMarbouta': 'Taa Marbouta (ة vs ه)',
      'checkAlefMaqsura': 'Alef Maqsura (ى vs ي)',
      'checkTanween': 'Tanween (ً ٌ ٍ)',
      'checkDiacritics': 'Diacritics (َ ُ ِ)',
      'checkShadda': 'Shadda (ّ)',
      'checkSukoon': 'Sukoon (ْ)',
      'checkMadda': 'Madda (آ)',
      'checkLamAlef': 'Lam Alef (لا)',
      'checkSentenceStructure': 'Sentence Structure',
      'checkGrammar': 'Basic Grammar',
      'checkGenderAgreement': 'Gender Agreement',
      'checkDualPlural': 'Dual/Plural Forms',
      'checkVerbConjugation': 'Verb Conjugation',
      'checkPronounAgreement': 'Pronoun Agreement',
    };
    return featureNames[key] ?? key;
  }

  Widget _buildRoleplaySelection(Level2ChatController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: ${controller.error}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadRoleplayTitles(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.roleplayTitles.length,
      itemBuilder: (context, index) {
        final roleplay = controller.roleplayTitles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(
              roleplay.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(roleplay.description),
                const SizedBox(height: 8),
                Text(
                  'Scenario: ${roleplay.scenario}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(roleplay.difficulty),
                      backgroundColor: _getDifficultyColor(roleplay.difficulty),
                    ),
                    Chip(
                      label: Text('${roleplay.estimatedVocabulary.length} words'),
                      backgroundColor: Colors.blue[100],
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => controller.selectRoleplay(roleplay),
          ),
        );
      },
    );
  }

  Widget _buildChatInterface(Level2ChatController controller) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: controller.messages.length,
            itemBuilder: (context, index) {
              final message = controller.messages[index];
              return _buildChatMessage(message, controller);
            },
          ),
        ),
        
        // Input area
        if (controller.isInForcedTypingMode)
          _buildForcedTypingInterface(controller)
        else
          _buildNormalInputInterface(controller),
      ],
    );
  }

  Widget _buildChatMessage(ChatMessage message, Level2ChatController controller) {
    final isUser = message.type == MessageType.user;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.blue[100] : Colors.grey[200];
    
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: message.validationState == ValidationState.invalid
              ? Border.all(color: Colors.red, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 18,
                color: message.validationState == ValidationState.invalid
                    ? Colors.red[700]
                    : null,
              ),
            ),
            
            // Show feedback for invalid messages
            if (message.validationState == ValidationState.invalid &&
                message.metadata?['feedback'] != null) ...[
              const SizedBox(height: 8),
              Text(
                message.metadata!['feedback'],
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (message.metadata?['analysis'] != null && message.metadata!['analysis']['uncheckedErrors'] != null && (message.metadata!['analysis']['uncheckedErrors'] as List).isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '(Student hasn\'t learned: ${(message.metadata!['analysis']['uncheckedErrors'] as List).join(', ')})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
              if (message.metadata?['examples'] != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Try one of these:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                ...List<String>.from(message.metadata!['examples']).map(
                  (example) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '• $example',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
            
            // Show metadata for AI messages
            if (!isUser && message.metadata != null) ...[
              const SizedBox(height: 8),
              if (message.metadata!['translation'] != null)
                Text(
                  message.metadata!['translation'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNormalInputInterface(Level2ChatController controller) {
  return Column(
    children: [
      // Input field
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -2),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  _messageController.text.isEmpty 
                      ? 'اكتب رسالتك هنا...' 
                      : _messageController.text,
                  style: TextStyle(
                    fontSize: 18,
                    color: _messageController.text.isEmpty 
                        ? Colors.grey 
                        : Colors.black,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 25,
              backgroundColor: _messageController.text.isEmpty 
                  ? Colors.grey 
                  : Theme.of(context).primaryColor,
              child: IconButton(
                icon: controller.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: controller.isLoading || _messageController.text.isEmpty
                    ? null
                    : () {
                        controller.sendUserMessage(_messageController.text);
                        _messageController.clear();
                        _scrollToBottom();
                      },
              ),
            ),
          ],
        ),
      ),
      
      // Arabic keyboard
      ArabicKeyboardWidget(
        enabled: !controller.isLoading,
        highlightNextKey: false, // No highlighting for free typing
        onKeyPressed: (character) {
          setState(() {
            _messageController.text += character;
          });
        },
        onBackspace: () {
          setState(() {
            if (_messageController.text.isNotEmpty) {
              _messageController.text = _messageController.text
                  .substring(0, _messageController.text.length - 1);
            }
          });
        },
        onSpace: () {
          setState(() {
            _messageController.text += ' ';
          });
        },
      ),
    ],
  );
}

  Widget _buildForcedTypingInterface(Level2ChatController controller) {
  final forcedText = controller.forcedTypingText ?? '';
  final inputState = controller.forcedInputState;
  
  return Column(
    children: [
      // Instruction and expected text
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border(
            bottom: BorderSide(color: Colors.orange[300]!, width: 1),
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Please type this message correctly:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Text(
                forcedText,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 8),
            // Display current typing progress
            if (inputState != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  textDirection: TextDirection.rtl,
                  children: [
                    for (int i = 0; i < forcedText.length; i++)
                      Text(
                        i < inputState.characterStates.length
                            ? inputState.characterStates[i].character
                            : '_',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: i < inputState.characterStates.length
                              ? (inputState.characterStates[i].status == CharacterStatus.correct
                                  ? Colors.green
                                  : Colors.red)
                              : Colors.grey[400],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      
      // Arabic keyboard
      ArabicKeyboardWidget(
        currentInputState: inputState,
        highlightNextKey: true,
        enabled: true,
        onKeyPressed: (character) {
          if (inputState != null) {
            final nextPosition = inputState.characterStates.length;
            controller.processForcedCharacterInput(character, nextPosition);
          }
        },
        onBackspace: () {
          controller.processForcedBackspace();
        },
        onSpace: () {
          // Handle space if needed
          if (inputState != null) {
            final nextPosition = inputState.characterStates.length;
            controller.processForcedCharacterInput(' ', nextPosition);
          }
        },
      ),
    ],
  );
}

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'hard':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}