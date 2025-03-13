import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final double? elevation;
  final VoidCallback? onTap;
  final bool hasShadow;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
    this.onTap,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
        color: backgroundColor ?? AppColors.surface,
        borderRadius: borderRadius ?? AppBorderRadius.lg,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? AppBorderRadius.lg,
        child: card,
      );
    }

    return card;
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const InfoCard({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: backgroundColor ?? AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withOpacity(0.1),
              borderRadius: AppBorderRadius.md,
            ),
            child: Icon(
              icon,
              size: 24,
              color: iconColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right,
              color: AppColors.textLight,
            ),
        ],
      ),
    );
  }
} 