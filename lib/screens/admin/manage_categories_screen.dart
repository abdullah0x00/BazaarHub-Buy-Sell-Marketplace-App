import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../models/category_model.dart';
import '../../config/theme.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCategoryDialog(context),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          if (admin.isLoading && admin.categories.isEmpty) {
            return const LoadingWidget();
          }

          if (admin.categories.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.category_outlined,
              title: 'No Categories',
              subtitle: 'Add categories to help users find products.',
            );
          }

          // Separate main categories and subcategories
          final mainCategories = admin.categories.where((c) => c.parentId == null).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mainCategories.length,
            itemBuilder: (context, index) {
              final main = mainCategories[index];
              final subs = admin.categories.where((c) => c.parentId == main.id).toList();

              return _CategoryExpansionTile(
                category: main,
                subCategories: subs,
                onAddSub: () => _showCategoryDialog(context, parentId: main.id),
                onEdit: () => _showCategoryDialog(context, category: main),
                onDelete: () => _confirmDelete(context, main.id),
                onEditSub: (sub) => _showCategoryDialog(context, category: sub),
                onDeleteSub: (id) => _confirmDelete(context, id),
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? category, String? parentId}) {
    final nameCtrl = TextEditingController(text: category?.name);
    final iconCtrl = TextEditingController(text: category?.icon ?? '📦');
    final orderCtrl = TextEditingController(text: category?.order.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Mobile)')),
            const SizedBox(height: 12),
            TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Icon Emoji (e.g. 📱)')),
            const SizedBox(height: 12),
            TextField(controller: orderCtrl, decoration: const InputDecoration(labelText: 'Display Order'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              
              final admin = context.read<AdminProvider>();
              if (category == null) {
                await admin.addCategory(CategoryModel(
                  id: '',
                  name: nameCtrl.text,
                  icon: iconCtrl.text,
                  parentId: parentId,
                  order: int.tryParse(orderCtrl.text) ?? 0,
                ));
              } else {
                await admin.updateCategory(category.copyWith(
                  name: nameCtrl.text,
                  icon: iconCtrl.text,
                  order: int.tryParse(orderCtrl.text) ?? 0,
                ));
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: const Text('Are you sure? This will not delete products but they might become uncategorized.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () async {
            await context.read<AdminProvider>().deleteCategory(id);
            if (context.mounted) Navigator.pop(context);
          }, child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}

class _CategoryExpansionTile extends StatelessWidget {
  final CategoryModel category;
  final List<CategoryModel> subCategories;
  final VoidCallback onAddSub;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(CategoryModel) onEditSub;
  final Function(String) onDeleteSub;

  const _CategoryExpansionTile({
    required this.category,
    required this.subCategories,
    required this.onAddSub,
    required this.onEdit,
    required this.onDelete,
    required this.onEditSub,
    required this.onDeleteSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: ExpansionTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${subCategories.length} Sub-categories', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.blue), onPressed: onAddSub),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: onDelete),
          ],
        ),
        children: [
          if (subCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No sub-categories added yet.', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
            ),
          ...subCategories.map((sub) => ListTile(
            dense: true,
            leading: Text(sub.icon),
            title: Text(sub.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () => onEditSub(sub)),
                IconButton(icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red), onPressed: () => onDeleteSub(sub.id)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

extension CategoryModelExtension on CategoryModel {
  CategoryModel copyWith({String? name, String? icon, int? order}) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      parentId: parentId,
      order: order ?? this.order,
    );
  }
}
