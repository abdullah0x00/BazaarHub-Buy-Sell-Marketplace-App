import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../services/product_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _origPriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  
  String _selectedCategory = 'Electronics';
  bool _isFlashSale = false;
  bool _isActive = true;
  ProductModel? _product;
  bool _loading = true;

  final List<File> _newImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ProductService().getProductById(widget.productId);
    if (mounted && p != null) {
      setState(() {
        _product = p;
        _titleCtrl.text = p.title;
        _descCtrl.text = p.description;
        _priceCtrl.text = p.price.toStringAsFixed(0);
        _origPriceCtrl.text = p.originalPrice?.toStringAsFixed(0) ?? '';
        _stockCtrl.text = p.stock.toString();
        _selectedCategory = p.category;
        _isFlashSale = p.isFlashSale;
        _isActive = p.isActive;
        _loading = false;
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 70);
    if (images.isNotEmpty) {
      setState(() => _newImages.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _product == null) return;
    
    final updated = _product!.copyWith(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text),
      originalPrice: _origPriceCtrl.text.isNotEmpty ? double.parse(_origPriceCtrl.text) : null,
      stock: int.parse(_stockCtrl.text),
      category: _selectedCategory,
      isFlashSale: _isFlashSale,
      isActive: _isActive,
    );

    final success = await context.read<ProductProvider>().updateProduct(
      updated, 
      newImageFiles: _newImages,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!'), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: LoadingWidget(message: 'Loading product...'));
    }

    final isLoading = context.watch<ProductProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Product'), elevation: 0),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image Edit Section
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Product Images'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: AppColors.azureSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.azure.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.add_a_photo_outlined, color: AppColors.azure),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ..._newImages.map((f) => _ImageItem(file: f, onRemove: () => setState(() => _newImages.remove(f)))),
                          if (_product != null) 
                            ..._product!.images.map((url) => _ImageItem(url: url)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Tip: Uploading new images will replace existing ones.', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
                      controller: _titleCtrl,
                      validator: (v) => AppValidators.minLength(v, 5, fieldName: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      label: 'Description',
                      controller: _descCtrl,
                      maxLines: 4,
                      validator: (v) => AppValidators.minLength(v, 20, fieldName: 'Description'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      items: AppConstants.categories.map((c) => DropdownMenuItem(value: c['name'], child: Text('${c['icon']} ${c['name']}'))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
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
                        Expanded(child: CustomTextField(label: 'Price (PKR)', controller: _priceCtrl, keyboardType: TextInputType.number, validator: AppValidators.price)),
                        const SizedBox(width: 12),
                        Expanded(child: CustomTextField(label: 'Original Price', controller: _origPriceCtrl, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(label: 'Stock Quantity', controller: _stockCtrl, keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _ToggleRow(label: '⚡ Flash Sale', value: _isFlashSale, onChanged: (v) => setState(() => _isFlashSale = v)),
                    _ToggleRow(label: '✅ Product Active', value: _isActive, onChanged: (v) => setState(() => _isActive = v)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Update Product', isLoading: isLoading, onPressed: _save),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  final File? file;
  final String? url;
  final VoidCallback? onRemove;
  const _ImageItem({this.file, this.url, this.onRemove});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: 80, height: 80,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: file != null ? DecorationImage(image: FileImage(file!), fit: BoxFit.cover) : DecorationImage(image: NetworkImage(url!), fit: BoxFit.cover),
        ),
      ),
      if (onRemove != null)
        Positioned(top: 2, right: 12, child: GestureDetector(onTap: onRemove, child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)))),
    ],
  );
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w500)), Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary)]);
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)), child: child);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
}
