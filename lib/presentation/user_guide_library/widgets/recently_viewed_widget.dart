import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RecentlyViewedWidget extends StatelessWidget {
  final List<Map<String, dynamic>> recentGuides;
  final Function(Map<String, dynamic>) onGuideTap;

  const RecentlyViewedWidget({
    super.key,
    required this.recentGuides,
    required this.onGuideTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Recently Viewed',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 12.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: recentGuides.length,
              itemBuilder: (context, index) {
                final guide = recentGuides[index];
                return _buildRecentGuideCard(guide, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentGuideCard(
    Map<String, dynamic> guide,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 70.w,
      margin: EdgeInsets.only(right: 3.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => onGuideTap(guide),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (guide['color'] as Color).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    guide['icon'] as IconData,
                    color: guide['color'] as Color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        guide['title'],
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        guide['duration'],
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
