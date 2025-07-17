// 📁 lib/features/admin/widgets/user_switcher_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nurseos_v3/core/theme/spacing.dart';
import 'package:nurseos_v3/core/theme/app_colors.dart';
import 'package:nurseos_v3/features/auth/models/user_model.dart';
import 'package:nurseos_v3/shared/widgets/app_loader.dart';
import 'package:nurseos_v3/shared/widgets/buttons/primary_button.dart';
import 'package:nurseos_v3/test_utils/user_switcher_service.dart';

class UserSwitcherDialog extends ConsumerStatefulWidget {
  const UserSwitcherDialog({super.key});

  @override
  ConsumerState<UserSwitcherDialog> createState() => _UserSwitcherDialogState();
}

class _UserSwitcherDialogState extends ConsumerState<UserSwitcherDialog> {
  List<UserModel>? _users;
  bool _isLoading = true;
  String? _error;
  UserModel? _selectedUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userSwitcher = ref.read(userSwitcherServiceProvider);
      final users = await userSwitcher.getAllTestUsers();

      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _switchUser() async {
    if (_selectedUser == null) return;

    try {
      final userSwitcher = ref.read(userSwitcherServiceProvider);
      await userSwitcher.switchToUser(_selectedUser!);

      if (mounted) {
        Navigator.of(context).pop();

        // Navigate to appropriate screen based on role
        final route = _selectedUser!.role.name == 'admin' ? '/admin' : '/tasks';
        context.go(route);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Switched to ${_selectedUser!.firstName} ${_selectedUser!.lastName} (${_selectedUser!.role.name})',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final currentUser = ref.read(userSwitcherServiceProvider).getCurrentUser();

    return AlertDialog(
      title: const Text('🔄 Switch Test User'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current user indicator
            if (currentUser != null) ...[
              Container(
                padding: const EdgeInsets.all(SpacingTokens.sm),
                decoration: BoxDecoration(
                  color: colors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, color: colors.brandPrimary, size: 16),
                    const SizedBox(width: SpacingTokens.xs),
                    Text(
                      'Current: ${currentUser.firstName} ${currentUser.lastName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.brandPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentUser.role.name.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
            ],

            // Loading state
            if (_isLoading) ...[
              const Expanded(
                child: Center(child: AppLoader()),
              ),
            ]
            // Error state
            else if (_error != null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: colors.danger, size: 48),
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        'Failed to load users',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.danger,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subdued,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ]
            // User list
            else if (_users != null) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: _users!.length,
                  itemBuilder: (context, index) {
                    final user = _users![index];
                    final isSelected = _selectedUser?.uid == user.uid;
                    final isCurrent = currentUser?.uid == user.uid;

                    return Card(
                      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
                      color: isSelected
                          ? colors.brandPrimary.withOpacity(0.1)
                          : colors.surfaceVariant,
                      child: ListTile(
                        title: Text(
                          '${user.firstName} ${user.lastName}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color:
                                isCurrent ? colors.brandPrimary : colors.text,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.email,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.subdued,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingTokens.xs,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role.name),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    user.role.name.toUpperCase(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (user.department != null) ...[
                                  const SizedBox(width: SpacingTokens.xs),
                                  Text(
                                    '• ${user.department}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.subdued,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                                if (isCurrent) ...[
                                  const Spacer(),
                                  Icon(
                                    Icons.radio_button_checked,
                                    color: colors.brandPrimary,
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        selected: isSelected,
                        onTap: isCurrent
                            ? null
                            : () {
                                setState(() {
                                  _selectedUser = user;
                                });
                              },
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: colors.brandPrimary)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        PrimaryButton(
          label: 'Switch User',
          onPressed: _selectedUser != null ? _switchUser : null,
          icon: const Icon(Icons.swap_horiz, size: 16),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.purple;
      case 'chargenurse':
        return Colors.orange;
      case 'nurse':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
