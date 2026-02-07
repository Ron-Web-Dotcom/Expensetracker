import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Biometric Authentication Screen
/// Provides secure app access using device biometric capabilities
class BiometricAuthentication extends StatefulWidget {
  const BiometricAuthentication({super.key});

  @override
  State<BiometricAuthentication> createState() =>
      _BiometricAuthenticationState();
}

class _BiometricAuthenticationState extends State<BiometricAuthentication>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isAuthenticating = false;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  String _errorMessage = '';
  int _failedAttempts = 0;
  static const int _maxFailedAttempts = 3;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    _checkBiometricSupport();
    _checkLockoutStatus();
    // Trigger biometric prompt immediately on screen appearance
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _authenticateWithBiometrics();
      }
    });
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _checkBiometricSupport() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (_canCheckBiometrics) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to check biometric support';
        });
      }
    }
  }

  Future<void> _checkLockoutStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutEnd = prefs.getInt('biometric_lockout_end');
    if (lockoutEnd != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now < lockoutEnd) {
        if (mounted) {
          setState(() {
            _failedAttempts = _maxFailedAttempts;
          });
        }
      } else {
        await prefs.remove('biometric_lockout_end');
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_failedAttempts >= _maxFailedAttempts) {
      _showLockoutMessage();
      return;
    }

    if (!_canCheckBiometrics || _availableBiometrics.isEmpty) {
      _showBiometricSetupGuidance();
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      final bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your financial data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        _handleAuthenticationSuccess();
      } else {
        _handleAuthenticationFailure();
      }
    } on PlatformException catch (e) {
      _handlePlatformException(e);
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _handleAuthenticationSuccess() {
    HapticFeedback.mediumImpact();

    // Show success animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );

    // Navigate to dashboard after celebration
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.pushReplacementNamed(context, '/expense-dashboard');
      }
    });
  }

  void _handleAuthenticationFailure() {
    HapticFeedback.heavyImpact();
    setState(() {
      _failedAttempts++;
      _errorMessage = _failedAttempts >= _maxFailedAttempts
          ? 'Too many failed attempts. Please try again later.'
          : 'Authentication failed. Please try again.';
    });
  }

  void _handlePlatformException(PlatformException e) {
    HapticFeedback.heavyImpact();
    String message = 'Authentication error occurred';

    if (e.code == 'NotAvailable') {
      message = 'Biometric authentication not available';
    } else if (e.code == 'NotEnrolled') {
      _showBiometricSetupGuidance();
      return;
    } else if (e.code == 'LockedOut') {
      message = 'Too many attempts. Please try again later.';
      _failedAttempts = _maxFailedAttempts;
    }

    setState(() {
      _errorMessage = message;
      _failedAttempts++;
    });
  }

  void _showBiometricSetupGuidance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Biometric Setup Required',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Please set up biometric authentication in your device settings to use this feature.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _usePasscodeInstead();
            },
            child: const Text('Use Passcode'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/splash-screen');
            },
            child: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  void _showLockoutMessage() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Account Locked',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Too many failed authentication attempts. Please wait 30 seconds before trying again.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/splash-screen');
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    // Reset failed attempts after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _failedAttempts = 0;
        });
      }
    });

    // Store lockout timestamp in SharedPreferences for persistence
    final prefs = await SharedPreferences.getInstance();
    final lockoutEndTime = DateTime.now()
        .add(const Duration(seconds: 30))
        .millisecondsSinceEpoch;
    await prefs.setInt('biometric_lockout_end', lockoutEndTime);
  }

  void _usePasscodeInstead() {
    setState(() {
      _isAuthenticating = true;
    });

    // Trigger system passcode authentication
    _localAuth
        .authenticate(
          localizedReason: 'Enter your device passcode',
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
            useErrorDialogs: true,
          ),
        )
        .then((authenticated) {
          if (authenticated) {
            _handleAuthenticationSuccess();
          } else {
            _handleAuthenticationFailure();
          }
        })
        .catchError((e) {
          if (mounted) {
            setState(() {
              _isAuthenticating = false;
            });
          }
        });
  }

  void _cancelAuthentication() {
    Navigator.pushReplacementNamed(context, '/splash-screen');
  }

  Widget _buildSuccessDialog() {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.primary,
                size: 12.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Authentication Successful!',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Welcome back to ExpenseTracker',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Biometric Icon with Pulse Animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 30.w,
                      height: 30.w,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: CustomIconWidget(
                        iconName:
                            _availableBiometrics.contains(BiometricType.face)
                            ? 'face'
                            : 'fingerprint',
                        color: theme.colorScheme.primary,
                        size: 18.w,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 6.h),

              // Heading
              Text(
                'Unlock ExpenseTracker',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 2.h),

              // Subtitle
              Text(
                'Biometric authentication is required to protect your financial data',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 4.h),

              // Error Message
              _errorMessage.isNotEmpty
                  ? Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'error_outline',
                            color: theme.colorScheme.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(height: 4.h),

              // Loading Indicator
              _isAuthenticating
                  ? SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(height: 6.h),

              // Retry Button
              !_isAuthenticating &&
                      _errorMessage.isNotEmpty &&
                      _failedAttempts < _maxFailedAttempts
                  ? ElevatedButton(
                      onPressed: _authenticateWithBiometrics,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: theme.textTheme.labelLarge,
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(height: 2.h),

              // Use Passcode Button
              !_isAuthenticating &&
                      _failedAttempts > 0 &&
                      _failedAttempts < _maxFailedAttempts
                  ? OutlinedButton(
                      onPressed: _usePasscodeInstead,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 7.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Use Passcode',
                        style: theme.textTheme.labelLarge,
                      ),
                    )
                  : const SizedBox.shrink(),

              SizedBox(height: 2.h),

              // Cancel Button
              TextButton(
                onPressed: _cancelAuthentication,
                style: TextButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              SizedBox(height: 4.h),

              // Security Tips
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Security Tips',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '• Keep your biometric data secure\n• Never share your device passcode\n• Enable two-factor authentication',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
