import 'package:caferesto/data/repositories/notifications/notifications_repository.dart';
import 'package:caferesto/features/notification/controllers/notification_controller.dart';
import 'package:caferesto/features/profil/controllers/address_controller.dart';
import 'package:caferesto/features/profil/controllers/gerant_dashboard_controller.dart';
import 'package:caferesto/features/profil/controllers/liste_etablissement_controller.dart';
import 'package:caferesto/features/shop/controllers/commandes/order_controller.dart';
import 'package:caferesto/features/shop/controllers/product/all_products_controller.dart';
import 'package:get/get.dart';

import '../data/repositories/address/address_repository.dart';
import '../data/repositories/banner/banner_repository.dart';
import '../data/repositories/etablissement/etablissement_repository.dart';
import '../data/repositories/order/order_repository.dart';
import '../data/repositories/product/produit_repository.dart';
import '../data/repositories/user/user_repository.dart';
import '../features/authentication/controllers/otp_verification/verify_otp_controller.dart';
import '../features/profil/controllers/user_controller.dart';
import '../features/profil/controllers/user_management_controller.dart';
import '../features/shop/controllers/etablissement_controller.dart';
import '../features/shop/controllers/product/checkout_controller.dart';
import '../features/shop/controllers/product/favorites_controller.dart';
import '../features/shop/controllers/product/variation_controller.dart';
import '../features/shop/controllers/product/panier_controller.dart';
import '../features/shop/controllers/banner_controller.dart';
import '../utils/helpers/network_manager.dart';

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories d'abord
    // Note: UserRepository, UserController, and AuthenticationRepository
    // are already registered in main.dart with permanent: true
    // So we only register them here if they don't exist (shouldn't happen, but safe check)
    if (!Get.isRegistered<UserRepository>()) {
      Get.lazyPut<UserRepository>(() => UserRepository(), fenix: true);
    }
    if (!Get.isRegistered<UserController>()) {
      Get.lazyPut<UserController>(() => UserController(), fenix: true);
    }

    Get.lazyPut<ProduitRepository>(() => ProduitRepository(), fenix: true);
    Get.lazyPut<EtablissementRepository>(() => EtablissementRepository(),
        fenix: true);
    Get.lazyPut<OrderRepository>(() => OrderRepository(), fenix: true);
    Get.lazyPut<AddressRepository>(() => AddressRepository(), fenix: true);
    Get.lazyPut<BannerRepository>(() => BannerRepository(), fenix: true);

    Get.lazyPut<NotificationsRepository>(
      () => NotificationsRepository(),
      fenix: true,
    );

    Get.lazyPut<NetworkManager>(() => NetworkManager(), fenix: true);

    // Controllers d'authentification
    Get.lazyPut(() => OTPVerificationController(), fenix: true);

    Get.put<NotificationController>(NotificationController(), permanent: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    Get.lazyPut<AllProductsController>(() => AllProductsController(),
        fenix: true);
    Get.lazyPut<PanierController>(() => PanierController(), fenix: true);
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<FavoritesController>(() => FavoritesController(), fenix: true);
    Get.lazyPut<VariationController>(() => VariationController(), fenix: true);
    Get.lazyPut<UserManagementController>(() => UserManagementController(),
        fenix: true);
    Get.lazyPut<ListeEtablissementController>(
        () => ListeEtablissementController(EtablissementRepository()),
        fenix: true);
    Get.lazyPut<EtablissementController>(
        () => EtablissementController(Get.find<EtablissementRepository>()),
        fenix: true);
    Get.lazyPut<BannerController>(() => BannerController(), fenix: true);
    Get.lazyPut<GerantDashboardController>(() => GerantDashboardController(),
        fenix: true);
  }
}
