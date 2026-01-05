import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../services/alert_service.dart';

class AlertHistoryWidget extends StatefulWidget {
  final VoidCallback onRefresh;

  const AlertHistoryWidget({super.key, required this.onRefresh});

  @override
  State<AlertHistoryWidget> createState() => _AlertHistoryWidgetState();
}

class _AlertHistoryWidgetState extends State<AlertHistoryWidget> {
  final AlertService _alertService = AlertService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _alertService.getAlertHistory();
    setState(() {
      _history = history.take(10).toList();
      _isLoading = false;
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFF44336);
      case 'high':
        return const Color(0xFFFF9800);
      case 'medium':
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'budget_limit':
        return Icons.account_balance_wallet;
      case 'unusual_spending':
        return Icons.trending_up;
      case 'large_transaction':
        return Icons.credit_card;
      case 'overspending':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(String timestamp) {
    final alertDate = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(alertDate);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${alertDate.month}/${alertDate.day}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Alerts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      await _alertService.clearAlertHistory();
                      widget.onRefresh();
                      _loadHistory();
                    },
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_history.isEmpty)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 12.w,
                      color: isDark
                          ? const Color(0xFF757575)
                          : const Color(0xFFBDBDBD),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No alerts yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? const Color(0xFF757575)
                            : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _history.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFE0E0E0),
              ),
              itemBuilder: (context, index) {
                final alert = _history[index];
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(alert['severity']).withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(
                      _getTypeIcon(alert['type']),
                      color: _getSeverityColor(alert['severity']),
                      size: 5.w,
                    ),
                  ),
                  title: Text(
                    alert['title'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    alert['message'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? const Color(0xFFB0B0B0)
                          : const Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatTime(alert['timestamp']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? const Color(0xFF757575)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
