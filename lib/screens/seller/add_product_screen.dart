import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  String _selectedCategory = 'Electronics';
  bool _isFlashSale = false;
  
  final List<File> _pickedFiles = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Select Multiple from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == ImageSource.camera) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        setState(() => _pickedFiles.add(File(image.path)));
      }
    } else if (source == ImageSource.gallery) {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
      if (images.isNotEmpty) {
        setState(() => _pickedFiles.addAll(images.map((x) => File(x.path))));
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product image'), backgroundColor: AppColors.warning),
      );
      return;
    }

    setState(() => _isUploading = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final productProvider = context.read<ProductProvider>();
    
    try {
      final auth = context.read<AuthProvider>();
      
      // 1. Create product model (images will be set by provider after upload)
      final product = ProductModel(
        id: const Uuid().v4(),
        sellerId: auth.currentUser!.id,
        sellerName: auth.currentUser!.shopName ?? auth.currentUser!.name,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        originalPrice: _origPriceCtrl.text.isNotEmpty ? double.parse(_origPriceCtrl.text) : null,
        images: [], // Handled by provider
        category: _selectedCategory,
        stock: int.parse(_stockCtrl.text),
        isFlashSale: _isFlashSale,
        createdAt: DateTime.now(),
      );

      // 2. Save to provider (passes files for Cloudinary upload)
      final success = await productProvider.addProduct(product, _pickedFiles);
      
      if (success) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Product added successfully!'), backgroundColor: AppColors.success),
        );
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(productProvider.error ?? 'Failed to add product'), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final bool isLoading = productProvider.isLoading || _isUploading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add New Product')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Product Images'),
                    const SizedBox(height: 12),
                    
                    // Image Picker Area
                    Row(
                      children: [
                        GestureDetector(
                          onTap: isLoading ? null : _pickImage,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.azureSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.azure.withValues(alpha: 0.3), style: BorderStyle.solid),
                            ),
                            child: const Icon(Icons.add_a_photo_outlined, color: AppColors.azure),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pickedFiles.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (ctx, i) => Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _pickedFiles[i],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _pickedFiles.removeAt(i)),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Tip: Tap the icon to add real photos of your product.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Basic Information'),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Product Title',
                      hint: 'e.g. iPhone 15 Pro Max 256GB',
                      controller: _titleCtrl,
                      validator: (v) => AppValidators.minLength(v, 5, fieldName: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      hint: 'Describe your product in detail...',
                      controller: _descCtrl,
                      maxLines: 4,
                      validator: (v) => AppValidators.minLength(v, 20, fieldName: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppColors.textPrimary),
                          items: AppConstants.categories.map((c) => DropdownMenuItem(value: c['name'], child: Text('${c['icon']} ${c['name']}', style: const TextStyle(fontFamily: 'Poppins')))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Pricing & Stock'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Price (PKR)',
                            hint: '10000',
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            validator: AppValidators.price,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Original Price',
                            hint: 'Optional',
                            controller: _origPriceCtrl,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Stock Quantity',
                      hint: 'e.g. 50',
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Stock is required';
                        if (int.tryParse(v) == null || int.parse(v) < 0) return 'Enter valid stock';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('⚡ Include in Flash Sale', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                        Switch(value: _isFlashSale, onChanged: (v) => setState(() => _isFlashSale = v), activeThumbColor: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Publish Product',
                isLoading: isLoading,
                onPressed: _save,
                icon: Icons.upload_rounded,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
        child: child,
      );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
}
