# MVVM Architecture - Folder Structure

## 📁 Complete Directory Structure

```
lib/
├── main.dart                          # Application entry point
├── app.dart                           # App configuration (GetMaterialApp)
├── navigation_menu.dart               # Main navigation widget
│
├── core/                              # Core configuration and utilities
│   ├── constants/                     # Global constants
│   │   ├── api_constants.dart
│   │   ├── colors.dart
│   │   ├── enums.dart
│   │   ├── image_strings.dart
│   │   ├── sizes.dart
│   │   └── text_strings.dart
│   │
│   ├── theme/                         # Application theme
│   │   ├── theme.dart
│   │   └── widget_themes/
│   │       ├── appbar_theme.dart
│   │       ├── bottom_sheet_theme.dart
│   │       ├── checkbox_theme.dart
│   │       ├── chip_theme.dart
│   │       ├── elevated_button_theme.dart
│   │       ├── outlined_button_theme.dart
│   │       ├── text_field_theme.dart
│   │       └── text_theme.dart
│   │
│   ├── utils/                         # General utilities
│   │   ├── device/
│   │   │   └── device_utility.dart
│   │   ├── exceptions/
│   │   │   ├── exceptions.dart
│   │   │   ├── firebase_exceptions.dart
│   │   │   ├── format_exceptions.dart
│   │   │   ├── platform_exceptions.dart
│   │   │   ├── supabase_auth_exceptions.dart
│   │   │   └── supabase_exception.dart
│   │   ├── formatters/
│   │   │   └── formatter.dart
│   │   ├── helpers/
│   │   │   ├── cloud_helper_functions.dart
│   │   │   ├── helper_functions.dart
│   │   │   ├── network_manager.dart
│   │   │   └── pricing_calculator.dart
│   │   ├── http/
│   │   │   └── http_client.dart
│   │   ├── loaders/
│   │   │   ├── animation_loader.dart
│   │   │   └── circular_loader.dart
│   │   ├── local_storage/
│   │   │   └── storage_utility.dart
│   │   ├── logging/
│   │   │   └── logger.dart
│   │   ├── popups/
│   │   │   ├── full_screen_loader.dart
│   │   │   └── loaders.dart
│   │   └── validators/
│   │       └── validation.dart
│   │
│   └── widgets/                       # Shared/reusable widgets
│       ├── appbar/
│       │   └── appbar.dart
│       ├── brands/
│       │   └── etablissement_card.dart
│       ├── categories/
│       │   └── category_card.dart
│       ├── custom_shapes/
│       │   ├── containers/
│       │   └── curved_edges/
│       ├── icons/
│       │   └── t_circular_icon.dart
│       ├── image_text_widgets/
│       │   └── vertical_image_text.dart
│       ├── images/
│       │   ├── circular_image.dart
│       │   └── t_rounded_image.dart
│       ├── layouts/
│       │   └── grid_layout.dart
│       ├── list_tiles/
│       │   ├── settings_menu_tile.dart
│       │   └── user_profile_tile.dart
│       ├── products/
│       │   ├── cart/
│       │   ├── favorite_icon/
│       │   ├── product_cards/
│       │   ├── ratings/
│       │   └── sortable/
│       ├── shimmer/
│       │   └── [shimmer widgets]
│       ├── success_screen/
│       │   └── success_screen.dart
│       └── texts/
│           └── [text widgets]
│
├── data/                              # Data layer
│   └── repositories/                  # Data access layer
│       ├── address/
│       │   └── address_repository.dart
│       ├── authentication/
│       │   └── authentication_repository.dart
│       ├── banner/
│       │   └── banner_repository.dart
│       ├── categories/
│       │   └── category_repository.dart
│       ├── etablissement/
│       │   └── etablissement_repository.dart
│       ├── horaire/
│       │   └── horaire_repository.dart
│       ├── order/
│       │   └── order_repository.dart
│       ├── product/
│       │   └── produit_repository.dart
│       └── user/
│           └── user_repository.dart
│
├── features/                          # Feature modules (MVVM)
│   │
│   ├── authentication/                # Feature: Authentication
│   │   ├── models/                    # Data models (if feature-specific)
│   │   ├── viewmodels/                # State & business logic
│   │   │   ├── login/
│   │   │   │   └── login_viewmodel.dart
│   │   │   └── signup/
│   │   │       ├── signup_viewmodel.dart
│   │   │       └── verify_otp_viewmodel.dart
│   │   ├── views/                     # UI screens
│   │   │   ├── home/
│   │   │   │   └── widgets/
│   │   │   │       └── home_categories.dart
│   │   │   ├── login/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── login_form.dart
│   │   │   │       └── login_header.dart
│   │   │   ├── signup/
│   │   │   │   ├── signup_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── [signup widgets]
│   │   │   └── splash/
│   │   │       └── splash_screen.dart
│   │   └── bindings/                  # Dependency injection (optional)
│   │       └── authentication_binding.dart
│   │
│   ├── shop/                          # Feature: Shopping
│   │   ├── models/                    # Data models
│   │   │   ├── banner_model.dart
│   │   │   ├── cart_item_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── etablissement_model.dart
│   │   │   ├── horaire_model.dart
│   │   │   ├── jour_semaine.dart
│   │   │   ├── order_model.dart
│   │   │   ├── produit_model.dart
│   │   │   ├── statut_etablissement_model.dart
│   │   │   └── taille_prix_model.dart
│   │   ├── viewmodels/                # State & business logic
│   │   │   ├── banner_viewmodel.dart
│   │   │   ├── category_viewmodel.dart
│   │   │   ├── commandes/
│   │   │   │   └── order_list_viewmodel.dart
│   │   │   ├── dashboard_viewmodel.dart
│   │   │   ├── etablissement_viewmodel.dart
│   │   │   ├── navigation_viewmodel.dart
│   │   │   ├── product/
│   │   │   │   ├── all_products_viewmodel.dart
│   │   │   │   ├── checkout_viewmodel.dart
│   │   │   │   ├── favorites_viewmodel.dart
│   │   │   │   ├── horaire_viewmodel.dart
│   │   │   │   ├── images_viewmodel.dart
│   │   │   │   ├── order_viewmodel.dart
│   │   │   │   ├── panier_viewmodel.dart
│   │   │   │   ├── produit_viewmodel.dart
│   │   │   │   └── variation_viewmodel.dart
│   │   │   └── search_viewmodel.dart
│   │   ├── views/                     # UI screens
│   │   │   ├── all_products/
│   │   │   │   └── all_products_screen.dart
│   │   │   ├── brand/
│   │   │   │   └── brand_products_screen.dart
│   │   │   ├── cart/
│   │   │   │   ├── cart_screen.dart
│   │   │   │   ├── cart_item.dart
│   │   │   │   ├── quantity_controls.dart
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── cart_appbar.dart
│   │   │   │   │   ├── cart_bottom_section.dart
│   │   │   │   │   ├── cart_header.dart
│   │   │   │   │   ├── delete_cart_bottomsheet.dart
│   │   │   │   │   ├── empty_cart_view.dart
│   │   │   │   │   └── [cart item widgets]
│   │   │   ├── categories/
│   │   │   │   └── all_categories_screen.dart
│   │   │   ├── checkout/
│   │   │   │   ├── checkout_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── billing_address_section.dart
│   │   │   │       ├── billing_amount_section.dart
│   │   │   │       └── time_slot_modal.dart
│   │   │   ├── favorite/
│   │   │   │   └── favorite_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── build_empty_state.dart
│   │   │   │       ├── home_appbar.dart
│   │   │   │       ├── promo_slider.dart
│   │   │   │       └── search_overlay.dart
│   │   │   ├── order/
│   │   │   │   ├── order_screen.dart
│   │   │   │   ├── delivery_map_screen.dart
│   │   │   │   ├── delivery_map_view.dart
│   │   │   │   ├── gerant_order_management_screen.dart
│   │   │   │   ├── order_tracking_screen.dart
│   │   │   │   ├── pick_up_slot_picker.dart
│   │   │   │   └── widgets/
│   │   │   │       └── order_list.dart
│   │   │   ├── product_details/
│   │   │   │   ├── product_detail_screen.dart
│   │   │   │   ├── product_detail_layout/
│   │   │   │   │   ├── product_detail_bottom_bar_wrapper.dart
│   │   │   │   │   ├── product_detail_desktop_layout.dart
│   │   │   │   │   ├── product_detail_image_slider.dart
│   │   │   │   │   ├── product_detail_mobile_layout.dart
│   │   │   │   │   └── product_details_content.dart
│   │   │   │   └── widgets/
│   │   │   │       └── [product detail widgets]
│   │   │   ├── product_reviews/
│   │   │   │   ├── add_produit_screen.dart
│   │   │   │   ├── list_produit_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── store/
│   │   │   │   ├── store_screen.dart
│   │   │   │   └── widgets/
│   │   │   └── sub_category/
│   │   │       └── sub_categories_screen.dart
│   │   ├── services/                  # Business logic services (optional)
│   │   │   └── arrival_time_calculator_service.dart
│   │   └── bindings/                  # Dependency injection (optional)
│   │       └── shop_binding.dart
│   │
│   ├── personalization/               # Feature: User Personalization
│   │   ├── models/
│   │   │   ├── address_model.dart
│   │   │   └── user_model.dart
│   │   ├── viewmodels/
│   │   │   ├── address_viewmodel.dart
│   │   │   ├── update_name_viewmodel.dart
│   │   │   ├── user_viewmodel.dart
│   │   │   └── user_management_viewmodel.dart
│   │   ├── views/
│   │   │   ├── address/
│   │   │   │   ├── address_screen.dart
│   │   │   │   ├── add_new_address_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       └── single_address.dart
│   │   │   ├── banners/
│   │   │   │   ├── add_banner_screen.dart
│   │   │   │   ├── banner_management_screen.dart
│   │   │   │   └── edit_banner_screen.dart
│   │   │   ├── brands/
│   │   │   │   ├── add_brand_screen.dart
│   │   │   │   ├── admin_gestion_etat_etablissement_screen.dart
│   │   │   │   ├── edit_brand_screen.dart
│   │   │   │   ├── map_picker_screen.dart
│   │   │   │   ├── mon_etablissement_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── categories/
│   │   │   │   ├── add_category_screen.dart
│   │   │   │   ├── category_manager_screen.dart
│   │   │   │   ├── edit_category_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── dashboard/
│   │   │   │   ├── admin_dashboard_screen.dart
│   │   │   │   ├── dashboard_side_menu.dart
│   │   │   │   └── gerant_dashboard_screen.dart
│   │   │   ├── etablisment/
│   │   │   │   ├── gestion_horaires_screen.dart
│   │   │   │   ├── heure_button.dart
│   │   │   │   └── horaire_tile.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── widgets/
│   │   │   ├── settings/
│   │   │   │   └── settings_screen.dart
│   │   │   ├── users/
│   │   │   │   └── admin_user_management_screen.dart
│   │   │   └── widgets/
│   │   │       └── loading_screen.dart
│   │   └── bindings/                  # Dependency injection (optional)
│   │       └── personalization_binding.dart
│   │
│   └── notification/                  # Feature: Notifications
│       ├── models/
│       │   └── notification_model.dart
│       ├── viewmodels/
│       │   └── notification_viewmodel.dart
│       ├── views/
│       │   ├── notifications_screen.dart
│       │   └── show_notifications_screen.dart
│       └── bindings/                  # Dependency injection (optional)
│           └── notification_binding.dart
│
└── bindings/                          # Global dependency injection
    └── general_binding.dart
```

## 📋 Key MVVM Structure Rules

### 1. **Feature-Based Organization**
Each feature is self-contained:
```
feature_name/
├── models/          # Feature-specific data models
├── viewmodels/      # State management & business logic
├── views/           # UI screens & widgets
├── services/        # Optional: Business logic services
└── bindings/        # Optional: Feature-specific DI
```

### 2. **Naming Conventions**

| Type | Pattern | Example |
|------|---------|---------|
| **Model** | `*_model.dart` | `product_model.dart` |
| **ViewModel** | `*_viewmodel.dart` | `product_viewmodel.dart` |
| **View** | `*_screen.dart` or `*_widget.dart` | `product_list_screen.dart` |
| **Repository** | `*_repository.dart` | `product_repository.dart` |
| **Service** | `*_service.dart` | `arrival_time_calculator_service.dart` |
| **Binding** | `*_binding.dart` | `shop_binding.dart` |

### 3. **Layer Responsibilities**

#### **MODEL**
- Pure data classes
- JSON serialization/deserialization
- No business logic
- No UI dependencies

#### **VIEWMODEL**
- State management (Rx observables)
- Business logic
- Repository communication
- Data transformation for views
- User action handling
- ❌ NO Flutter UI imports
- ❌ NO BuildContext
- ❌ NO Widget creation

#### **VIEW**
- UI rendering only
- User interaction handling (passes to ViewModel)
- Display data from ViewModel (via Obx)
- Minimal state (only UI state like scroll position)

#### **REPOSITORY**
- Data access abstraction
- API/database communication
- Data caching
- No business logic

#### **SERVICE** (Optional)
- Complex business calculations
- Cross-feature business logic
- Reusable business utilities

## 🎯 Benefits of This Structure

1. **Clear Separation**: Each layer has distinct responsibilities
2. **Testability**: ViewModels can be tested without Flutter UI
3. **Maintainability**: Easy to locate and modify code
4. **Scalability**: Easy to add new features
5. **Reusability**: ViewModels can be reused across different views
6. **Team Collaboration**: Clear structure for team members
7. **Feature Isolation**: Each feature is self-contained

## 📝 Notes

- `core/` contains shared utilities and constants
- `data/repositories/` contains all data access logic
- `features/` contains feature modules in MVVM pattern
- `bindings/` at root level is for global dependencies
- Feature-specific `bindings/` is optional for feature DI

