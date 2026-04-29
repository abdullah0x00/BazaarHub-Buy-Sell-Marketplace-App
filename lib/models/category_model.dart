class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String? parentId;
  final int order;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.parentId,
    this.order = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, String id) {
    return CategoryModel(
      id: id,
      name: json['name'] ?? '',
      icon: json['icon'] ?? '📦',
      parentId: json['parentId'],
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'icon': icon,
    'parentId': parentId,
    'order': order,
  };
}
