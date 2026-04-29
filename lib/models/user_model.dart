/// User model representing both buyers and sellers
enum UserRole { buyer, seller, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final UserRole role;
  final bool isApprovedSeller;
  final bool isBlocked;
  final String? shopName;
  final String? cnic;
  final String? bankAccount;
  final String? warehouseAddress;
  final String? shippingAddress;
  final List<String> completedOnboardingSteps;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = UserRole.buyer,
    this.isApprovedSeller = false,
    this.isBlocked = false,
    this.shopName,
    this.cnic,
    this.bankAccount,
    this.warehouseAddress,
    this.shippingAddress,
    this.completedOnboardingSteps = const [],
    required this.createdAt,
  });

  /// Check if user has completed all seller registration steps
  bool get hasCompletedSellerRegistration => 
    (shopName?.isNotEmpty ?? false) && 
    (cnic?.isNotEmpty ?? false) && 
    (bankAccount?.isNotEmpty ?? false) && 
    (warehouseAddress?.isNotEmpty ?? false);

  /// Check if user is a seller (Role + Approval + Registration)
  bool get isSeller => role == UserRole.seller && isApprovedSeller && hasCompletedSellerRegistration;

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    UserRole? role,
    bool? isApprovedSeller,
    bool? isBlocked,
    String? shopName,
    String? cnic,
    String? bankAccount,
    String? warehouseAddress,
    String? shippingAddress,
    List<String>? completedOnboardingSteps,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isApprovedSeller: isApprovedSeller ?? this.isApprovedSeller,
      isBlocked: isBlocked ?? this.isBlocked,
      shopName: shopName ?? this.shopName,
      cnic: cnic ?? this.cnic,
      bankAccount: bankAccount ?? this.bankAccount,
      warehouseAddress: warehouseAddress ?? this.warehouseAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      completedOnboardingSteps: completedOnboardingSteps ?? this.completedOnboardingSteps,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role.name,
      'isApprovedSeller': isApprovedSeller,
      'isBlocked': isBlocked,
      'shopName': shopName,
      'cnic': cnic,
      'bankAccount': bankAccount,
      'warehouseAddress': warehouseAddress,
      'shippingAddress': shippingAddress,
      'completedOnboardingSteps': completedOnboardingSteps,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.buyer,
      ),
      isApprovedSeller: json['isApprovedSeller'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      shopName: json['shopName'],
      cnic: json['cnic'],
      bankAccount: json['bankAccount'],
      warehouseAddress: json['warehouseAddress'],
      shippingAddress: json['shippingAddress'],
      completedOnboardingSteps: List<String>.from(json['completedOnboardingSteps'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Sample mock users for demo
  static List<UserModel> mockUsers() {
    return [
      UserModel(
        id: 'admin_1',
        name: 'Super Admin',
        email: 'admin@bazaarhub.com', // Admin specific email
        role: UserRole.admin,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      UserModel(
        id: 'seller_1',
        name: 'Ahmed Khan',
        email: 'ahmed@gmail.com',
        phone: '03001234567',
        role: UserRole.seller,
        isApprovedSeller: true,
        shopName: 'Ahmed\'s Tech Store',
        cnic: '35201-1234567-1',
        bankAccount: 'PK12 HBL 0000 1234 5678 90',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      UserModel(
        id: 'seller_2',
        name: 'Fatima Zahra',
        email: 'fatima@organic.pk',
        phone: '03125556677',
        role: UserRole.seller,
        isApprovedSeller: false, // Pending
        shopName: 'Green Farm Organics',
        cnic: '35202-9876543-2',
        bankAccount: 'PK44 MEZN 0011 2233 4455 66',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      UserModel(
        id: 'seller_3',
        name: 'Bilal Motors',
        email: 'bilal@motors.com',
        phone: '03334455667',
        role: UserRole.seller,
        isApprovedSeller: false, // Pending
        shopName: 'Bilal Premium Wheels',
        cnic: '32101-5554433-1',
        bankAccount: 'PK55 BAHL 9988 7766 5544 33',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserModel(
        id: 'buyer_1',
        name: 'Sara Ali',
        email: 'sara@gmail.com',
        phone: '03211234567',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserModel(
        id: 'buyer_2',
        name: 'Zeeshan Malik',
        email: 'zeeshan@outlook.com',
        phone: '03009988776',
        isBlocked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserModel(
        id: 'buyer_3',
        name: 'Ayesha Khan',
        email: 'ayesha.k@yahoo.com',
        phone: '03112233445',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      UserModel(
        id: 'buyer_4',
        name: 'Umar Farooq',
        email: 'umar.f@proton.me',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      UserModel(
        id: 'buyer_5',
        name: 'Hina Pervez',
        email: 'hina@gmail.com',
        phone: '03445566778',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserModel(
        id: 'buyer_6',
        name: 'Kashif Mehmood',
        email: 'kashif.m@gmail.com',
        phone: '03001122334',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      UserModel(
        id: 'buyer_7',
        name: 'Mariam Sultan',
        email: 'mariam@outlook.com',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      UserModel(
        id: 'seller_4',
        name: 'Ali Furniture',
        email: 'ali@furniture.com',
        role: UserRole.seller,
        isApprovedSeller: false,
        shopName: 'Modern Home Decor',
        cnic: '35201-7766554-3',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }
}
