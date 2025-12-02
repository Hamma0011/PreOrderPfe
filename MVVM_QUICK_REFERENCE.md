# MVVM Quick Reference Guide

## 🚀 Quick Start

### Current vs MVVM Structure

| Current | MVVM | Action |
|---------|------|--------|
| `controllers/` | `viewmodels/` | Rename directory |
| `*_controller.dart` | `*_viewmodel.dart` | Rename files |
| `*Controller` | `*ViewModel` | Rename classes |
| `screens/` | `views/` or keep `screens/` | Optional rename |

---

## 📋 Naming Convention Cheat Sheet

### Files
- ✅ `product_viewmodel.dart`
- ✅ `login_viewmodel.dart`
- ✅ `cart_viewmodel.dart`
- ❌ `product_controller.dart`
- ❌ `login_controller.dart`

### Classes
- ✅ `ProductViewModel extends GetxController`
- ✅ `LoginViewModel extends GetxController`
- ❌ `ProductController extends GetxController`

### Variables
- ✅ `final viewModel = Get.put(ProductViewModel());`
- ✅ `final vm = Get.find<ProductViewModel>();`
- ❌ `final controller = Get.put(ProductController());`

---

## 📁 Standard Feature Structure

```
feature_name/
├── models/
│   └── feature_model.dart
├── viewmodels/
│   └── feature_viewmodel.dart
├── views/
│   ├── feature_screen.dart
│   └── widgets/
│       └── feature_widget.dart
└── bindings/          # Optional
    └── feature_binding.dart
```

---

## 🔄 Migration Steps (One Feature)

### 1. Create ViewModels Directory
```bash
cd lib/features/feature_name
mkdir viewmodels
mv controllers/* viewmodels/
rm -rf controllers
```

### 2. Rename Files
```bash
cd viewmodels
for file in *_controller.dart; do
  mv "$file" "${file/_controller/_viewmodel}"
done
```

### 3. Update Class Names
**Find**: `class (\w+)Controller extends GetxController`
**Replace**: `class $1ViewModel extends GetxController`

### 4. Update Imports
**Find**: `import.*controllers/(.+)_controller\.dart`
**Replace**: `import ../viewmodels/$1_viewmodel.dart`

### 5. Update Usage
**Find**: `(\w+)Controller()`
**Replace**: `$1ViewModel()`

### 6. Update GeneralBinding
```dart
// Before
Get.lazyPut(() => ProductController(), fenix: true);

// After
Get.lazyPut(() => ProductViewModel(), fenix: true);
```

---

## ✅ MVVM Rules

### ViewModel ✅ Should:
- Manage state (Rx observables)
- Handle business logic
- Communicate with repositories
- Transform data for views
- Handle user actions

### ViewModel ❌ Should NOT:
- Import Flutter UI widgets
- Use BuildContext
- Create Widgets
- Handle navigation directly (use Get.to() sparingly)

### View ✅ Should:
- Render UI only
- Observe ViewModel (via Obx)
- Pass user actions to ViewModel
- Display data from ViewModel

### View ❌ Should NOT:
- Contain business logic
- Access repositories directly
- Transform data
- Manage complex state

---

## 🔍 Common Patterns

### ViewModel Pattern
```dart
class ProductViewModel extends GetxController {
  // State
  final products = <Product>[].obs;
  final isLoading = false.obs;
  
  // Repository
  final repository = Get.find<ProductRepository>();
  
  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }
  
  // Business Logic
  Future<void> loadProducts() async {
    _isLoading.value = true;
    try {
      products.value = await repository.fetchProducts();
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }
}
```

### View Pattern
```dart
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ProductViewModel>();
    
    return Scaffold(
      body: Obx(() => viewModel.isLoading.value
        ? CircularProgressIndicator()
        : ListView.builder(
            itemCount: viewModel.products.length,
            itemBuilder: (context, index) {
              final product = viewModel.products[index];
              return ProductCard(product: product);
            },
          ),
      ),
    );
  }
}
```

---

## 📝 Import Examples

### ViewModel Import in View
```dart
import '../viewmodels/product_viewmodel.dart';
```

### Repository Import in ViewModel
```dart
import '../../../data/repositories/product/produit_repository.dart';
```

### Model Import in ViewModel
```dart
import '../models/produit_model.dart';
```

---

## 🔧 Find & Replace Commands

### Find All Controllers
```bash
grep -r "Controller" lib/ --include="*.dart" | grep class
```

### Find All Controller Imports
```bash
grep -r "_controller" lib/ --include="*.dart" | grep import
```

### Find All Controller Usage
```bash
grep -r "Controller()" lib/ --include="*.dart"
```

---

## ⚠️ Important Notes

1. **Gradual Migration**: Migrate one feature at a time
2. **Test After Each**: Test after migrating each feature
3. **Keep It Simple**: Don't over-engineer
4. **Consistency**: Maintain consistent naming throughout
5. **Documentation**: Update documentation as you go

---

## 🆘 Quick Troubleshooting

| Issue | Solution |
|-------|----------|
| Import not found | Update path from `controllers/` to `viewmodels/` |
| Class not found | Rename `*Controller` to `*ViewModel` |
| GetX binding error | Update `GeneralBinding` with new class names |
| Circular dependency | Use lazy getters instead of constructor initialization |

---

## 📚 Related Files

- `MVVM_FOLDER_STRUCTURE.md` - Complete folder structure
- `MVVM_MIGRATION_GUIDE.md` - Detailed migration steps

---

**Happy Migrating! 🚀**

