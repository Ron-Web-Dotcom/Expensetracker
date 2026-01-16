import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HabitStreakWidget extends StatelessWidget {
  final int streak;
  final double weeklyCompletionRate;

  const HabitStreakWidget({
    super.key,
    required this.streak,
    required this.weeklyCompletionRate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.all(4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withAlpha(179),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Streak Counter
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 10.w,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '$streak Day${streak != 1 ? 's' : ''}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Current Streak',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),

              // Completion Rate
              Column(
                children: [
                  SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: weeklyCompletionRate / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withAlpha(77),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        Text(
                          '${weeklyCompletionRate.toInt()}%',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Weekly Rate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: Colors.white, size: 4.w),
                SizedBox(width: 2.w),
                Text(
                  _getMotivationalMessage(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage() {
    if (streak >= 30) return 'Amazing! 30+ day streak!';
    if (streak >= 14) return 'Great! 2 weeks strong!';
    if (streak >= 7) return 'Keep it up! 1 week streak!';
    if (streak >= 3) return 'Building momentum!';
    return 'Start your streak today!';
  }
}
