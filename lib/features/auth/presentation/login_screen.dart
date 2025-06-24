import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/core/models/user_role.dart';
import 'package:nurseos_v3/features/auth/state/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final authState = ref.watch(authControllerProvider);
    debugPrint('[LoginScreen] authState status: $authState');

    // 🔁 Listen to auth changes and redirect on successful login
    ref.listen<AsyncValue<UserModel?>>(
      authControllerProvider,
      (previous, next) {
        next.whenOrNull(
          data: (user) {
            if (user == null) return;

            // ✅ Update default post-login route
            final route = user.role == UserRole.admin ? '/admin' : '/tasks';

            // ⏳ Schedule redirect after build frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(route);
            });
          },
          error: (e, _) {
            // ❗ Show login failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed: $e')),
            );
          },
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // 🔃 Show spinner or login button
            authState.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();
                      ref
                          .read(authControllerProvider.notifier)
                          .signIn(email, password);
                    },
                    child: const Text('Log in'),
                  ),
          ],
        ),
      ),
    );
  }
}
