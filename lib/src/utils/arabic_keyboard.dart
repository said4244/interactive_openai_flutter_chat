class ArabicKeyboard {
  static const List<List<String>> layout = [
    // First row
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د'],
    // Second row
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    // Third row
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ', 'ذ'],
    // Fourth row - special characters and space
    ['؟', '،', '.', ' ', '!', '؛', 'ـ', 'َ', 'ُ', 'ِ', 'ً', 'ٌ', 'ٍ'], // Add diacritics
  ];
  
  // Diacritics/variants mapping
  static const Map<String, List<String>> diacriticsMap = {
    'ا': ['ا', 'أ', 'إ', 'آ', 'ء'],  // Alif variants
    'ه': ['ه', 'ة'],  // Haa variants
    'ى': ['ى', 'ي'],  // Yaa variants
    'و': ['و', 'ؤ'],  // Waw variants
  };
  
  static const Map<String, String> shiftMappings = {
    'ض': 'َ',  // Fatha
    'ص': 'ً',  // Tanween Fath
    'ث': 'ُ',  // Damma
    'ق': 'ٌ',  // Tanween Damm
    'ف': 'ِ',  // Kasra
    'غ': 'ٍ',  // Tanween Kasr
    'ع': 'ّ',  // Shadda
    'ه': 'آ',  // Alef with Madda
    'خ': 'إ',  // Alef with Hamza below
    'ح': 'أ',  // Alef with Hamza above
    'ج': 'ْ',  // Sukun
    'ش': '\\',
    'س': ']',
    'ي': '[',
    'ب': 'ﻷ',
    'ل': 'ﻵ',
    'ا': 'ﻹ',
    'ت': 'ﻻ',
    'ن': 'ﻶ',
    'م': '/',
    'ك': ':',
    'ط': '"',
    'ظ': '~',
    'ز': '}',
    'و': '{',
    'ة': '\'',
    'ى': 'ﺁ',
    'ر': 'ﻸ',
    'ؤ': 'ِ',
    'ء': 'ُ',
    'ئ': '×',
  };
  
  static const String space = ' ';
  static const String backspace = '⌫';
  static const String enter = '⏎';
  
  static bool hasDiacritics(String key) {
    return diacriticsMap.containsKey(key);
  }
  
  static List<String> getDiacritics(String key) {
    return diacriticsMap[key] ?? [key];
  }
  
  static String? getBaseCharacter(String character) {
    for (final entry in diacriticsMap.entries) {
      if (entry.value.contains(character)) {
        return entry.key;
      }
    }
    return null;
  }
  
  static bool isVariantOf(String baseChar, String variant) {
    final variants = diacriticsMap[baseChar];
    return variants != null && variants.contains(variant);
  }
  
  static List<String> getAllCharacters() {
    final characters = <String>{};
    
    // Add all regular characters
    for (final row in layout) {
      characters.addAll(row);
    }
    
    // Add all diacritic variants
    for (final variants in diacriticsMap.values) {
      characters.addAll(variants);
    }
    
    // Add shift mappings
    characters.addAll(shiftMappings.values);
    
    // Add special keys
    characters.add(space);
    
    return characters.toList();
  }
  
  static bool isSpecialKey(String key) {
    return key == backspace || key == enter || key == 'Shift';
  }
}