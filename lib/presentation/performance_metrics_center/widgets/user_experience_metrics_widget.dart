import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class UserExperienceMetricsWidget extends StatelessWidget {
  const UserExperienceMetricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(3.w),
      children: [
        _buildScreenTransitions(context),
        SizedBox(height: 2.h),
        _buildInputResponsiveness(context),
        SizedBox(height: 2.h),
        _buildFeatureCompletion(context),
        SizedBox(height: 2.h),
        _buildSatisfactionCorrelation(context),
      ],
    );
  }

  Widget _buildScreenTransitions(BuildContext context) {
    final theme = Theme.of(context);

    final screens = [
      {'name': 'Dashboard → Add Expense', 'smoothness': 98, 'time': '0.28s'},
      {'name': 'Analytics → Reports', 'smoothness': 96, 'time': '0.32s'},
      {'name': 'Budget → Categories', 'smoothness': 99, 'time': '0.24s'},
      {'name': 'Settings → Profile', 'smoothness': 97, 'time': '0.26s'},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.animation,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Screen Transition Smoothness',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...screens.map(
            (screen) => _buildTransitionRow(
              context,
              name: screen['name'] as String,
              smoothness: screen['smoothness'] as int,
              time: screen['time'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionRow(
    BuildContext context, {
    required String name,
    required int smoothness,
    required String time,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.8.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: smoothness / 100,
                    backgroundColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.1,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      smoothness >= 95 ? Colors.green : Colors.orange,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '$smoothness%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputResponsiveness(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Input Responsiveness',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInputStat(context, '42ms', 'Avg Response'),
              _buildInputStat(context, '98.5%', 'Success Rate'),
              _buildInputStat(context, '1.2%', 'Lag Events'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCompletion(BuildContext context) {
    final theme = Theme.of(context);

    final features = [
      {'name': 'Add Expense', 'completion': 94},
      {'name': 'Create Budget', 'completion': 88},
      {'name': 'View Analytics', 'completion': 92},
      {'name': 'Export Data', 'completion': 76},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Feature Completion Rates',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...features.map(
            (feature) => _buildFeatureRow(
              context,
              name: feature['name'] as String,
              completion: feature['completion'] as int,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context, {
    required String name,
    required int completion,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '$completion%',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: completion / 100,
              backgroundColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.1,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                completion >= 85
                    ? Colors.green
                    : completion >= 70
                    ? Colors.orange
                    : Colors.red,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionCorrelation(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sentiment_satisfied_alt,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'User Satisfaction',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSatisfactionStat(context, '4.6', 'Avg Rating', Icons.star),
              _buildSatisfactionStat(
                context,
                '92%',
                'Positive',
                Icons.thumb_up,
              ),
              _buildSatisfactionStat(context, '87%', 'Retention', Icons.repeat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 18.sp),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 0.3.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
