import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/app_state.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/services/api_exception.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — shows the settings menu dialog
// ─────────────────────────────────────────────────────────────────────────────
void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => const _SettingsMenuDialog(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Menu — two option cards
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsMenuDialog extends StatelessWidget {
  const _SettingsMenuDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings_outlined,
                      color: AppTheme.primaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Manage your account and access',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      size: 18, color: AppTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Change Password option ─────────────────
            _SettingsOption(
              icon: Icons.lock_reset_outlined,
              iconColor: AppTheme.primary,
              iconBg: AppTheme.primary.withOpacity(0.08),
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => const _ChangePasswordDialog(),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Add Admin option ───────────────────────
            _SettingsOption(
              icon: Icons.admin_panel_settings_outlined,
              iconColor: AppTheme.accent,
              iconBg: AppTheme.accent.withOpacity(0.08),
              title: 'Add Admin',
              subtitle: 'Grant admin access to a user',
              badge: 'Admin only',
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (_) => const _AddAdminDialog(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable option card
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.accent.withOpacity(0.3)),
                            ),
                            child: Text(
                              badge!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppTheme.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Change Password Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final message = await context.read<AppState>().changePassword(
        _currentController.text.trim(),
        _newController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(greenSnackbar(message));
      }
    } catch (e) {
        if (mounted) {
          final msg = e is ApiException
              ? e.message
              : e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context)
              .showSnackBar(redSnackbar(msg));
        }
      } 
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _DialogHeader(
                icon: Icons.lock_reset_outlined,
                iconColor: AppTheme.primary,
                iconBg: AppTheme.primary.withOpacity(0.08),
                title: 'Change Password',
                subtitle: 'Enter your current and new password',
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 24),

              AppTextField(
                label: 'Current Password',
                hint: '••••••••',
                controller: _currentController,
                obscureText: _obscureCurrent,
                autofillHints: const [],
                prefix: const Icon(Icons.lock_outline,
                    size: 18, color: AppTheme.textTertiary),
                suffix: _eyeIcon(_obscureCurrent,
                    () => setState(() => _obscureCurrent = !_obscureCurrent)),
                  validator: (v) {
                  if (v == null || v.isEmpty) return 'Current password is required';
                  if (v.length < 4) return 'Current Password too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'New Password',
                hint: '••••••••',
                controller: _newController,
                obscureText: _obscureNew,
                autofillHints: const [],
                prefix: const Icon(Icons.lock_outline,
                    size: 18, color: AppTheme.textTertiary),
                suffix: _eyeIcon(_obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'New password is required';
                  if (v.length < 4) return 'New Password too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Confirm New Password',
                hint: '••••••••',
                controller: _confirmController,
                obscureText: _obscureConfirm,
                autofillHints: const [],
                prefix: const Icon(Icons.lock_outline,
                    size: 18, color: AppTheme.textTertiary),
                suffix: _eyeIcon(
                    _obscureConfirm,
                    () => setState(
                        () => _obscureConfirm = !_obscureConfirm)),
                validator: (v) {
                  if (v == null || v.isEmpty)
                    return 'Please confirm your password';
                  if (v != _newController.text)
                    return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              _DialogActions(
                confirmLabel: 'Update Password',
                confirmIcon: Icons.check_rounded,
                confirmColor: AppTheme.primary,
                isLoading: _isLoading,
                onCancel: () => Navigator.of(context).pop(),
                onConfirm: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _eyeIcon(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
        color: AppTheme.textTertiary,
      ),
      onPressed: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Admin Dialog
// ─────────────────────────────────────────────────────────────────────────────
class _AddAdminDialog extends StatefulWidget {
  const _AddAdminDialog();

  @override
  State<_AddAdminDialog> createState() => _AddAdminDialogState();
}

class _AddAdminDialogState extends State<_AddAdminDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final message = await context.read<AppState>().addAdmin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(greenSnackbar(message));
      }
    } catch (e) {
        if (mounted) {
          final msg = e is ApiException
              ? e.message
              : e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context)
              .showSnackBar(redSnackbar(msg));
        }
      }
    finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DialogHeader(
                icon: Icons.admin_panel_settings_outlined,
                iconColor: AppTheme.accent,
                iconBg: AppTheme.accent.withOpacity(0.08),
                title: 'Add Admin',
                subtitle: 'Create a new admin account',
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 16),

              // Info banner — backend restricts this to admins only
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 15, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Only existing admins can successfully create new admin accounts.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.warning,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              AppTextField(
                label: 'Username',
                hint: 'e.g. john_admin',
                controller: _usernameController,
                autofillHints: const [],
                prefix: const Icon(Icons.person_outline,
                    size: 18, color: AppTheme.textTertiary),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Username is required';
                  if (v.trim().length < 4) return 'Username Must be at least 4 characters';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              AppTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [],
                prefix: const Icon(Icons.lock_outline,
                    size: 18, color: AppTheme.textTertiary),
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppTheme.textTertiary,
                  ),
                  onPressed: () => setState(
                      () => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Password is required';
                  if (v.trim().length < 4) return 'Password Must be at least 4 characters';
                  return null;
                },
              ),
              const SizedBox(height: 28),

              _DialogActions(
                confirmLabel: 'Create Admin',
                confirmIcon: Icons.admin_panel_settings_outlined,
                confirmColor: AppTheme.accent,
                isLoading: _isLoading,
                onCancel: () => Navigator.of(context).pop(),
                onConfirm: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared dialog header
// ─────────────────────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onClose;

  const _DialogHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  )),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close,
              size: 18, color: AppTheme.textSecondary),
          onPressed: onClose,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared dialog action buttons
// ─────────────────────────────────────────────────────────────────────────────
class _DialogActions extends StatelessWidget {
  final String confirmLabel;
  final IconData confirmIcon;
  final Color confirmColor;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _DialogActions({
    required this.confirmLabel,
    required this.confirmIcon,
    required this.confirmColor,
    required this.isLoading,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: AppTheme.border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onConfirm,
            icon: isLoading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(confirmIcon, size: 16),
            label: Text(confirmLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Snackbar helpers
// ─────────────────────────────────────────────────────────────────────────────
// SnackBar _greenSnackbar(String message) => SnackBar(
//       content: Row(
//         children: [
//           const Icon(Icons.check_circle_outline,
//               color: Colors.white, size: 16),
//           const SizedBox(width: 8),
//           Expanded(child: Text(message)),
//         ],
//       ),
//       backgroundColor: AppTheme.success,
//       behavior: SnackBarBehavior.floating,
//       width: 360,
//       duration: const Duration(seconds: 4),
//     );

// SnackBar _redSnackbar(String message) => SnackBar(
//       content: Row(
//         children: [
//           const Icon(Icons.error_outline, color: Colors.white, size: 16),
//           const SizedBox(width: 8),
//           Expanded(child: Text(message)),
//         ],
//       ),
//       backgroundColor: AppTheme.error,
//       behavior: SnackBarBehavior.floating,
//       width: 360,
//       duration: const Duration(seconds: 6),
//     );
