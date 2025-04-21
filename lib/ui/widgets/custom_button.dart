// lib/ui/widgets/custom_button.dart

import 'package:flutter/material.dart';
import 'package:study_scheduler/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
    this.icon,
  });

  // Constructor with label for backward compatibility
  const CustomButton.withLabel({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
    Color? backgroundColor,
    Color? textColor,
    double? width,
    double height = 48.0,
    double borderRadius = 8.0,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 24.0),
    IconData? icon,
  }) : this(
          key: key,
          text: label,
          onPressed: onPressed,
          isLoading: isLoading,
          backgroundColor: backgroundColor,
          textColor: textColor,
          width: width,
          height: height,
          borderRadius: borderRadius,
          padding: padding,
          icon: icon,
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
          elevation: 2,
          disabledBackgroundColor: backgroundColor != null
              ? backgroundColor!.withOpacity(0.7)
              : AppColors.primary.withOpacity(0.7),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}