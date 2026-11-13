import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/auth/cubit/auth_cubit.dart';
import 'package:myalien/auth/cubit/auth_state.dart';
import 'package:myalien/auth/utils/auth_navigation.dart';
import 'package:pinput/pinput.dart';

/// User-friendly OTP verification screen designed for everyday users.
class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.phoneNumber,
    super.key,
  });

  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  Timer? _countdownTimer;
  int _secondsRemaining = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _secondsRemaining = 0;
            _canResend = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showSnack('Please enter the complete 6-digit code', isError: true);
      _otpFocusNode.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().verifyOtp(smsCode: otp);
  }

  void _handleResend() {
    if (!_canResend) return;
    _startCountdown();
    context.read<AuthCubit>().resendOtp(widget.phoneNumber);
  }

  String _formatPhoneNumber(String phone) {
    // If format is +91XXXXXXXXXX
    if (phone.startsWith('+91') && phone.length == 13) {
      return '+91 ${phone.substring(3, 8)} ${phone.substring(8)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Pin theme configurations for clear readability
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary,
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Change phone number',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verification',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) async {
            if (state is AuthSuccess) {
              _showSnack('Verification successful!');
              await checkProfileCompleteAndNavigate(context);
            } else if (state is AuthVerificationFailed) {
              _showSnack(state.error, isError: true);
              _otpController.clear();
              _otpFocusNode.requestFocus();
            } else if (state is AuthError) {
              _showSnack(state.error, isError: true);
            } else if (state is AuthCodeSent) {
              _showSnack('A new code has been sent via SMS');
            }
          },
          builder: (context, state) {
            final isVerifying = state is AuthVerifyingOtp;
            final isResending = state is AuthSendingOtp;
            final countdownStr =
                _secondsRemaining.toString().padLeft(2, '0');

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),

                          // Header Icon
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer
                                    .withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sms_outlined,
                                size: 40,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Enter 6-Digit Code',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            'We sent a text message with your '
                            'verification code to',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Phone display chip with Edit button
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatPhoneNumber(widget.phoneNumber),
                                    style:
                                        theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Edit',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // Pinput Input Area
                          Center(
                            child: Pinput(
                              length: 6,
                              controller: _otpController,
                              focusNode: _otpFocusNode,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              errorPinTheme: errorPinTheme,
                              onCompleted: (pin) => _verifyOtp(),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Verify Button
                          FilledButton(
                            onPressed: isVerifying ? null : _verifyOtp,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 1,
                            ),
                            child: isVerifying
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Verifying...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Verify & Continue',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.check_rounded, size: 20),
                                    ],
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Resend Section
                          Center(
                            child: _canResend
                                ? TextButton.icon(
                                    onPressed:
                                        isResending ? null : _handleResend,
                                    icon: isResending
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.refresh_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      isResending
                                          ? 'Sending code...'
                                          : 'Resend SMS Code',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color:
                                            colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Resend code in 0:$countdownStr',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color:
                                              colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),

                          const Spacer(),

                          // Helpful Tip Card for Laymen
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Code not arriving? Make sure your phone '
                                    'has signal and check your messages inbox.',
                                    style:
                                        theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
