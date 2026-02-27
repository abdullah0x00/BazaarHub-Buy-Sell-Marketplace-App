# 🛍️ BazaarHub — Buy & Sell Marketplace App

A **production-level Flutter marketplace app** with Blue, White & Azure theme. Built with clean architecture, Provider state management, and full feature coverage similar to Daraz / Shopify.

---

## 📱 App Screenshots Overview

| Splash | Onboarding | Home | Product Detail |
|--------|------------|------|----------------|
| Animated gradient splash | 3-step onboarding | Banner + Categories + Flash Sale | Image gallery, ratings, add to cart |

---

## ✨ Features

### 🔐 Authentication
- Register / Login / Forgot Password
- Email & password validation
- Demo admin: `admin@bazaarhub.com` / any password
- Role-based access: Buyer / Seller / Admin

### 🛒 Buyer Features
- Home screen with banner slider, categories, flash sale, recommendations
- Search with debounce and recent/trending suggestions
- Product detail page with image gallery, specs, reviews & ratings
- Add to cart, wishlist, buy now
- Cart with quantity controls and delivery fee calculator
- Multi-step checkout with multiple payment methods (UI)
- Order history with tracking simulation
- Notifications feed

### 🏪 Seller Features
- Seller application form (shop name, CNIC, phone, bank account)
- Admin approval workflow
- Seller dashboard (revenue, orders, products, quick actions)
- Add / Edit / Delete products with image URL support
- Flash sale toggle and active/inactive product status
- Order management with status updates
- Sales analytics with Bar & Line charts (fl_chart)
- Product promotion tools (UI)

### 👑 Admin Features
- Admin dashboard with platform-wide stats
- Approve / reject pending seller applications
- Manage all users (block/unblock)
- Manage all products (hide/delete)
- Platform reports modal

### ⚙️ Settings
- Dark mode toggle
- Language selector (English, Urdu, Arabic)
- Push notification toggle
- Privacy policy & Terms of Service
- Change password / Delete account

---

## 📁 Folder Structure

```
lib/
 ├── main.dart                  # Entry point
 ├── app.dart                   # Root MaterialApp
 ├── config/
 │   ├── theme.dart             # AppColors + Light/Dark themes
 │   └── routes.dart            # All named routes
 ├── models/
 │   ├── user_model.dart        # UserModel with roles
 │   ├── product_model.dart     # ProductModel with mock data
 │   ├── order_model.dart       # OrderModel + OrderItem
 │   └── review_model.dart      # ReviewModel
 ├── services/
 │   ├── auth_service.dart      # Auth CRUD (simulated)
 │   ├── product_service.dart   # Product CRUD
 │   └── order_service.dart     # Order CRUD + Analytics
 ├── providers/
 │   ├── auth_provider.dart     # Auth + settings state
 │   ├── cart_provider.dart     # Cart state
 │   └── product_provider.dart  # Products + wishlist state
 ├── screens/
 │   ├── splash_screen.dart
 │   ├── onboarding/            # 3 onboarding screens
 │   ├── auth/                  # Login, Register, Forgot Password
 │   ├── buyer/                 # Home, Details, Cart, Checkout, Orders, Wishlist, Search, etc.
 │   ├── seller/                # Dashboard, Add/Edit Product, Orders, Analytics
 │   ├── profile/               # Profile, Edit Profile, Settings
 │   └── admin/                 # Dashboard, Manage Users, Manage Products
 ├── widgets/
 │   ├── custom_button.dart
 │   ├── custom_textfield.dart
 │   ├── product_card.dart
 │   └── loading_widget.dart
 └── utils/
     ├── constants.dart
     └── validators.dart
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- An IDE (VS Code / Android Studio)

### Installation

```bash
# 1. Clone the repo
git clone https://github.com/yourname/marketplace_app.git

# 2. Navigate to project
cd marketplace_app

# 3. Install dependencies
flutter pub get

# 4. Create assets directories
mkdir -p assets/images assets/icons assets/fonts

# 5. Run the app
flutter run
```

> **Note:** The app uses placeholder network images and simulated backend — no real API key needed.

### Demo Credentials

| Role  | Email                    | Password    |
|-------|--------------------------|-------------|
| Admin | admin@bazaarhub.com      | any password |
| Seller | ahmed@gmail.com         | any password |
| Buyer | sara@gmail.com           | any password |

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `fl_chart` | Revenue & order charts |
| `shared_preferences` | Local settings & auth persistence |
| `uuid` | Unique product IDs |
| `intl` | Date formatting |
| `shimmer` | Loading skeletons |
| `image_picker` | Product image selection |
| `carousel_slider` | Banner carousel |
| `flutter_rating_bar` | Star ratings |

---

## 🏗️ Architecture

The app follows a **layered architecture**:

```
UI (Screens) ──► Providers (State) ──► Services (Business Logic) ──► Models (Data)
```

- **Models**: Pure data classes with JSON serialization
- **Services**: Simulated async API calls (replace with real HTTP/Firebase)
- **Providers**: `ChangeNotifier` classes managing UI state
- **Screens**: Stateless/Stateful widgets consuming providers
- **Widgets**: Reusable UI components

---

## 🔄 Future Improvements

- [ ] Firebase Auth + Firestore backend
- [ ] Real payment gateway (Stripe / JazzCash API)
- [ ] Push notifications (FCM)
- [ ] Real image upload (Firebase Storage / Cloudinary)
- [ ] Product video support
- [ ] Live chat (buyer-seller messaging)
- [ ] Multi-vendor shipping integration
- [ ] Ratings and reviews CRUD
- [ ] Advanced search filters (price range, rating)
- [ ] Referral & loyalty points system
- [ ] Multi-language (i18n) with proper ARB files
- [ ] CI/CD pipeline with GitHub Actions

---

## 📄 License

MIT License — Free to use for personal and commercial projects.

---

Made with ❤️ using Flutter & Dart
