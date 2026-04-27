import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance
            _SettingsSection(
              title: 'Appearance',
              children: [
                _ToggleTile(
                  icon: Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  subtitle: 'Switch between light and dark theme',
                  value: auth.isDarkMode,
                  onChanged: (_) => auth.toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Notifications
            _SettingsSection(
              title: 'Notifications',
              children: [
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  label: 'Push Notifications',
                  subtitle: 'Receive order updates and offers',
                  value: auth.notificationsEnabled,
                  onChanged: (_) => auth.toggleNotifications(),
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Notification Preferences',
                  subtitle: 'Manage which notifications you receive',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Language
            _SettingsSection(
              title: 'Language & Region',
              children: [
                _DropdownTile(
                  icon: Icons.language,
                  label: 'Language',
                  value: auth.selectedLanguage,
                  options: const ['English', 'Urdu', 'Arabic'],
                  onChanged: (v) => auth.setLanguage(v ?? 'English'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Security
            _SettingsSection(
              title: 'Security',
              children: [
                _ActionTile(
                  icon: Icons.security_outlined,
                  label: 'Two-Factor Authentication',
                  subtitle: auth.twoFactorEnabled ? 'Enabled' : 'Disabled',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.twoFactor),
                ),
                const Divider(height: 1, indent: 56),
                _ToggleTile(
                  icon: Icons.fingerprint_rounded,
                  label: 'Biometric Lock',
                  subtitle: 'Unlock with fingerprint or face ID',
                  value: auth.biometricEnabled,
                  onChanged: (_) async {
                    final success = await auth.toggleBiometric();
                    if (!success && auth.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.error),
                      );
                      auth.clearError();
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.devices_outlined,
                  label: 'Trusted Devices',
                  subtitle: 'Manage devices where you are logged in',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.trustedDevices),
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.history_rounded,
                  label: 'Login History',
                  subtitle: 'See recent login activity',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.loginHistory),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Privacy & Support
            _SettingsSection(
              title: 'Privacy & Support',
              children: [
                _ActionTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.feedback_outlined,
                  label: 'Send Feedback',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Account
            _SettingsSection(
              title: 'Account',
              children: [
                _ActionTile(
                  icon: Icons.lock_reset_outlined,
                  label: 'Change Password',
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                ),
                const Divider(height: 1, indent: 56),
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete Account',
                  labelColor: AppColors.error,
                  onTap: () => _confirmDeleteAccount(context, auth),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // App version
            const Center(
              child: Text(
                'BazaarHub v1.0.0 • Made with ❤️',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, including order history and shop details, will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Mock deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested. Our team will contact you.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showWIP(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This feature is coming soon!')),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'BazaarHub collects and uses your personal data to provide and improve our services. '
              'We are committed to protecting your privacy and being transparent about how we use your data.\n\n'
              '1. Information We Collect\nWe collect information you provide directly, such as name, email, phone number, and payment details.\n\n'
              '2. How We Use It\nWe use your data to process orders, provide customer support, and send relevant notifications.\n\n'
              '3. Data Sharing\nWe do not sell your personal data to third parties. We may share data with trusted partners to provide services.\n\n'
              '4. Your Rights\nYou have the right to access, modify, or delete your personal data at any time.\n\n'
              '5. Contact Us\nFor privacy concerns, contact privacy@bazaarhub.com',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textHint,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.azureSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.azure, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textHint,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? labelColor;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: labelColor != null
              ? labelColor!.withValues(alpha: 0.1)
              : AppColors.azureSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: labelColor ?? AppColors.azure,
          size: 18,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: labelColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textHint,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textHint,
        size: 18,
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.azureSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.azure, size: 18),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: AppColors.primary,
        ),
        items: options
            .map(
              (o) => DropdownMenuItem(
                value: o,
                child: Text(o),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
