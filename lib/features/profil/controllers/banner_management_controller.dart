import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../shop/controllers/banner_controller.dart';
import 'user_controller.dart';
import '../../shop/models/banner_model.dart';

class BannerManagementController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final BannerController bannerController = Get.find<BannerController>();
  final UserController userController = Get.find<UserController>();

  late TabController tabController;
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: bannerController.selectedTabIndex.value,
    );
    tabController.addListener(_onTabChanged);
    selectedTabIndex.value = bannerController.selectedTabIndex.value;
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      selectedTabIndex.value = tabController.index;
      bannerController.selectedTabIndex.value = tabController.index;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Getters pour les permissions
  bool get isAdmin => userController.userRole == 'Admin';
  bool get isGerant => userController.userRole == 'Gérant';
  bool get canManageBanners => isGerant;
  bool get canChangeStatus => isAdmin;

  // Getters pour les données
  bool get isLoading => bannerController.isLoading.value;
  List<BannerModel> get filteredBanners =>
      bannerController.getFilteredBannersByTab();

  // Getters pour les compteurs par statut
  int get enAttenteCount =>
      bannerController.getBannersByStatus('en_attente').length;
  int get publieeCount => bannerController.getBannersByStatus('publiee').length;
  int get refuseeCount => bannerController.getBannersByStatus('refusee').length;

  // Méthodes pour les actions
  void updateSearch(String query) {
    bannerController.updateSearch(query);
  }

  Future<void> refreshBanners() async {
    await bannerController.refreshBanners();
  }

  Future<void> updateBannerStatus(String bannerId, String newStatus) async {
    await bannerController.updateBannerStatus(bannerId, newStatus);
  }

  Future<void> deleteBanner(String bannerId) async {
    await bannerController.deleteBanner(bannerId);
  }

  void loadBannerForEditing(BannerModel banner) {
    bannerController.loadBannerForEditing(banner);
  }

  Future<void> approvePendingChanges(String bannerId) async {
    await bannerController.approvePendingChanges(bannerId);
  }

  Future<void> rejectPendingChanges(String bannerId) async {
    await bannerController.rejectPendingChanges(bannerId);
  }

  bool hasPendingChanges(BannerModel banner) {
    return bannerController.hasPendingChanges(banner);
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'publiee':
        return 'Publiée';
      case 'refusee':
        return 'Refusée';
      default:
        return 'En attente';
    }
  }

  MaterialColor getStatusColor(String status) {
    switch (status) {
      case 'publiee':
        return Colors.green;
      case 'refusee':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String getTabName(int index) {
    switch (index) {
      case 0:
        return 'En attente';
      case 1:
        return 'Publiée';
      case 2:
        return 'Refusée';
      default:
        return '';
    }
  }
}
