# MVVM Migration Guide

## 📋 Overview

This guide will help you migrate your current codebase from a Controller-based architecture to a clean MVVM architecture pattern.

## 🎯 Migration Strategy

We'll migrate **one feature at a time** to minimize risk and allow testing after each step.

## ⚠️ Prerequisites

1. **Create a new branch**:
```bash
git checkout -b refactor/mvvm-migration
git push -u origin refactor/mvvm-migration
```

2. **Ensure all tests pass** (if you have tests):
```bash
flutter test
flutter analyze
```

3. **Backup your code** or commit current state:
```bash
git add .
git commit -m "chore: backup before MVVM migration"
```

---

## 📦 Phase 1: Prepare Core Structure

### Step 1.1: Create Core Directories (if needed)

These should already exist, but verify:

```bash
# Verify core structure exists
lib/core/
  ├── constants/
  ├── theme/
  ├── utils/
  └── widgets/
```

### Step 1.2: Move Shared Widgets (if needed)

Move any feature-specific widgets that should be shared to `core/widgets/`:
- Widgets used across multiple features
- Common UI components

**Action**: Check if any widgets in `common/` should be moved to `core/widgets/`.

---

## 📦 Phase 2: Migrate Authentication Feature

### Step 2.1: Rename Controllers to ViewModels

```bash
# Navigate to authentication feature
cd lib/features/authentication

# Create viewmodels directory
mkdir viewmodels
mkdir viewmodels/login
mkdir viewmodels/signup

# Move and rename files
mv controllers/login/login_controller.dart viewmodels/login/login_viewmodel.dart
mv controllers/signup/signup_controller.dart viewmodels/signup/signup_viewmodel.dart
mv controllers/signup/verify_otp_controller.dart viewmodels/signup/verify_otp_viewmodel.dart

# Remove old controllers directory
rm -rf controllers
```

### Step 2.2: Update Class Names

For each ViewModel file:

**Before** (`login_controller.dart`):
```dart
class LoginController extends GetxController {
  // ...
}
```

**After** (`login_viewmodel.dart`):
```dart
class LoginViewModel extends GetxController {
  // ...
}
```

**Files to update**:
- `viewmodels/login/login_viewmodel.dart`
- `viewmodels/signup/signup_viewmodel.dart`
- `viewmodels/signup/verify_otp_viewmodel.dart`

### Step 2.3: Rename Screens Directory (Optional)

```bash
# Optional: Rename screens to views for MVVM terminology
mv screens views
```

**Note**: You can keep `screens/` if you prefer - it's just naming.

### Step 2.4: Update Imports in Views

Find all files that import the old controllers:

```bash
# Search for old imports
grep -r "login_controller" lib/features/authentication/views/
grep -r "signup_controller" lib/features/authentication/views/
```

**Update imports**:

**Before**:
```dart
import '../../controllers/login/login_controller.dart';

final controller = Get.put(LoginController());
```

**After**:
```dart
import '../../viewmodels/login/login_viewmodel.dart';

final viewModel = Get.put(LoginViewModel());
```

### Step 2.5: Update Variable Names in Views

**Before**:
```dart
final controller = Get.put(LoginController());
// ...
controller.emailController.text
```

**After**:
```dart
final viewModel = Get.put(LoginViewModel());
// ...
viewModel.emailController.text
```

### Step 2.6: Update GeneralBinding

**File**: `lib/bindings/general_binding.dart`

**Before**:
```dart
Get.lazyPut(() => LoginController(), fenix: true);
Get.lazyPut(() => SignupController(), fenix: true);
Get.lazyPut(() => VerifyOtpController(), fenix: true);
```

**After**:
```dart
Get.lazyPut(() => LoginViewModel(), fenix: true);
Get.lazyPut(() => SignupViewModel(), fenix: true);
Get.lazyPut(() => VerifyOtpViewModel(), fenix: true);
```

**Update imports**:
```dart
import '../features/authentication/viewmodels/login/login_viewmodel.dart';
import '../features/authentication/viewmodels/signup/signup_viewmodel.dart';
import '../features/authentication/viewmodels/signup/verify_otp_viewmodel.dart';
```

### Step 2.7: Test Authentication Feature

```bash
flutter run
# Test login, signup, OTP verification
flutter analyze
```

---

## 📦 Phase 3: Migrate Shop Feature

The shop feature is the largest, so we'll do it in sub-phases.

### Step 3.1: Create ViewModels Directory Structure

```bash
cd lib/features/shop

# Create viewmodels directory
mkdir viewmodels
mkdir viewmodels/product
mkdir viewmodels/commandes

# Move all controllers to viewmodels
mv controllers/banner_controller.dart viewmodels/banner_viewmodel.dart
mv controllers/category_controller.dart viewmodels/category_viewmodel.dart
mv controllers/dashboard_controller.dart viewmodels/dashboard_viewmodel.dart
mv controllers/etablissement_controller.dart viewmodels/etablissement_viewmodel.dart
mv controllers/navigation_controller.dart viewmodels/navigation_viewmodel.dart
mv controllers/search_controller.dart viewmodels/search_viewmodel.dart
mv controllers/commandes/order_list_controller.dart viewmodels/commandes/order_list_viewmodel.dart
mv controllers/product/* viewmodels/product/

# Remove old controllers directory
rm -rf controllers
```

### Step 3.2: Rename Product Controllers

```bash
cd viewmodels/product

# Rename all files
mv all_products_controller.dart all_products_viewmodel.dart
mv checkout_controller.dart checkout_viewmodel.dart
mv favorites_controller.dart favorites_viewmodel.dart
mv horaire_controller.dart horaire_viewmodel.dart
mv images_controller.dart images_viewmodel.dart
mv order_controller.dart order_viewmodel.dart
mv panier_controller.dart panier_viewmodel.dart
mv produit_controller.dart produit_viewmodel.dart
mv variation_controller.dart variation_viewmodel.dart
```

### Step 3.3: Update Class Names in ViewModels

**Use Find & Replace** in your IDE:

**Pattern**: `class (\w+)Controller extends GetxController`
**Replace**: `class $1ViewModel extends GetxController`

**Example**:
- `ProductController` → `ProductViewModel`
- `PanierController` → `PanierViewModel`
- `NavigationController` → `NavigationViewModel`

**Files to update** (17 files):
1. `viewmodels/banner_viewmodel.dart`
2. `viewmodels/category_viewmodel.dart`
3. `viewmodels/dashboard_viewmodel.dart`
4. `viewmodels/etablissement_viewmodel.dart`
5. `viewmodels/navigation_viewmodel.dart`
6. `viewmodels/search_viewmodel.dart`
7. `viewmodels/commandes/order_list_viewmodel.dart`
8. `viewmodels/product/all_products_viewmodel.dart`
9. `viewmodels/product/checkout_viewmodel.dart`
10. `viewmodels/product/favorites_viewmodel.dart`
11. `viewmodels/product/horaire_viewmodel.dart`
12. `viewmodels/product/images_viewmodel.dart`
13. `viewmodels/product/order_viewmodel.dart`
14. `viewmodels/product/panier_viewmodel.dart`
15. `viewmodels/product/produit_viewmodel.dart`
16. `viewmodels/product/variation_viewmodel.dart`

### Step 3.4: Update Imports in Views

**Search for all controller imports**:
```bash
grep -r "_controller" lib/features/shop/screens/ | grep import
```

**Update imports** (use Find & Replace in IDE):

**Pattern**: `import.*controllers/(.+)controller\.dart`
**Replace**: `import ../viewmodels/$1viewmodel.dart`

**Manual updates needed for nested paths**:
- `controllers/product/produit_controller.dart` → `viewmodels/product/produit_viewmodel.dart`
- `controllers/commandes/order_list_controller.dart` → `viewmodels/commandes/order_list_viewmodel.dart`

### Step 3.5: Update Variable Names in Views

**Find all instances**:
```bash
grep -r "Controller()" lib/features/shop/screens/
```

**Update**:
- `Get.put(ProductController())` → `Get.put(ProductViewModel())`
- `Get.find<ProductController>()` → `Get.find<ProductViewModel>()`
- `final controller =` → `final viewModel =` (or keep `controller` if preferred)

### Step 3.6: Update GeneralBinding

**File**: `lib/bindings/general_binding.dart`

**Update all shop-related bindings**:

**Before**:
```dart
Get.lazyPut<PanierController>(() => PanierController(), fenix: true);
Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
// ... etc
```

**After**:
```dart
Get.lazyPut<PanierViewModel>(() => PanierViewModel(), fenix: true);
Get.lazyPut<CheckoutViewModel>(() => CheckoutViewModel(), fenix: true);
Get.lazyPut<OrderViewModel>(() => OrderViewModel(), fenix: true);
// ... etc
```

**Update imports**:
```dart
import '../features/shop/viewmodels/product/panier_viewmodel.dart';
import '../features/shop/viewmodels/product/checkout_viewmodel.dart';
// ... etc
```

### Step 3.7: Test Shop Feature

```bash
flutter run
# Test all shop features:
# - Product listing
# - Product details
# - Cart
# - Checkout
# - Orders
flutter analyze
```

---

## 📦 Phase 4: Migrate Personalization Feature

### Step 4.1: Create ViewModels Directory

```bash
cd lib/features/personalization

# Create viewmodels directory
mkdir viewmodels

# Move controllers
mv controllers/address_controller.dart viewmodels/address_viewmodel.dart
mv controllers/update_name_controller.dart viewmodels/update_name_viewmodel.dart
mv controllers/user_controller.dart viewmodels/user_viewmodel.dart
mv controllers/user_management_controller.dart viewmodels/user_management_viewmodel.dart

# Remove old controllers directory
rm -rf controllers
```

### Step 4.2: Update Class Names

- `AddressController` → `AddressViewModel`
- `UpdateNameController` → `UpdateNameViewModel`
- `UserController` → `UserViewModel`
- `UserManagementController` → `UserManagementViewModel`

### Step 4.3: Update Imports in Views

Same process as Phase 3.

### Step 4.4: Update GeneralBinding

Update all personalization-related bindings.

### Step 4.5: Test Personalization Feature

Test user profile, address management, etc.

---

## 📦 Phase 5: Migrate Notification Feature

### Step 5.1: Create ViewModels Directory

```bash
cd lib/features/notification

mkdir viewmodels
mv controllers/notification_controller.dart viewmodels/notification_viewmodel.dart
rm -rf controllers
```

### Step 5.2: Update Class Name

- `NotificationController` → `NotificationViewModel`

### Step 5.3: Update Imports and Test

---

## 📦 Phase 6: Global Updates

### Step 6.1: Update Navigation Menu

**File**: `lib/navigation_menu.dart`

**Before**:
```dart
import 'features/shop/controllers/navigation_controller.dart';

final controller = Get.put(NavigationController());
```

**After**:
```dart
import 'features/shop/viewmodels/navigation_viewmodel.dart';

final viewModel = Get.put(NavigationViewModel());
```

### Step 6.2: Update Main App

Check `lib/main.dart` for any controller references.

### Step 6.3: Update All Repository References

Search for repository files that reference controllers:

```bash
grep -r "Controller" lib/data/repositories/
```

Update references:
- `Get.find<UserController>()` → `Get.find<UserViewModel>()`

### Step 6.4: Final Search & Replace

**Search for any remaining "Controller" references**:

```bash
# Find all remaining controller references
grep -r "Controller" lib/ --include="*.dart" | grep -v viewmodel
```

Update as needed.

---

## 📦 Phase 7: Cleanup & Verification

### Step 7.1: Remove Old Directories

Verify all `controllers/` directories are removed:

```bash
find lib/features -type d -name "controllers" -exec echo {} \;
```

If any remain, remove them.

### Step 7.2: Update Import Paths

Ensure all imports use correct paths:
- `../controllers/` → `../viewmodels/`
- `../../controllers/` → `../../viewmodels/`

### Step 7.3: Code Analysis

```bash
flutter analyze
flutter pub get
```

### Step 7.4: Comprehensive Testing

Test all features:
- ✅ Authentication (login, signup, OTP)
- ✅ Shop (products, cart, checkout, orders)
- ✅ Personalization (profile, addresses, settings)
- ✅ Notifications
- ✅ Navigation

### Step 7.5: Update Documentation

Update any documentation that references "controllers" to "viewmodels".

---

## 🔧 Helper Scripts

### Script 1: Find All Controller References

```bash
#!/bin/bash
# find_controllers.sh

echo "Searching for controller references..."
grep -r "Controller" lib/ --include="*.dart" | grep -v "viewmodel" | grep -v "//"
```

### Script 2: Bulk Rename Pattern

```bash
#!/bin/bash
# rename_pattern.sh - Use with caution!

# This would rename all files matching pattern
# Uncomment and modify as needed

# find lib/features -name "*_controller.dart" | while read file; do
#   new_name=$(echo "$file" | sed 's/_controller\.dart/_viewmodel.dart/')
#   mv "$file" "$new_name"
# done
```

---

## ✅ Checklist

### Authentication Feature
- [ ] Controllers renamed to ViewModels
- [ ] Class names updated
- [ ] Imports updated
- [ ] Variable names updated
- [ ] GeneralBinding updated
- [ ] Tests pass

### Shop Feature
- [ ] All controllers moved to viewmodels/
- [ ] All class names updated (17 files)
- [ ] All imports updated
- [ ] GeneralBinding updated
- [ ] Tests pass

### Personalization Feature
- [ ] Controllers renamed to ViewModels
- [ ] Class names updated
- [ ] Imports updated
- [ ] Tests pass

### Notification Feature
- [ ] Controller renamed to ViewModel
- [ ] Class name updated
- [ ] Tests pass

### Global Updates
- [ ] Navigation menu updated
- [ ] Repository references updated
- [ ] No remaining "Controller" references (except in comments)
- [ ] All tests pass
- [ ] Code analysis passes

---

## 🚨 Common Issues & Solutions

### Issue 1: Import Errors

**Problem**: `import '../controllers/...'` not found

**Solution**: Update all import paths from `controllers/` to `viewmodels/`

### Issue 2: Class Not Found

**Problem**: `ProductController` not found

**Solution**: Update to `ProductViewModel` everywhere

### Issue 3: GetX Binding Errors

**Problem**: Controller not registered

**Solution**: Update `GeneralBinding` with new ViewModel names

### Issue 4: Circular Dependencies

**Problem**: ViewModel depends on another ViewModel not yet created

**Solution**: Use lazy getters (as we did with `authRepo`)

---

## 📝 Post-Migration Best Practices

1. **Naming Consistency**: Always use `*_viewmodel.dart` for ViewModels
2. **Separation**: Keep ViewModels free of Flutter UI imports
3. **Testing**: Test ViewModels independently
4. **Documentation**: Update any team documentation

---

## 🎉 Completion

Once all phases are complete:

1. Commit changes:
```bash
git add .
git commit -m "refactor: migrate to MVVM architecture"
```

2. Test thoroughly:
```bash
flutter test
flutter analyze
flutter run
```

3. Create Pull Request:
```bash
git push origin refactor/mvvm-migration
```

4. Review and merge!

---

## 📚 Additional Resources

- [GetX Documentation](https://pub.dev/packages/get)
- [MVVM Pattern Explained](https://en.wikipedia.org/wiki/Model–view–viewmodel)
- Flutter Best Practices

---

**Good luck with your migration! 🚀**

