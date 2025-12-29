import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App bar variant types for different screen contexts
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with back button for navigation stack
  withBack,

  /// App bar with search functionality
  withSearch,

  /// Transparent app bar for overlay contexts
  transparent,

  /// App bar with large title for main sections
  large,
}

/// Custom app bar for personal finance application
/// Implements minimal elevation and clean visual hierarchy
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.onBackPressed,
    this.leading,
    this.centerTitle = false,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.searchController,
    this.onSearchChanged,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize {
    double height = kToolbarHeight;

    // Add extra height for large variant
    if (variant == CustomAppBarVariant.large) {
      height = 120;
    }

    // Add bottom widget height if present
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }

    return Size.fromHeight(height);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    final effectiveBackgroundColor =
        backgroundColor ??
        (variant == CustomAppBarVariant.transparent
            ? Colors.transparent
            : colorScheme.surface);

    final effectiveForegroundColor =
        foregroundColor ??
        (variant == CustomAppBarVariant.transparent
            ? Colors.white
            : colorScheme.onSurface);

    // Determine elevation based on variant
    final effectiveElevation =
        elevation ?? (variant == CustomAppBarVariant.transparent ? 0 : 0);

    return AppBar(
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: effectiveElevation,
      centerTitle: centerTitle,
      leading: _buildLeading(context, effectiveForegroundColor),
      title: _buildTitle(context, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      bottom: bottom,
      systemOverlayStyle: variant == CustomAppBarVariant.transparent
          ? SystemUiOverlayStyle.light
          : theme.brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    // Show back button for withBack variant or when there's a route to pop
    if (variant == CustomAppBarVariant.withBack ||
        (variant == CustomAppBarVariant.standard &&
            Navigator.canPop(context))) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: foregroundColor,
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.pop(context);
          }
        },
        tooltip: 'Back',
      );
    }

    return null;
  }

  Widget? _buildTitle(BuildContext context, Color foregroundColor) {
    final theme = Theme.of(context);

    if (variant == CustomAppBarVariant.withSearch) {
      return _buildSearchField(context, foregroundColor);
    }

    if (title == null) {
      return null;
    }

    if (variant == CustomAppBarVariant.large) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title!,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Text(
      title!,
      style: theme.textTheme.titleLarge?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context, Color foregroundColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: (_) => onSearchSubmitted?.call(),
        style: theme.textTheme.bodyMedium?.copyWith(color: foregroundColor),
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: foregroundColor.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: foregroundColor.withValues(alpha: 0.6),
            size: 20,
          ),
          suffixIcon: searchController?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: foregroundColor.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  onPressed: () {
                    searchController?.clear();
                    onSearchChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions == null || actions!.isEmpty) {
      return null;
    }

    // Apply foreground color to action icons
    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          color: foregroundColor,
          onPressed: action.onPressed,
          tooltip: action.tooltip,
        );
      }
      return action;
    }).toList();
  }
}

/// Helper class to create common app bar configurations
class CustomAppBarFactory {
  CustomAppBarFactory._();

  /// Creates a standard app bar for main screens
  static CustomAppBar standard({
    required String title,
    List<Widget>? actions,
    bool centerTitle = false,
  }) {
    return CustomAppBar(
      title: title,
      variant: CustomAppBarVariant.standard,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  /// Creates an app bar with back button for detail screens
  static CustomAppBar withBack({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      title: title,
      variant: CustomAppBarVariant.withBack,
      actions: actions,
      onBackPressed: onBackPressed,
    );
  }

  /// Creates an app bar with search functionality
  static CustomAppBar withSearch({
    TextEditingController? searchController,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onSearchSubmitted,
    List<Widget>? actions,
  }) {
    return CustomAppBar(
      variant: CustomAppBarVariant.withSearch,
      searchController: searchController,
      onSearchChanged: onSearchChanged,
      onSearchSubmitted: onSearchSubmitted,
      actions: actions,
    );
  }

  /// Creates a transparent app bar for overlay contexts
  static CustomAppBar transparent({
    String? title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      title: title,
      variant: CustomAppBarVariant.transparent,
      actions: actions,
      onBackPressed: onBackPressed,
    );
  }

  /// Creates a large title app bar for main sections
  static CustomAppBar large({required String title, List<Widget>? actions}) {
    return CustomAppBar(
      title: title,
      variant: CustomAppBarVariant.large,
      actions: actions,
    );
  }
}
