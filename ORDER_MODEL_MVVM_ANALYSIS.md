# OrderModel MVVM Analysis & Refactoring Guide

## 📋 Summary

The `OrderModel` class contains **intrusive code** that violates MVVM principles. According to your project's MVVM guidelines, models should be:
- ✅ Pure data classes
- ✅ JSON serialization/deserialization only
- ❌ **NO business logic**
- ❌ **NO formatting logic**
- ❌ **NO UI dependencies**

---

## 🔴 Issues Found

### 1. **Formatting Logic** (Lines 52-56, 259)
**Violation**: Models should not contain formatting logic for UI display.

**Code to Move:**
```dart
// Lines 52-56
String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);
String get formattedDeliveryDate => deliveryDate != null
    ? THelperFunctions.getFormattedDate(deliveryDate!)
    : '';

// Line 259
String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} DT';
```

**Where to Move:**
- **Option 1 (Recommended)**: Create an extension file `lib/features/shop/extensions/order_model_extension.dart`
- **Option 2**: Move to ViewModel (OrderController/OrderViewModel) as getter methods
- **Option 3**: Add to existing `THelperFunctions` class

**Recommended Solution:**
```dart
// lib/features/shop/extensions/order_model_extension.dart
import 'package:caferesto/features/shop/models/order_model.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';

extension OrderModelDisplayExtension on OrderModel {
  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);
  
  String get formattedDeliveryDate => deliveryDate != null
      ? THelperFunctions.getFormattedDate(deliveryDate!)
      : '';
  
  String get formattedTotalAmount => '${totalAmount.toStringAsFixed(2)} DT';
}
```

---

### 2. **Business Logic - Status Text** (Lines 58-73)
**Violation**: Business logic for converting enum to display text belongs in ViewModel or extension.

**Code to Move:**
```dart
String get orderStatusText {
  switch (status) {
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.preparing:
      return 'En préparation';
    case OrderStatus.ready:
      return 'Prête';
    case OrderStatus.pending:
      return 'En attente';
    case OrderStatus.cancelled:
      return 'Annulée';
    case OrderStatus.refused:
      return 'Refusée';
  }
}
```

**Where to Move:**
- **Option 1 (Recommended)**: Add to the extension file above
- **Option 2**: Move to ViewModel (OrderController/OrderViewModel)
- **Option 3**: Create a separate `OrderStatusExtension` for `OrderStatus` enum

**Recommended Solution:**
Add to `order_model_extension.dart`:
```dart
String get orderStatusText {
  switch (status) {
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.preparing:
      return 'En préparation';
    case OrderStatus.ready:
      return 'Prête';
    case OrderStatus.pending:
      return 'En attente';
    case OrderStatus.cancelled:
      return 'Annulée';
    case OrderStatus.refused:
      return 'Refusée';
  }
}
```

---

### 3. **Business Logic - State Checks** (Lines 76-91)
**Violation**: Business rules about order state should be in ViewModel.

**Code to Move:**
```dart
// Line 76
bool get canBeModified => status == OrderStatus.pending;

// Line 79
bool get canBeCancelled => status == OrderStatus.pending;

// Lines 82-85
bool get isActive =>
    status == OrderStatus.pending ||
    status == OrderStatus.preparing ||
    status == OrderStatus.ready;

// Lines 88-91
bool get isCompleted =>
    status == OrderStatus.delivered ||
    status == OrderStatus.cancelled ||
    status == OrderStatus.refused;
```

**Where to Move:**
- **Option 1 (Recommended)**: Add to the extension file (if these are simple getters based on status)
- **Option 2**: Move to ViewModel if they involve more complex business rules
- **Note**: These are simple status checks, so extension is acceptable

**Recommended Solution:**
Add to `order_model_extension.dart`:
```dart
bool get canBeModified => status == OrderStatus.pending;
bool get canBeCancelled => status == OrderStatus.pending;
bool get isActive =>
    status == OrderStatus.pending ||
    status == OrderStatus.preparing ||
    status == OrderStatus.ready;
bool get isCompleted =>
    status == OrderStatus.delivered ||
    status == OrderStatus.cancelled ||
    status == OrderStatus.refused;
```

---

### 4. **Complex Business Logic** (Lines 263-284)
**Violation**: Complex business logic that processes data should be in ViewModel or Service.

**Code to Move:**
```dart
String get establishmentNameFromItems {
  if (items.isEmpty) {
    return etablissement?.name ?? 'LiteWait';
  }

  // Compter les occurrences de chaque nom d'établissement
  final Map<String, int> establishmentCounts = {};
  for (final item in items) {
    final name = item.brandName ?? 'Inconnu';
    establishmentCounts[name] = (establishmentCounts[name] ?? 0) + 1;
  }

  // Retourner le nom le plus fréquent
  if (establishmentCounts.isEmpty) {
    return etablissement?.name ?? 'LiteWait';
  }

  final mostFrequent = establishmentCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b);
  
  return mostFrequent.key;
}
```

**Where to Move:**
- **Option 1 (Recommended)**: Move to ViewModel (OrderController/OrderViewModel) as a method
- **Option 2**: Create a service `OrderDisplayService` if this logic is reused
- **Option 3**: Add to extension if you want to keep it as a getter (less ideal for complex logic)

**Recommended Solution:**
Move to `lib/features/shop/controllers/product/order_controller.dart` (or future ViewModel):
```dart
// In OrderController class
String getEstablishmentNameFromItems(OrderModel order) {
  if (order.items.isEmpty) {
    return order.etablissement?.name ?? 'LiteWait';
  }

  final Map<String, int> establishmentCounts = {};
  for (final item in order.items) {
    final name = item.brandName ?? 'Inconnu';
    establishmentCounts[name] = (establishmentCounts[name] ?? 0) + 1;
  }

  if (establishmentCounts.isEmpty) {
    return order.etablissement?.name ?? 'LiteWait';
  }

  final mostFrequent = establishmentCounts.entries
      .reduce((a, b) => a.value > b.value ? a : b);
  
  return mostFrequent.key;
}
```

---

### 5. **Helper Methods** (Lines 246-253, 256)
**Violation**: Some helper methods contain business logic.

**Code to Review:**
```dart
// Lines 246-248
bool belongsToUser(String userId) {
  return this.userId == userId;
}

// Lines 251-253
bool belongsToEstablishment(String etablissementId) {
  return this.etablissementId == etablissementId;
}

// Line 256
int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
```

**Where to Move:**
- **`belongsToUser` & `belongsToEstablishment`**: These are simple comparisons - **KEEP in model** (acceptable)
- **`itemCount`**: Simple calculation - **KEEP in model** (acceptable) OR move to extension

**Recommendation:**
- Keep `belongsToUser` and `belongsToEstablishment` in model (they're simple property checks)
- Move `itemCount` to extension if you want consistency, but it's acceptable in model

---

## ✅ Code That Should STAY in Model

These are acceptable for a model class:
- ✅ All properties (lines 10-29)
- ✅ Constructor (lines 30-50)
- ✅ `copyWith` method (lines 97-141) - standard for immutable models
- ✅ `toJson` and `fromJson` (lines 148-229) - serialization
- ✅ `_parseStatus` helper (lines 214-229) - parsing helper for deserialization
- ✅ `OrderModel.empty()` factory (lines 231-243) - factory method
- ✅ `operator ==`, `hashCode`, `toString` (lines 286-298) - standard Dart methods
- ✅ `belongsToUser` and `belongsToEstablishment` (lines 246-253) - simple property checks

---

## 📁 Recommended File Structure

After refactoring, you should have:

```
lib/features/shop/
├── models/
│   └── order_model.dart          # Pure data class only
├── extensions/                    # NEW: Create this directory
│   └── order_model_extension.dart # Display/formatting logic
├── controllers/ (or viewmodels/)
│   └── product/
│       └── order_controller.dart  # Business logic methods
└── services/                      # Optional: For complex reusable logic
    └── order_display_service.dart
```

---

## 🎯 Action Items

1. **Create Extension File**: `lib/features/shop/extensions/order_model_extension.dart`
   - Move formatting logic (formattedOrderDate, formattedDeliveryDate, formattedTotalAmount)
   - Move status text conversion (orderStatusText)
   - Move state checks (canBeModified, canBeCancelled, isActive, isCompleted)
   - Optionally move itemCount

2. **Update OrderController/ViewModel**: 
   - Add `getEstablishmentNameFromItems()` method
   - Or create a service if logic is complex/reusable

3. **Update All Usages**:
   - Add import: `import 'package:caferesto/features/shop/extensions/order_model_extension.dart';`
   - No code changes needed (extensions work transparently)

4. **Remove from Model**:
   - Delete lines 52-91 (formatting & business logic)
   - Delete lines 246-284 (helper methods - move as needed)

---

## 📝 Notes

- Extensions are a good middle ground: they keep display logic separate from the model but maintain the convenient getter syntax
- If your project migrates to ViewModels (from Controllers), move complex business logic there
- Keep the model as a pure data class for better testability and maintainability

