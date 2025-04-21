class HeroTags {
  static const String aiAssistantButton = 'ai_assistant_button';
  static const String aiAssistantFab = 'ai_assistant_fab';
  static const String compactAiFab = 'compact_ai_fab';
  
  // Generate a unique tag for compact AI fab
  static String getUniqueCompactAiFabTag() {
    return '${compactAiFab}_${DateTime.now().millisecondsSinceEpoch}';
  }
} 