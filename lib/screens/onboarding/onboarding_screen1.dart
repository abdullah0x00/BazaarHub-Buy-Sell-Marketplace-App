import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

/// Reusable onboarding page layout
class _OnboardingBase extends StatelessWidget {
  final int pageIndex;
  final String emoji;
  final String title;
  final String subtitle;
  final bool isLast;
  final VoidCallback? onNext;

  const _OnboardingBase({
    required this.pageIndex,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.isLast = false,
    this.onNext,
  });

  Future<void> _markDoneAndNavigate(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: AppConstants.animFast,
                        margin: const EdgeInsets.only(right: 6),
                        width: i == pageIndex ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == pageIndex
                              ? AppColors.primary
                              : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _markDoneAndNavigate(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.azureSurface,
                        AppColors.primary.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 110),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 36),
              isLast
                  ? CustomButton(
                      text: 'Get Started 🚀',
                      onPressed: () => _markDoneAndNavigate(context),
                    )
                  : CustomButton(text: 'Next', onPressed: onNext),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});
  @override
  Widget build(BuildContext context) => _OnboardingBase(
        pageIndex: 0,
        emoji: '🛒',
        title: 'Shop Thousands\nof Products',
        subtitle:
            'Discover millions of items from trusted sellers. Get the best deals on electronics, fashion, home & more.',
        onNext: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding2),
      );
}

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});
  @override
  Widget build(BuildContext context) => _OnboardingBase(
        pageIndex: 1,
        emoji: '💰',
        title: 'Sell Anything\nWith Ease',
        subtitle:
            'Turn unused items into cash. List products in minutes, reach thousands of buyers, and get paid fast.',
        onNext: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.onboarding3),
      );
}

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});
  @override
  Widget build(BuildContext context) => const _OnboardingBase(
        pageIndex: 2,
        emoji: '🚀',
        title: 'Fast & Secure\nDelivery',
        subtitle:
            'Track orders in real-time. Enjoy secure payments, buyer protection, and lightning-fast delivery.',
        isLast: true,
      );
}
