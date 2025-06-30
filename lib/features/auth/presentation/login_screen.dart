// 📁 lib/features/auth/presentation/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';
import 'package:nurseos_v3/l10n/generated/app_localizations.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart'; // ✅

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validate);
    _passwordController.addListener(_validate);
  }

  void _validate() {
    final isValid = _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
    if (isValid != _canSubmit) {
      setState(() => _canSubmit = isValid);
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
    final l10n = AppLocalizations.of(context)!; // ✅
    final authState = ref.watch(authControllerProvider);
    final colors = Theme.of(context).extension<AppColors>()!;
    //final scaler = MediaQuery.textScalerOf(context);  **FIXME**

    ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (prev, next) {
        next.whenOrNull(
          data: (user) {
            if (user == null) return;
            final route = user.firstName.trim().isEmpty
                ? '/edit-profile?replace=true'
                : user.role == UserRole.admin
                    ? '/admin'
                    : '/tasks';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go(route);
            });
          },
          error: (e, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${l10n.loginFailed}: $e')),
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
                  TextField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  TextField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: SpacingTokens.xl),
                  authState.isLoading
                      ? const AppLoader()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            key: const Key('loginButton'),
                            onPressed: _canSubmit
                                ? () {
                                    final email = _emailController.text.trim();
                                    final password =
                                        _passwordController.text.trim();
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .signIn(email, password);
                                  }
                                : null,
                            child: Text(l10n.login),
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
