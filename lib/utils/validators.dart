// lib/utils/validators.dart

import 'package:flutter/material.dart';

class Validators {
  // Required field validator
  static FormFieldValidator<String> required(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  // Email validator
  static FormFieldValidator<String> email(String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty case
      }
      
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      );
      
      if (!emailRegex.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }

  // Minimum length validator
  static FormFieldValidator<String> minLength(int minLength, String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty case
      }
      
      if (value.length < minLength) {
        return message;
      }
      return null;
    };
  }

  // Maximum length validator
  static FormFieldValidator<String> maxLength(int maxLength, String message) {
    return (value) {
      if (value == null || value.isEmpty) {
        return null; // Let required validator handle empty case
      }
      
      if (value.length > maxLength) {
        return message;
      }
      return null;
    };
  }

  // Combine multiple validators
  static FormFieldValidator<String> compose(
      List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}