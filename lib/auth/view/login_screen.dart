import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myalien/app/constants/app_strings.dart';
import 'package:myalien/app/view/brand_logo.dart';
import 'package:myalien/auth/cubit/auth_cubit.dart';
import 'package:myalien/auth/cubit/auth_state.dart';
import 'package:myalien/auth/utils/auth_navigation.dart';
import 'package:myalien/auth/view/otp_screen.dart';
import 'package:myalien/auth/view/terms_and_privacy_sheet.dart';

/// User-friendly login screen designed for everyday users.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_onPhoneChanged)
      ..dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_validationError != null) {
      setState(() {
        _validationError = null;
      });
    } else {
      setState(() {});
    }
  }

  String _cleanPhoneNumber(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      digits = digits.substring(2);
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return digits;
  }

  void _handleSendOtp() {
    final rawInput = _phoneController.text.trim();
    final cleanDigits = _cleanPhoneNumber(rawInput);

    if (cleanDigits.length != 10) {
      setState(() {
        _validationError = 'Please enter your 10-digit mobile number';
      });
      _phoneFocusNode.requestFocus();
      return;
    }

    if (_phoneController.text != cleanDigits) {
      _phoneController.value = TextEditingValue(
        text: cleanDigits,
        selection: TextSelection.collapsed(offset: cleanDigits.length),
      );
    }

    final formattedPhone = '+91$cleanDigits';
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().sendOtp(formattedPhone);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) async {
              if (state is AuthCodeSent) {
                await Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => BlocProvider.value(
                      value: context.read<AuthCubit>(),
                      child: OtpScreen(phoneNumber: state.phoneNumber),
                    ),
                  ),
                );
              } else if (state is AuthVerificationFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.error)),
                      ],
                    ),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              } else if (state is AuthSuccess) {
                await checkProfileCompleteAndNavigate(context);
              }
            },
            builder: (context, state) {
              final isSending = state is AuthSendingOtp;

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
                            const Spacer(),

                            // Hero Branding
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface.withValues(
                                    alpha: 0.6,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const BrandLogo(size: 96),
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              AppStrings.welcomeToMyAlien,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'Log in or register with your mobile number to get started.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Value Proposition Hero Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildValuePill(
                                    icon: Icons.coffee_rounded,
                                    label: 'Cafe Meetups',
                                    color: colorScheme.primary,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: colorScheme.primary.withValues(alpha: 0.25),
                                  ),
                                  _buildValuePill(
                                    icon: Icons.verified_user_rounded,
                                    label: 'Escrow Safe',
                                    color: const Color(0xFF10B981),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 20,
                                    color: colorScheme.primary.withValues(alpha: 0.25),
                                  ),
                                  _buildValuePill(
                                    icon: Icons.stars_rounded,
                                    label: 'Earn & Sponsor',
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Phone Number Card
                            Card(
                              elevation: 4,
                              shadowColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Mobile Number',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _validationError != null
                                              ? colorScheme.error
                                              : colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .surfaceContainerHighest
                                                  .withValues(alpha: 0.3),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      15,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      15,
                                                    ),
                                                  ),
                                            ),
                                            child: const Text(
                                              '🇮🇳 +91',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 1,
                                            height: 32,
                                            color: colorScheme.outlineVariant,
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _phoneController,
                                              focusNode: _phoneFocusNode,
                                              keyboardType: TextInputType.phone,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onSubmitted: (_) =>
                                                  _handleSendOtp(),
                                              maxLength: 10,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    letterSpacing: 1.5,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                              decoration: const InputDecoration(
                                                counterText: '',
                                                hintText: '98765 43210',
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_validationError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          _validationError!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Send OTP Button
                            FilledButton(
                              onPressed: isSending ? null : _handleSendOtp,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 2,
                              ),
                              child: isSending
                                  ? const CircularProgressIndicator.adaptive()
                                  : const Text(
                                      'Get Verification Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),

                            // Security Footer
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 14,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Quick & secure login • No password required',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            Text.rich(
                              TextSpan(
                                text: AppStrings.byContinuingPrefix,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                                children: [
                                  TextSpan(
                                    text: AppStrings.termsOfService,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        TermsAndPrivacySheet.show(
                                          context,
                                        );
                                      },
                                  ),
                                  const TextSpan(text: AppStrings.andSeparator),
                                  TextSpan(
                                    text: AppStrings.privacyPolicy,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        TermsAndPrivacySheet.show(
                                          context,
                                          isPrivacyPolicy: true,
                                        );
                                      },
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const Spacer(),

                            // Copyright & App Version (Pinned to bottom center)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                AppStrings.copyrightAllRightsReserved,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.5),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildValuePill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
