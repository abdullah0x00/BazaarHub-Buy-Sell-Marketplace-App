import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
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
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    // Upload image first if a new one was picked
    if (_pickedImage != null) {
      final success = await auth.updateProfilePicture(_pickedImage!);
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Failed to upload image'),
            backgroundColor: AppColors.error,
          ),
        );
        return; // Stop saving if image upload fails
      }
    }

    // Get updated user (might have new avatar URL)
    final updatedUser = auth.currentUser!;
    final updated = updatedUser.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    
    final success = await auth.updateProfile(updated);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: auth.isLoading ? null : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 3),
                        ),
                        child: ClipOval(
                          child: _pickedImage != null
                              ? Image.file(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                  width: 110,
                                  height: 110,
                                )
                              : user?.avatar != null && user!.avatar!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.avatar!,
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                      errorWidget: (context, url, error) => _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: auth.isLoading 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      validator: (v) =>
                          AppValidators.minLength(v, 3, fieldName: 'Name'),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Email Address',
                      initialValue: auth.currentUser?.email,
                      readOnly: true,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      suffixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textHint,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v != null && v.isNotEmpty
                              ? AppValidators.phone(v)
                              : null,
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                isLoading: auth.isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.azureSurface,
      child: Center(
        child: Text(
          _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
