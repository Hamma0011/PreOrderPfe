import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_stats_model.dart';

class GerantDashboardController extends GetxController {
  final DashboardController dashboardController = Get.find<DashboardController>();

  // État de présentation
  final selectedPeriod = '30'.obs;
  final useCustomDateRange = false.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  // Getters pour les données
  bool get isLoading => dashboardController.isLoading;
  DashboardStats? get stats => dashboardController.stats.value;

  @override
  void onInit() {
    super.onInit();
    // Synchroniser avec DashboardController si nécessaire
    selectedPeriod.value = dashboardController.selectedPeriod.value;
    useCustomDateRange.value = dashboardController.useCustomDateRange.value;
    startDate.value = dashboardController.startDate.value;
    endDate.value = dashboardController.endDate.value;
  }

  // Actions de présentation
  void updatePeriod(String period) {
    selectedPeriod.value = period;
    useCustomDateRange.value = false;
    startDate.value = null;
    endDate.value = null;
    dashboardController.updatePeriod(period);
  }

  void updateCustomDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      useCustomDateRange.value = true;
      startDate.value = start;
      endDate.value = end;
      dashboardController.updateCustomDateRange(start, end);
    }
  }

  void clearCustomDateRange() {
    useCustomDateRange.value = false;
    startDate.value = null;
    endDate.value = null;
    dashboardController.clearCustomDateRange();
  }

  void refreshStats() {
    dashboardController.loadDashboardStats();
  }

  // Logique de formatage et calculs pour la présentation
  String getPeriodDropdownValue() {
    return useCustomDateRange.value ? 'custom' : selectedPeriod.value;
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatRevenue(double revenue) {
    return '${revenue.toStringAsFixed(2)} DT';
  }

  double calculatePercentage(int count, int total) {
    return total > 0 ? (count / total * 100) : 0.0;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFC107); // Colors.amber
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Logique de layout responsive
  int getCrossAxisCount(double maxWidth) {
    if (maxWidth > 1200) return 4;
    if (maxWidth > 800) return 3;
    if (maxWidth > 600) return 2;
    return 1;
  }

  double getChildAspectRatio(double maxWidth) {
    if (maxWidth > 1200) return 3.5;
    if (maxWidth > 800) return 2.8;
    if (maxWidth > 600) return 2.5;
    if (maxWidth > 400) return 3.2;
    return 3.5;
  }

  Map<String, double> getCardSizes(double maxWidth) {
    if (maxWidth > 1200) {
      return {
        'iconSize': 16.0,
        'valueFontSize': 14.0,
        'titleFontSize': 10.0,
        'horizontalPadding': 8.0,
        'verticalPadding': 4.0,
      };
    } else if (maxWidth > 800) {
      return {
        'iconSize': 16.0,
        'valueFontSize': 14.0,
        'titleFontSize': 10.0,
        'horizontalPadding': 8.0,
        'verticalPadding': 4.0,
      };
    } else if (maxWidth > 600) {
      return {
        'iconSize': 18.0,
        'valueFontSize': 16.0,
        'titleFontSize': 11.0,
        'horizontalPadding': 8.0,
        'verticalPadding': 4.0,
      };
    } else if (maxWidth > 400) {
      return {
        'iconSize': 20.0,
        'valueFontSize': 18.0,
        'titleFontSize': 12.0,
        'horizontalPadding': 8.0,
        'verticalPadding': 4.0,
      };
    } else {
      return {
        'iconSize': 18.0,
        'valueFontSize': 16.0,
        'titleFontSize': 11.0,
        'horizontalPadding': 4.0,
        'verticalPadding': 2.0,
      };
    }
  }

  bool shouldShowSidebar(double maxWidth) {
    return maxWidth >= 900;
  }

  bool isDesktopLayout(double maxWidth) {
    return maxWidth > 800;
  }
}