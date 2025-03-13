import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? color;
  final double? width;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
              ? Colors.transparent 
              : color ?? AppColors.primary,
          foregroundColor: isOutlined 
              ? color ?? AppColors.primary 
              : Colors.white,
          elevation: isOutlined ? 0 : 1,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
            side: isOutlined 
                ? BorderSide(color: color ?? AppColors.primary) 
                : BorderSide.none,
          ),
          disabledBackgroundColor: isOutlined 
              ? Colors.transparent 
              : AppColors.primary.withAlpha((0.8 * 255).round()),
          disabledForegroundColor: isOutlined 
              ? AppColors.primary.withAlpha((0.8 * 255).round()) 
              : Colors.white.withAlpha((0.8 * 255).round()),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                    style: AppTextStyles.button,
                  ),
                ],
              ),
      ),
    );
  }
} 