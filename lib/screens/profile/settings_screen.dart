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
      appBar: AppBar(title: const Text('General Settings')),
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
            
            // Support
            _SettingsSection(
              title: 'Support',
              children: [
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
            
            const SizedBox(height: 32),
            Center(
              child: Text(
                'BazaarHub v1.0.0',
                style: TextStyle(
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
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textHint, letterSpacing: 0.8)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
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
  const _ToggleTile({required this.icon, required this.label, this.subtitle, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.azureSurface, radius: 18, child: Icon(icon, color: AppColors.azure, size: 18)),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
      trailing: Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(backgroundColor: AppColors.azureSurface, radius: 18, child: Icon(icon, color: AppColors.azure, size: 18)),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  const _DropdownTile({required this.icon, required this.label, required this.value, required this.options, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.azureSurface, radius: 18, child: Icon(icon, color: AppColors.azure, size: 18)),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
