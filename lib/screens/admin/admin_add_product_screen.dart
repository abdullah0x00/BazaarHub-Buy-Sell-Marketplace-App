import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AdminAddProductScreen extends StatefulWidget {
  final ProductModel? product; // If provided, we are editing
  const AdminAddProductScreen({super.key, this.product});

  @override
  State<AdminAddProductScreen> createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _origPriceCtrl;
  late final TextEditingController _stockCtrl;
  
  String _selectedCategory = 'Electronics';
  bool _isFlashSale = false;
  bool _isActive = true;
  
  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.product?.title ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.price.toStringAsFixed(0) ?? '');
    _origPriceCtrl = TextEditingController(text: widget.product?.originalPrice?.toStringAsFixed(0) ?? '');
    _stockCtrl = TextEditingController(text: widget.product?.stock.toString() ?? '');
    
    if (_isEditing) {
      _selectedCategory = widget.product!.category;
      _isFlashSale = widget.product!.isFlashSale;
      _isActive = widget.product!.isActive;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_isEditing && _newImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image')),
      );
      return;
    }

    final admin = context.read<AdminProvider>();
    
    final product = ProductModel(
      id: _isEditing ? widget.product!.id : const Uuid().v4(),
      sellerId: _isEditing ? widget.product!.sellerId : 'admin_hub',
      sellerName: _isEditing ? widget.product!.sellerName : 'BazaarHub Admin',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      originalPrice: _origPriceCtrl.text.isNotEmpty ? double.parse(_origPriceCtrl.text) : null,
      images: _isEditing ? widget.product!.images : [], // Images handled in provider
      category: _selectedCategory,
      stock: int.parse(_stockCtrl.text),
      isFlashSale: _isFlashSale,
      isActive: _isActive,
      createdAt: _isEditing ? widget.product!.createdAt : DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await admin.updateProduct(product, newImages: _newImages);
    } else {
      success = await admin.addProduct(product, _newImages);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product ${_isEditing ? "updated" : "added"} successfully!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(admin.error ?? 'Operation failed'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AdminProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add New Product'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Picker Section
              const Text('Product Images', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.azureSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.azure.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.add_a_photo, color: AppColors.azure),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ..._newImages.map((f) => Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(image: FileImage(f), fit: BoxFit.cover),
                      ),
                    )),
                    if (_isEditing) ...widget.product!.images.map((url) => Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              CustomTextField(
                label: 'Product Title',
                controller: _titleCtrl,
                validator: (v) => AppValidators.minLength(v, 5),
              ),
              const SizedBox(height: 16),
              
              CustomTextField(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 4,
                validator: (v) => AppValidators.minLength(v, 20),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Price (PKR)',
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      validator: AppValidators.price,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      label: 'Stock',
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                items: AppConstants.categories.map((c) => DropdownMenuItem(
                  value: c['name'], 
                  child: Text('${c['icon']} ${c['name']}')
                )).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 24),
              
              SwitchListTile(
                title: const Text('Is Flash Sale?'),
                value: _isFlashSale, 
                onChanged: (v) => setState(() => _isFlashSale = v),
                activeThumbColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('Is Active?'),
                value: _isActive, 
                onChanged: (v) => setState(() => _isActive = v),
                activeThumbColor: AppColors.primary,
              ),
              
              const SizedBox(height: 32),
              CustomButton(
                text: _isEditing ? 'Update Product' : 'Publish Product',
                isLoading: isLoading,
                onPressed: _save,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
