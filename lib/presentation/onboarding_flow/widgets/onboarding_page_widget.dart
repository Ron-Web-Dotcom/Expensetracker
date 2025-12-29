import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual onboarding page widget with illustration and features
class OnboardingPageWidget extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final bool isActive;

  const OnboardingPageWidget({
    super.key,
    required this.pageData,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = pageData["primaryColor"] as Color;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Main illustration
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(isActive ? 1.0 : 0.9),
              child: Container(
                width: 80.w,
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomImageWidget(
                    imageUrl: pageData["image"] as String,
                    width: 80.w,
                    height: 30.h,
                    fit: BoxFit.cover,
                    semanticLabel: pageData["semanticLabel"] as String,
                  ),
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              pageData["title"] as String,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                fontSize: 24.sp,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              pageData["description"] as String,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Feature highlights
            _buildFeatureHighlights(context, primaryColor),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context, Color primaryColor) {
    final theme = Theme.of(context);
    final features = pageData["features"] as List<Map<String, dynamic>>;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: features.map((feature) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.w),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: feature["icon"] as String,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    feature["text"] as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
