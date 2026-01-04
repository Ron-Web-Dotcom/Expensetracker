import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class DatabasePerformanceWidget extends StatelessWidget {
  const DatabasePerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: EdgeInsets.all(3.w),
      children: [
        _buildQueryPerformance(context),
        SizedBox(height: 2.h),
        _buildStorageUsage(context),
        SizedBox(height: 2.h),
        _buildBackupStatus(context),
        SizedBox(height: 2.h),
        _buildSyncPerformance(context),
      ],
    );
  }

  Widget _buildQueryPerformance(BuildContext context) {
    final theme = Theme.of(context);

    final queries = [
      {'name': 'Expense Fetch', 'time': '12ms', 'status': 'good'},
      {'name': 'Budget Calculation', 'time': '28ms', 'status': 'good'},
      {'name': 'Analytics Aggregation', 'time': '45ms', 'status': 'warning'},
      {'name': 'Receipt Query', 'time': '18ms', 'status': 'good'},
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
                Icons.query_stats,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Query Execution Times',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...queries.map(
            (query) => _buildQueryRow(
              context,
              name: query['name']!,
              time: query['time']!,
              status: query['status']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryRow(
    BuildContext context, {
    required String name,
    required String time,
    required String status,
  }) {
    final theme = Theme.of(context);
    Color statusColor = status == 'good' ? Colors.green : Colors.orange;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13.sp,
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

  Widget _buildStorageUsage(BuildContext context) {
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
                Icons.storage,
                color: theme.colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                'Storage Usage',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildStorageBar(context, 'Expenses', 45.2, Colors.blue),
          SizedBox(height: 1.5.h),
          _buildStorageBar(context, 'Receipts', 28.6, Colors.purple),
          SizedBox(height: 1.5.h),
          _buildStorageBar(context, 'Analytics', 12.8, Colors.orange),
          SizedBox(height: 1.5.h),
          _buildStorageBar(context, 'Other', 8.4, Colors.grey),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Used',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '95 MB / 500 MB',
                style: TextStyle(
                  fontSize: 14.sp,
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

  Widget _buildStorageBar(
    BuildContext context,
    String category,
    double mb,
    Color color,
  ) {
    final theme = Theme.of(context);
    final percentage = mb / 500;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              '${mb.toStringAsFixed(1)} MB',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildBackupStatus(BuildContext context) {
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
              Icon(Icons.backup, color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                'Backup Status',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildBackupRow(
            context,
            'Last Backup',
            '2 hours ago',
            Icons.check_circle,
            Colors.green,
          ),
          _buildBackupRow(
            context,
            'Success Rate',
            '100%',
            Icons.trending_up,
            Colors.green,
          ),
          _buildBackupRow(
            context,
            'Next Scheduled',
            'In 22 hours',
            Icons.schedule,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildBackupRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncPerformance(BuildContext context) {
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
              Icon(Icons.sync, color: theme.colorScheme.primary, size: 20.sp),
              SizedBox(width: 2.w),
              Text(
                'Sync Performance',
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
              _buildSyncStat(context, '1.2s', 'Avg Sync Time'),
              _buildSyncStat(context, '99.5%', 'Success Rate'),
              _buildSyncStat(context, '3', 'Devices'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStat(BuildContext context, String value, String label) {
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
}
