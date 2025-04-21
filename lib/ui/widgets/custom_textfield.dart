// lib/ui/widgets/custom_textfield.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final EdgeInsets contentPadding;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16.0,
      vertical: 16.0,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
        contentPadding: contentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: autofocus,
      textInputAction: textInputAction,
      focusNode: focusNode,
    );
  }
}