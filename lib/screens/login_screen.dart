import 'package:flutter/material.dart';

import '../widgets/gradient_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final card = theme.cardColor.withOpacity(0.95);

    InputDecoration _input(String hint, {IconData? icon}) => InputDecoration(
      hintText: hint,
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: onSurface.withOpacity(0.6)),
      filled: true,
      fillColor: theme.cardColor.withOpacity(0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primary.withOpacity(0.35), width: 1.5),
      ),
    );

    Widget _ghostIcon(IconData icon) => Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 22, color: onSurface),
    );

    Widget _loginButton() => GestureDetector(
      onTap: () {}, // UI only
      child: Stack(
        alignment: Alignment.center,
        children: [
          // gradient halo ring
          Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: SweepGradient(
                colors: [
                  primary.withOpacity(0.18),
                  primary.withOpacity(0.06),
                  primary.withOpacity(0.18),
                ],
              ),
            ),
          ),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: primary.withOpacity(0.18), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Sign in',
              style: theme.textTheme.titleMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Title
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.nights_stay_rounded,
                          color: primary,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sound Sleep',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: _input(
                            'Email',
                            icon: Icons.alternate_email_rounded,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          decoration:
                              _input(
                                'Password',
                                icon: Icons.lock_outline_rounded,
                              ).copyWith(
                                suffixIcon: Icon(
                                  Icons.visibility_off_rounded,
                                  color: onSurface.withOpacity(0.6),
                                ),
                              ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot password?',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: onSurface.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _loginButton(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Or divider
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'or',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: theme.dividerColor.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Social login ghost buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_ghostIcon(Icons.g_mobiledata_rounded)],
                  ),

                  const SizedBox(height: 16),

                  // Footer text
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/signup'),
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
