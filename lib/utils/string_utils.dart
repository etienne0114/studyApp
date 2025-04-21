/// Utility class for string operations.
class StringUtils {
  /// Capitalize the first letter of each word in a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Truncate a string to a specified length and add ellipsis if needed.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get initials from a name (e.g., "John Doe" -> "JD").
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Remove HTML tags from a string.
  static String stripHtml(String htmlString) {
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Check if a string is a valid email address.
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    return emailRegex.hasMatch(email);
  }

  /// Convert a string to camelCase.
  static String toCamelCase(String text) {
    if (text.isEmpty) return text;
    
    final words = text.split(RegExp(r'[_\s-]+'));
    final firstWord = words[0].toLowerCase();
    final remainingWords = words.skip(1).map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });
    
    return [firstWord, ...remainingWords].join('');
  }

  /// Format a file size in bytes to a human-readable string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get a file extension from a filename.
  static String getFileExtension(String filename) {
    final parts = filename.split('.');
    if (parts.length <= 1) return '';
    return parts.last.toLowerCase();
  }

  /// Generate a random string of specified length.
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) {
      final randomIndex = DateTime.now().microsecondsSinceEpoch % chars.length;
      return chars[randomIndex];
    }).join('');
  }

  /// Mask a credit card number (only show last 4 digits).
  static String maskCreditCard(String cardNumber) {
    if (cardNumber.length <= 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return 'XXXX-XXXX-XXXX-$lastFour';
  }

  /// Add ordinal suffix to a number (1st, 2nd, 3rd, etc.).
  static String addOrdinalSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    
    switch (number % 10) {
      case 1: return '${number}st';
      case 2: return '${number}nd';
      case 3: return '${number}rd';
      default: return '${number}th';
    }
  }

  /// Convert snake_case to Title Case.
  static String snakeToTitleCase(String text) {
    return text.split('_').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Check if a string contains only digits.
  static bool isNumeric(String text) {
    return RegExp(r'^[0-9]+$').hasMatch(text);
  }

  /// Format a phone number (e.g., "1234567890" -> "(123) 456-7890").
  static String formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) return phoneNumber;
    
    // Format as (XXX) XXX-XXXX for US numbers
    return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 10)}';
  }
}