// 📁 lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart'; // Defines SpacingTokens.{sm,md,lg,xl}
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/l10n/generated/app_localizations.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers for the two TextFields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Track whether both fields are non-empty
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
  }

  // Recompute _canSubmit whenever either field changes
  void _validate() {
    final emailNotEmpty = _emailController.text.trim().isNotEmpty;
    final passNotEmpty = _passwordController.text.trim().isNotEmpty;
    final next = emailNotEmpty && passNotEmpty;
    if (next != _canSubmit) {
      setState(() => _canSubmit = next);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;
    final authState = ref.watch(authControllerProvider);

    // Listen for login success or error
    ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (user == null) return;
            // Determine where to route next
            final route = user.firstName.trim().isEmpty
                ? '/edit-profile?replace=true'
                : user.role == UserRole.admin
                    ? '/admin'
                    : '/tasks';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(route);
            });
          },
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.loginFailed}: $error')),
            );
          },
        );
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branding
                  const Icon(Icons.medical_services, size: 64),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'NurseOS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                  ),
                  Text(
                    l10n.loginSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.subdued,
                        ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),

                  // Email input
                  TextField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: SpacingTokens.md),

                  // Password input
                  TextField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (_canSubmit) _submit();
                    },
                  ),
                  const SizedBox(height: SpacingTokens.xl),

                  // Show loader while signing in, else show PrimaryButton
                  authState.isLoading
                      ? const AppLoader()
                      : PrimaryButton(
                          key: const Key('loginButton'),
                          label: l10n.login,
                          onPressed: _canSubmit ? _submit : null,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Reads controllers and fires the signIn() call.
  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    ref.read(authControllerProvider.notifier).signIn(email, password);
  }
}
