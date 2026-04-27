import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController(
    text: 'House 12, Street 5, DHA Phase 2, Lahore',
  );
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  String _selectedPayment = 'Cash on Delivery';
  bool _isPlacingOrder = false;
  bool _isLocating = false;
  bool _orderPlaced = false;
  String _orderId = '';

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameCtrl.text = user.name;
      _phoneCtrl.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
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

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    if (auth.currentUser == null) return;

    setState(() => _isPlacingOrder = true);

    try {
      final order = await OrderService().placeOrder(
        buyerId: auth.currentUser!.id,
        buyerName: auth.currentUser!.name,
        cartItems: cart.toOrderItems(),
        paymentMethod: _selectedPayment,
        shippingAddress: _addressCtrl.text,
        deliveryFee: cart.deliveryFee,
      );
      cart.clearCart();
      if (mounted) {
        setState(() {
          _orderPlaced = true;
          _orderId = order.id;
          _isPlacingOrder = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (_orderPlaced) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Info
              _Section(
                title: 'Delivery Information',
                icon: Icons.location_on_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Full Name', _nameCtrl, Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildField(
                      'Phone Number',
                      _phoneCtrl,
                      Icons.phone_outlined,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationOption(
                      icon: Icons.my_location_rounded,
                      title: 'Use Current Location',
                      onTap: _isLocating ? null : _getCurrentLocation,
                      isLoading: _isLocating,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('OR', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),
                    ),
                    _buildField(
                      'Complete Address',
                      _addressCtrl,
                      Icons.home_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Payment Method
              _Section(
                title: 'Payment Method',
                icon: Icons.payment_outlined,
                child: Column(
                  children: [
                    _buildPaymentTile(
                      'Cash on Delivery',
                      'Pay when you receive your order',
                      'https://cdn-icons-png.flaticon.com/512/1554/1554401.png',
                    ),
                    _buildPaymentTile(
                      'JazzCash',
                      'Pay via JazzCash Wallet',
                      'https://upload.wikimedia.org/wikipedia/commons/d/d1/JazzCash_logo.png',
                    ),
                    _buildPaymentTile(
                      'EasyPaisa',
                      'Pay via EasyPaisa Wallet',
                      'https://seeklogo.com/images/E/easypaisa-logo-0D68069502-seeklogo.com.png',
                    ),
                    _buildPaymentTile(
                      'Credit / Debit Card',
                      'Visa, MasterCard, PayPak',
                      'https://cdn-icons-png.flaticon.com/512/349/349221.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Order Summary
              _Section(
                title: 'Order Summary',
                icon: Icons.receipt_outlined,
                child: Column(
                  children: [
                    ...cart.cartList.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '×${item.quantity}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.textHint,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PKR ${_fmt(item.subtotal)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Fee',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          cart.deliveryFee == 0
                              ? 'FREE'
                              : 'PKR ${_fmt(cart.deliveryFee)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: cart.deliveryFee == 0
                                ? AppColors.success
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'PKR ${_fmt(cart.total)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payment', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  Text(
                    'PKR ${_fmt(cart.total)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Confirm Order',
                isLoading: _isPlacingOrder,
                onPressed: _placeOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textHint),
      ),
      validator: (v) => v == null || v.isEmpty ? '$label is required' : null,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 50)),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your order $_orderId has been placed successfully. You\'ll receive a confirmation shortly.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Track Order',
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.orderHistory,
                    (r) => r.settings.name == AppRoutes.main,
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Continue Shopping',
                  outlined: true,
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.main,
                    (r) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    return v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  Widget _buildPaymentTile(String method, String subtitle, String iconUrl) {
    bool isSelected = _selectedPayment == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: Image.network(
                iconUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.payment, color: AppColors.textHint),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.azure.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            isLoading 
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.azure))
              : Icon(icon, color: AppColors.azure, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.azure,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
