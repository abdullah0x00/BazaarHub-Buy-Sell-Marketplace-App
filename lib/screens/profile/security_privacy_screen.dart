import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class SecurityPrivacyScreen extends StatelessWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Security & Privacy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Section
            _SectionHeader(title: 'Security Protections'),
            _SecurityCard(
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

            const SizedBox(height: 24),

            // Privacy Section
            _SectionHeader(title: 'Data & Privacy'),
            _SecurityCard(
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
                  icon: Icons.lock_reset_outlined,
                  label: 'Change Password',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
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
            const SizedBox(height: 40),
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
        content: const Text('This action is permanent and cannot be undone. All your data will be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (ctx, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Privacy Policy', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'BazaarHub is committed to your privacy. We collect data only to improve your experience and process your orders safely.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textHint, letterSpacing: 1)),
  );
}

class _SecurityCard extends StatelessWidget {
  final List<Widget> children;
  const _SecurityCard({required this.children});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
    child: Column(children: children),
  );
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.label, this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(backgroundColor: AppColors.azureSurface, radius: 18, child: Icon(icon, color: AppColors.azure, size: 18)),
    title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
    trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? labelColor;
  const _ActionTile({required this.icon, required this.label, this.subtitle, required this.onTap, this.labelColor});
  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: CircleAvatar(backgroundColor: labelColor?.withValues(alpha: 0.1) ?? AppColors.azureSurface, radius: 18, child: Icon(icon, color: labelColor ?? AppColors.azure, size: 18)),
    title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: labelColor)),
    subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
    trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
  );
}
