import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final String route;
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const CustomBottomBarItem({
    required this.route,
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// Custom bottom navigation bar for personal finance app
/// Implements bottom-heavy interaction design with thumb-friendly positioning
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Navigation items based on Mobile Navigation Hierarchy
  static final List<CustomBottomBarItem> _navigationItems = [
    const CustomBottomBarItem(
      route: '/expense-dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const CustomBottomBarItem(
      route: '/transaction-history',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'History',
    ),
    const CustomBottomBarItem(
      route: '/add-expense',
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Add',
    ),
    const CustomBottomBarItem(
      route: '/analytics-dashboard',
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Analytics',
    ),
    const CustomBottomBarItem(
      route: '/settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) =>
                  _buildNavigationItem(context, _navigationItems[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    CustomBottomBarItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    // Determine colors based on selection state
    final iconColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final labelColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          // Haptic feedback for confident interaction
          HapticFeedback.lightImpact();

          // Navigate to the selected route
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, item.route);
          }

          // Call the onTap callback
          onTap(index);
        },
        splashColor: colorScheme.primary.withValues(alpha: 0.1),
        highlightColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth transition
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Icon(
                  isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label with fade animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: theme.textTheme.labelMedium!.copyWith(
                  color: labelColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extension to easily add CustomBottomBar to Scaffold
extension CustomBottomBarExtension on Widget {
  Widget withCustomBottomBar({
    required int currentIndex,
    required Function(int) onTap,
  }) {
    return Builder(
      builder: (context) {
        return Scaffold(
          body: this,
          bottomNavigationBar: CustomBottomBar(
            currentIndex: currentIndex,
            onTap: onTap,
          ),
        );
      },
    );
  }
}
