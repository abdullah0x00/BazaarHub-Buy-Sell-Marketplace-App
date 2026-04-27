import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  bool _isEnabling = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isEnabled = auth.twoFactorEnabled;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Two-Factor Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isEnabled ? Colors.green.withValues(alpha: 0.1) : AppColors.azureSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isEnabled ? Icons.verified_user : Icons.security,
                size: 64,
                color: isEnabled ? Colors.green : AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isEnabled ? '2FA is Enabled' : 'Secure Your Account',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              isEnabled 
                ? 'Your account is protected with an extra layer of security. Every time you log in, we will ask for a verification code.'
                : 'Two-factor authentication adds an extra layer of security to your account. To log in, you will need to provide a code.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const Spacer(),
            CustomButton(
              text: isEnabled ? 'Disable 2FA' : 'Enable 2FA Now',
              color: isEnabled ? Colors.red : AppColors.primary,
              onPressed: () async {
                setState(() => _isEnabling = true);
                // In a real app, this would trigger an OTP flow
                await Future.delayed(const Duration(seconds: 1));
                await auth.toggleTwoFactor();
                setState(() => _isEnabling = false);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('2FA has been ${!isEnabled ? "enabled" : "disabled"}'),
                      backgroundColor: !isEnabled ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              isLoading: _isEnabling,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
