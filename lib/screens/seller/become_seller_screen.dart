import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BecomeSellerScreen extends StatefulWidget {
  final int initialStep;
  const BecomeSellerScreen({super.key, this.initialStep = 0});

  @override
  State<BecomeSellerScreen> createState() => _BecomeSellerScreenState();
}

class _BecomeSellerScreenState extends State<BecomeSellerScreen> {
  final _shopNameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  late int _currentStep;
  bool _isSubmitting = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    final user = context.read<AuthProvider>().currentUser;
    
    // BONUS: Protect BecomeSellerScreen from being opened if already a seller
    if (user != null && user.isSeller == true) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
        }
      });
      return;
    }

    if (user != null) {
      _shopNameCtrl.text = user.shopName ?? '';
      _cnicCtrl.text = user.cnic ?? '';
      _phoneCtrl.text = user.phone ?? '';
      _bankCtrl.text = user.bankAccount ?? '';
      _addressCtrl.text = user.warehouseAddress ?? '';
    }
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _cnicCtrl.dispose();
    _phoneCtrl.dispose();
    _bankCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
        setState(() => _addressCtrl.text = address);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_shopNameCtrl.text.isEmpty || _cnicCtrl.text.isEmpty || _addressCtrl.text.isEmpty || _bankCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.applyForSeller(
      shopName: _shopNameCtrl.text.trim(),
      cnic: _cnicCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      bankAccount: _bankCtrl.text.trim(),
      warehouseAddress: _addressCtrl.text.trim(),
    );

    if (!mounted) return;

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Application Submitted!'),
            content: const Text('Your seller application has been sent for approval. Admin will review your details shortly.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(context, AppRoutes.main);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Seller Registration'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stepper Header
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Identity'),
                  _buildDivider(0),
                  _buildStepIndicator(1, 'Warehouse'),
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
                  if (_currentStep == 0) _buildIdentityInfo(),
                  if (_currentStep == 1) _buildWarehouseInfo(),
                  if (_currentStep == 2) _buildBankInfo(),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: CustomButton(
                            text: 'Back',
                            outlined: true,
                            onPressed: () => setState(() => _currentStep--),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: _currentStep == 2 ? 'Submit & Open Dashboard' : 'Continue',
                          isLoading: _isSubmitting,
                          onPressed: () {
                            if (_currentStep < 2) {
                              setState(() => _currentStep++);
                            } else {
                              _submit();
                            }
                          },
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
          width: 30, height: 30,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isCompleted || isSelected ? AppColors.primary : Colors.grey[300]),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('${step + 1}', style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.primary : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildDivider(int step) {
    return Expanded(
      child: Container(height: 2, margin: const EdgeInsets.only(bottom: 15), color: _currentStep > step ? AppColors.primary : Colors.grey[300]),
    );
  }

  Widget _buildIdentityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Identity & Shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        CustomTextField(label: 'Shop Name', hint: 'e.g. My Awesome Shop', controller: _shopNameCtrl),
        const SizedBox(height: 16),
        CustomTextField(label: 'CNIC Number', hint: '35201-1234567-1', controller: _cnicCtrl, keyboardType: TextInputType.number),
      ],
    );
  }

  Widget _buildWarehouseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Warehouse Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text(
          'How would you like to add your warehouse address?',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        
        // Current Location Option
        _buildLocationOption(
          icon: Icons.my_location_rounded,
          title: 'Use Current Location',
          subtitle: 'Fetch warehouse address automatically',
          color: AppColors.azure,
          onTap: _isLocating ? null : _getCurrentLocation,
          isLoading: _isLocating,
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('OR MANUALLY', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              Expanded(child: Divider()),
            ],
          ),
        ),

        CustomTextField(label: 'Complete Address', hint: 'House #, Street, City, etc.', controller: _addressCtrl, maxLines: 3),
        const SizedBox(height: 16),
        CustomTextField(label: 'Pickup Phone Number', hint: '03001234567', controller: _phoneCtrl, keyboardType: TextInputType.phone),
      ],
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBankInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bank Account Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        CustomTextField(label: 'Bank Account / IBAN', hint: 'e.g. HBL-1234567890', controller: _bankCtrl),
      ],
    );
  }
}
