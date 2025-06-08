class Constants {
  // API Configuration
  static const String openAIApiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String openAIModel = 'gpt-4o-mini';
  static const String level2Model = 'gpt-4o-mini'; // Using same model for level 2
  
  // UI Constants
  static const double chatMessageFontSize = 18.0;
  static const double keyboardButtonSize = 50.0;
  static const double chatContainerHeight = 0.6; // More space for conversation
  static const double keyboardContainerHeight = 0.4;
  
  // Animation Durations
  static const Duration typingAnimationDuration = Duration(milliseconds: 150);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
  static const Duration colorTransitionDuration = Duration(milliseconds: 200);
  static const Duration validationDelay = Duration(milliseconds: 500);
  
  // Colors
  static const int correctColorValue = 0xFF4CAF50; // Green
  static const int incorrectColorValue = 0xFFF44336; // Red
  static const int pendingColorValue = 0xFF757575; // Grey
  static const int warningColorValue = 0xFFFFA726; // Orange
  
  // Limits
  static const int maxConversationTurns = 20; // 10 exchanges
  static const int maxRetries = 3;
  static const int maxFailedAttempts = 3; // Before forced typing (for language errors)
  static const Duration retryDelay = Duration(seconds: 2);
}