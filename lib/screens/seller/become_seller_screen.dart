import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BecomeSellerScreen extends StatefulWidget {
  const BecomeSellerScreen({super.key});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _shopNameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  int _currentStep = 0;
  bool _submitted = false;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _cnicCtrl.dispose();
    _phoneCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();

    final shopName = _shopNameCtrl.text.trim().isEmpty
        ? 'My Demo Shop'
        : _shopNameCtrl.text.trim();
    final cnic = _cnicCtrl.text.trim().isEmpty
        ? '35201-1234567-1'
        : _cnicCtrl.text.trim();
    final phone =
        _phoneCtrl.text.trim().isEmpty ? '03001234567' : _phoneCtrl.text.trim();
    final bank =
        _bankCtrl.text.trim().isEmpty ? 'HBL-12345678' : _bankCtrl.text.trim();

    final success = await auth.applyForSeller(
      shopName: shopName,
      cnic: cnic,
      phone: phone,
      bankAccount: bank,
    );

    if (mounted && success) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (_submitted || auth.isPendingSeller) {
      return _buildPendingScreen();
    }

    if (auth.isSeller) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Become a Seller'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Stepper Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Shop'),
                  _buildDivider(0),
                  _buildStepIndicator(1, 'Identity'),
                  _buildDivider(1),
                  _buildStepIndicator(2, 'Bank'),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentStep == 0) _buildShopInfo(),
                  if (_currentStep == 1) _buildIdentityInfo(),
                  if (_currentStep == 2) _buildBankInfo(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => setState(() => _currentStep--),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 52),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Back'),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _submit();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(0, 52),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _currentStep == 2
                                ? 'Submit Application'
                                : 'Continue',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isSelected = _currentStep == step;
    bool isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isSelected
                ? AppColors.primary
                : Colors.grey[300],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('${step + 1}',
                    style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDivider(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 15),
        color: _currentStep > step ? AppColors.primary : Colors.grey[300],
      ),
    );
  }

  Widget _buildShopInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shop Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Enter your business details below',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Shop Name',
          hint: 'e.g. Ahmed\'s Tech Store',
          controller: _shopNameCtrl,
          prefixIcon: const Icon(Icons.storefront_outlined),
        ),
      ],
    );
  }

  Widget _buildIdentityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Identity Verification',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('We need to verify your identity',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'CNIC Number',
          hint: '35201-1234567-1',
          controller: _cnicCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.badge_outlined),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Phone Number',
          hint: '03001234567',
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined),
        ),
      ],
    );
  }

  Widget _buildBankInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Account Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Where should we send your earnings?',
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Bank Account / IBAN',
          hint: 'e.g. HBL-1234567890',
          controller: _bankCtrl,
          prefixIcon: const Icon(Icons.account_balance_outlined),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your application will be reviewed within 24-48 hours.',
                  style: TextStyle(fontSize: 12, color: Colors.brown),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Application Status')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⏳', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              const Text(
                'Application Under Review',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your seller application has been submitted. Our team will review and approve it within 24-48 hours.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Back to Home',
                outlined: true,
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, AppRoutes.main),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
