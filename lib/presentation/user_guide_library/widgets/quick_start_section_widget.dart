import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QuickStartSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> guides;
  final Function(Map<String, dynamic>) onGuideTap;

  const QuickStartSectionWidget({
    super.key,
    required this.guides,
    required this.onGuideTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (guides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'No quick start guides available',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(4.w),
      children: [
        Text(
          'Quick Start Guides',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Get started quickly with these essential guides',
          style: TextStyle(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        ...guides.map((guide) => _buildQuickStartCard(guide, colorScheme)),
      ],
    );
  }

  Widget _buildQuickStartCard(
    Map<String, dynamic> guide,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => onGuideTap(guide),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (guide['color'] as Color).withValues(alpha: 0.1),
                (guide['color'] as Color).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: guide['color'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  guide['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide['title'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      guide['description'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          guide['duration'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
