import 'package:caferesto/features/profil/controllers/liste_etablissement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/order/order_repository.dart';
import '../models/dashboard_stats_model.dart';
import 'user_controller.dart';
import '../../../utils/popups/loaders.dart';

class DashboardController extends GetxController {
  final _db = Supabase.instance.client;
  final userController = Get.find<UserController>();
  final etablissementController = Get.find<ListeEtablissementController>();

  // Getter pour OrderRepository pour éviter l'erreur de lazyPut
  OrderRepository get orderRepository {
    try {
      return Get.find<OrderRepository>();
    } catch (e) {
      // Si OrderRepository n'est pas trouvé, le créer
      return Get.put(OrderRepository(), permanent: true);
    }
  }

  final _isLoading = false.obs;
  final stats = Rxn<DashboardStats>();
  final selectedPeriod = '30'.obs; // 7, 30, 90 jours
  final useCustomDateRange =
      false.obs; // Utiliser une plage de dates personnalisée
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();
  final selectedEtablissementId = Rxn<String>(); // ID de l'établissement sélectionné pour le filtre (Admin uniquement)
  final etablissements = <Map<String, dynamic>>[].obs; // Liste des établissements pour le filtre
  final revenuePeriodFilter = '7days'.obs; // Filtre de période pour les revenus: '7days', 'month', '3months', 'year', 'all'

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    // Charger la liste des établissements si admin
    if (userController.userRole == 'Admin') {
      _loadEtablissements();
    }
    loadDashboardStats();
  }

  /// Charge la liste des établissements pour le filtre (Admin uniquement)
  Future<void> _loadEtablissements() async {
    try {
      final etablissementsResponse = await _db
          .from('etablissements')
          .select('id, name')
          .order('name', ascending: true);
      
      etablissements.value = (etablissementsResponse as List)
          .map((e) => {
                'id': e['id']?.toString() ?? '',
                'name': e['name']?.toString() ?? 'Inconnu',
              })
          .toList();
    } catch (e) {
      debugPrint('Erreur chargement établissements pour filtre: $e');
      etablissements.value = [];
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      _isLoading.value = true;
      final userRole = userController.userRole;
      final userId = userController.user.value.id;

      if (userRole == 'Admin') {
        await _loadAdminStats();
      } else if (userRole == 'Gérant') {
        await _loadGerantStats(userId);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors du chargement des statistiques: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadAdminStats() async {
    try {
      // Statistiques globales pour Admin
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);
      
      // Récupérer l'ID de l'établissement sélectionné pour le filtre
      final etablissementIdFilter = selectedEtablissementId.value;

      // Déterminer la plage de dates pour le filtre
      List allOrders;
      if (useCustomDateRange.value &&
          startDate.value != null &&
          endDate.value != null) {
        final filterStartDate = DateTime(
          startDate.value!.year,
          startDate.value!.month,
          startDate.value!.day,
        );
        final filterEndDate = DateTime(
          endDate.value!.year,
          endDate.value!.month,
          endDate.value!.day,
          23,
          59,
          59,
        );

        // Toutes les commandes avec filtre de dates
        var allOrdersQuery = _db
            .from('orders')
            .select('*, etablissement:etablissement_id(*)')
            .gte('created_at', filterStartDate.toIso8601String())
            .lte('created_at', filterEndDate.toIso8601String());
        
        // Ajouter le filtre par établissement si sélectionné
        if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
          allOrdersQuery = allOrdersQuery.eq('etablissement_id', etablissementIdFilter);
        }
        
        final allOrdersResponse = await allOrdersQuery.order('created_at', ascending: false);
        allOrders = allOrdersResponse as List;
      } else {
        // Toutes les commandes sans filtre de dates personnalisé
        var allOrdersQuery = _db
            .from('orders')
            .select('*, etablissement:etablissement_id(*)');
        
        // Ajouter le filtre par établissement si sélectionné
        if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
          allOrdersQuery = allOrdersQuery.eq('etablissement_id', etablissementIdFilter);
        }
        
        final allOrdersResponse = await allOrdersQuery.order('created_at', ascending: false);
        allOrders = allOrdersResponse as List;
      }

      // Commandes du jour (basées sur created_at pour le comptage)
      var todayOrdersQuery = _db
          .from('orders')
          .select('*')
          .gte('created_at', todayStart.toIso8601String());
      if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
        todayOrdersQuery = todayOrdersQuery.eq('etablissement_id', etablissementIdFilter);
      }
      final todayOrdersResponse = await todayOrdersQuery;

      // Commandes du mois (basées sur created_at pour le comptage)
      var monthOrdersQuery = _db
          .from('orders')
          .select('*')
          .gte('created_at', monthStart.toIso8601String());
      if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
        monthOrdersQuery = monthOrdersQuery.eq('etablissement_id', etablissementIdFilter);
      }
      final monthOrdersResponse = await monthOrdersQuery;

      // Commandes livrées aujourd'hui (basées sur delivery_date pour le revenu)
      var todayDeliveredOrdersQuery = _db
          .from('orders')
          .select('*')
          .eq('status', 'delivered')
          .not('delivery_date', 'is', null)
          .gte('delivery_date', todayStart.toIso8601String())
          .lt(
              'delivery_date',
              DateTime(now.year, now.month, now.day, 23, 59, 59)
                  .toIso8601String());
      if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
        todayDeliveredOrdersQuery = todayDeliveredOrdersQuery.eq('etablissement_id', etablissementIdFilter);
      }
      final todayDeliveredOrdersResponse = await todayDeliveredOrdersQuery;

      final todayOrders = todayOrdersResponse as List;
      final monthOrders = monthOrdersResponse as List;
      final todayDeliveredOrders = todayDeliveredOrdersResponse as List;

      // Calculs des statistiques
      final totalOrders = allOrders.length;
      final ordersToday = todayOrders.length;
      final ordersThisMonth = monthOrders.length;

      final pendingOrders =
          allOrders.where((o) => o['status'] == 'pending').length;
      final activeOrders = allOrders
          .where((o) => ['preparing', 'ready'].contains(o['status']))
          .length;
      final completedOrders =
          allOrders.where((o) => o['status'] == 'delivered').length;

      final totalRevenue = allOrders
          .where((o) => ['delivered', 'ready'].contains(o['status']))
          .fold<double>(
              0.0,
              (sum, o) =>
                  sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));

      // Revenu d'aujourd'hui basé sur delivery_date (seulement les commandes livrées aujourd'hui)
      final todayRevenue = todayDeliveredOrders.fold<double>(0.0,
          (sum, o) => sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));
      final monthlyRevenue = monthOrders
          .where((o) => ['delivered', 'ready'].contains(o['status']))
          .fold<double>(
              0.0,
              (sum, o) =>
                  sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));

      final averageOrderValue =
          completedOrders > 0 ? totalRevenue / completedOrders : 0.0;

      // Statistiques des établissements (toujours global, pas de filtre)
      final etablissementsResponse =
          await _db.from('etablissements').select('id');
      final totalEtablissements = (etablissementsResponse as List).length;

      // Statistiques des produits (filtrer par établissement si sélectionné)
      var productsQuery = _db
          .from('produits')
          .select('id, quantite_stock, est_stockable');
      if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
        productsQuery = productsQuery.eq('etablissement_id', etablissementIdFilter);
      }
      final productsResponse = await productsQuery;
      final products = productsResponse as List;
      final totalProducts = products.length;
      final lowStockProducts = products.where((p) {
        final isStockable = p['est_stockable'] == true;
        final stockQuantity = (p['quantite_stock'] as num?)?.toInt() ?? 0;
        return isStockable && stockQuantity < 10;
      }).length;

      // Statistiques des utilisateurs
      final usersResponse = await _db.from('users').select('id');
      final totalUsers = (usersResponse as List).length;

      // Produits les plus commandés (filtrer par établissement si sélectionné)
      // Note: getMostOrderedProducts ne supporte pas encore le filtre par établissement
      // On devra filtrer manuellement après récupération
      final topProductsRaw = await orderRepository.getMostOrderedProducts(
          days: int.parse(selectedPeriod.value), limit: 20); // Récupérer plus pour filtrer
      
      // Filtrer par établissement si nécessaire
      List<Map<String, dynamic>> filteredTopProductsRaw = topProductsRaw;
      if (etablissementIdFilter != null && etablissementIdFilter.isNotEmpty) {
        // Récupérer les produits de l'établissement
        final etabProductsResponse = await _db
            .from('produits')
            .select('id')
            .eq('etablissement_id', etablissementIdFilter);
        final etabProductIds = (etabProductsResponse as List)
            .map((p) => p['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
        
        filteredTopProductsRaw = topProductsRaw
            .where((p) {
              final productId = p['productId']?.toString() ?? '';
              return etabProductIds.contains(productId);
            })
            .take(5)
            .toList();
      } else {
        filteredTopProductsRaw = topProductsRaw.take(5).toList();
      }

      // Enrichir avec les informations des produits (nom et catégorie)
      final topProducts = await _enrichTopProducts(filteredTopProductsRaw);

      // Commandes récentes
      final recentOrders = allOrders
          .take(5)
          .map((o) => {
                'id': o['id'],
                'total_amount': o['total_amount'],
                'status': o['status'],
                'created_at': o['created_at'],
                'etablissement_name':
                    (o['etablissement'] as Map?)?['name'] ?? 'N/A',
              })
          .toList();

      // Commandes par statut
      final ordersByStatus = <String, int>{};
      for (var order in allOrders) {
        final status = (order['status'] as String?) ?? 'unknown';
        ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;
      }

      // Statistiques par jour (jours avec le plus de commandes)
      final ordersByDay = _calculateOrdersByDay(allOrders);

      // Statistiques des heures de pickup
      final pickupHours = _calculatePickupHours(allOrders);

      // Top 10 utilisateurs les plus fidèles
      final topUsers = await _calculateTopUsers(allOrders);

      stats.value = DashboardStats(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        activeOrders: activeOrders,
        completedOrders: completedOrders,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
        monthlyRevenue: monthlyRevenue,
        totalProducts: totalProducts,
        totalEtablissements: totalEtablissements,
        totalUsers: totalUsers,
        lowStockProducts: lowStockProducts,
        ordersByStatus: ordersByStatus,
        topProducts: topProducts,
        recentOrders: recentOrders,
        averageOrderValue: averageOrderValue,
        ordersToday: ordersToday,
        ordersThisMonth: ordersThisMonth,
        ordersByDay: ordersByDay,
        pickupHours: pickupHours,
        topUsers: topUsers,
      );
    } catch (e) {
      debugPrint('Erreur chargement stats admin: $e');
      rethrow;
    }
  }

  Future<void> _loadGerantStats(String userId) async {
    try {
      // Récupérer l'établissement du gérant
      final etab =
          await etablissementController.getEtablissementUtilisateurConnecte();
      if (etab == null) {
        throw 'Aucun établissement trouvé pour ce gérant';
      }

      final etablissementId = etab.id;
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      // Déterminer la plage de dates pour le filtre
      DateTime periodStart;
      if (useCustomDateRange.value &&
          startDate.value != null &&
          endDate.value != null) {
        periodStart = DateTime(
          startDate.value!.year,
          startDate.value!.month,
          startDate.value!.day,
        );
      } else {
        periodStart =
            now.subtract(Duration(days: int.parse(selectedPeriod.value)));
      }

      // Commandes de l'établissement
      var query = _db
          .from('orders')
          .select('*')
          .eq('etablissement_id', etablissementId.toString());

      if (useCustomDateRange.value &&
          startDate.value != null &&
          endDate.value != null) {
        final filterStartDate = DateTime(
          startDate.value!.year,
          startDate.value!.month,
          startDate.value!.day,
        );
        final filterEndDate = DateTime(
          endDate.value!.year,
          endDate.value!.month,
          endDate.value!.day,
          23,
          59,
          59,
        );
        query = query
            .gte('created_at', filterStartDate.toIso8601String())
            .lte('created_at', filterEndDate.toIso8601String());
      }

      final allOrdersResponse =
          await query.order('created_at', ascending: false);
      final allOrders = allOrdersResponse as List;

      // Commandes du jour (basées sur created_at pour le comptage)
      final todayOrdersResponse = await _db
          .from('orders')
          .select('*')
          .eq('etablissement_id', etablissementId.toString())
          .gte('created_at', todayStart.toIso8601String());

      // Commandes du mois (basées sur created_at pour le comptage)
      final monthOrdersResponse = await _db
          .from('orders')
          .select('*')
          .eq('etablissement_id', etablissementId.toString())
          .gte('created_at', monthStart.toIso8601String());

      // Commandes livrées aujourd'hui (basées sur delivery_date pour le revenu)
      final todayDeliveredOrdersResponse = await _db
          .from('orders')
          .select('*')
          .eq('etablissement_id', etablissementId.toString())
          .eq('status', 'delivered')
          .not('delivery_date', 'is', null)
          .gte('delivery_date', todayStart.toIso8601String())
          .lt(
              'delivery_date',
              DateTime(now.year, now.month, now.day, 23, 59, 59)
                  .toIso8601String());

      final todayOrders = todayOrdersResponse as List;
      final monthOrders = monthOrdersResponse as List;
      final todayDeliveredOrders = todayDeliveredOrdersResponse as List;

      // Calculs
      final totalOrders = allOrders.length;
      final ordersToday = todayOrders.length;
      final ordersThisMonth = monthOrders.length;

      final pendingOrders =
          allOrders.where((o) => o['status'] == 'pending').length;
      final activeOrders = allOrders
          .where((o) => ['preparing', 'ready'].contains(o['status']))
          .length;
      final completedOrders =
          allOrders.where((o) => o['status'] == 'delivered').length;

      final totalRevenue = allOrders
          .where((o) => ['delivered', 'ready'].contains(o['status']))
          .fold<double>(
              0.0,
              (sum, o) =>
                  sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));

      // Revenu d'aujourd'hui basé sur delivery_date (seulement les commandes livrées aujourd'hui)
      final todayRevenue = todayDeliveredOrders.fold<double>(0.0,
          (sum, o) => sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));
      final monthlyRevenue = monthOrders
          .where((o) => ['delivered', 'ready'].contains(o['status']))
          .fold<double>(
              0.0,
              (sum, o) =>
                  sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));

      final averageOrderValue =
          completedOrders > 0 ? totalRevenue / completedOrders : 0.0;

      // Produits de l'établissement
      final productsResponse = await _db
          .from('produits')
          .select('id, quantite_stock, est_stockable')
          .eq('etablissement_id', etablissementId.toString());

      final products = productsResponse as List;
      final totalProducts = products.length;
      final lowStockProducts = products.where((p) {
        final isStockable = p['est_stockable'] == true;
        final stockQuantity = (p['quantite_stock'] as num?)?.toInt() ?? 0;
        return isStockable && stockQuantity < 10;
      }).length;

      // Produits les plus commandés (pour cet établissement uniquement)
      final periodOrders = await _db
          .from('orders')
          .select('items, created_at, status')
          .eq('etablissement_id', etablissementId.toString())
          .gte('created_at', periodStart.toIso8601String())
          .not('status', 'in', '(cancelled,refused)');

      final Map<String, int> productQuantities = {};
      for (var orderData in periodOrders as List) {
        final items = orderData['items'] as List?;
        if (items == null || items.isEmpty) continue;

        for (var item in items) {
          final itemMap = Map<String, dynamic>.from(item);
          final productId = itemMap['productId']?.toString() ?? '';
          final quantity = (itemMap['quantity'] as num?)?.toInt() ?? 0;

          if (productId.isEmpty || quantity <= 0) continue;
          productQuantities[productId] =
              (productQuantities[productId] ?? 0) + quantity;
        }
      }

      final topProductsRaw = productQuantities.entries
          .map((e) => {'productId': e.key, 'totalQuantity': e.value})
          .toList()
        ..sort((a, b) =>
            (b['totalQuantity'] as int).compareTo(a['totalQuantity'] as int));

      // Enrichir avec les informations des produits (nom et catégorie)
      final topProducts =
          await _enrichTopProducts(topProductsRaw.take(5).toList());

      // Commandes récentes
      final recentOrders = allOrders
          .take(5)
          .map((o) => {
                'id': o['id'],
                'total_amount': o['total_amount'],
                'status': o['status'],
                'created_at': o['created_at'],
              })
          .toList();

      // Commandes par statut
      final ordersByStatus = <String, int>{};
      for (var order in allOrders) {
        final status = (order['status'] as String?) ?? 'unknown';
        ordersByStatus[status] = (ordersByStatus[status] ?? 0) + 1;
      }

      // Statistiques par jour (jours avec le plus de commandes)
      final ordersByDay = _calculateOrdersByDay(allOrders);

      // Statistiques des heures de pickup
      final pickupHours = _calculatePickupHours(allOrders);

      // Top 10 utilisateurs les plus fidèles (pour cet établissement)
      final topUsers = await _calculateTopUsers(allOrders);

      stats.value = DashboardStats(
        totalOrders: totalOrders,
        pendingOrders: pendingOrders,
        activeOrders: activeOrders,
        completedOrders: completedOrders,
        totalRevenue: totalRevenue,
        todayRevenue: todayRevenue,
        monthlyRevenue: monthlyRevenue,
        totalProducts: totalProducts,
        totalEtablissements: 1, // Un seul établissement pour le gérant
        totalUsers: 0, // Non applicable pour le gérant
        lowStockProducts: lowStockProducts,
        ordersByStatus: ordersByStatus,
        topProducts: topProducts.take(5).toList(),
        recentOrders: recentOrders,
        averageOrderValue: averageOrderValue,
        ordersToday: ordersToday,
        ordersThisMonth: ordersThisMonth,
        ordersByDay: ordersByDay,
        pickupHours: pickupHours,
        topUsers: topUsers,
      );
    } catch (e) {
      debugPrint('Erreur chargement stats gérant: $e');
      rethrow;
    }
  }

  void updatePeriod(String period) {
    selectedPeriod.value = period;
    useCustomDateRange.value = false;
    startDate.value = null;
    endDate.value = null;
    loadDashboardStats();
  }

  void updateCustomDateRange(DateTime? start, DateTime? end) {
    if (start != null && end != null) {
      useCustomDateRange.value = true;
      startDate.value = start;
      endDate.value = end;
      loadDashboardStats();
    }
  }

  void clearCustomDateRange() {
    useCustomDateRange.value = false;
    startDate.value = null;
    endDate.value = null;
    loadDashboardStats();
  }

  /// Met à jour le filtre d'établissement (Admin uniquement)
  void updateEtablissementFilter(String? etablissementId) {
    selectedEtablissementId.value = etablissementId;
    loadDashboardStats();
  }

  /// Efface le filtre d'établissement
  void clearEtablissementFilter() {
    selectedEtablissementId.value = null;
    loadDashboardStats();
  }

  /// Met à jour le filtre de période pour les revenus
  void updateRevenuePeriodFilter(String period) {
    revenuePeriodFilter.value = period;
  }

  /// Enrichit les produits les plus vendus avec leurs noms et catégories
  Future<List<Map<String, dynamic>>> _enrichTopProducts(
      List<Map<String, dynamic>> topProductsRaw) async {
    final enrichedProducts = <Map<String, dynamic>>[];

    // Récupérer toutes les catégories pour le mapping
    final categoriesResponse = await _db.from('categories').select('id, name');
    final categoriesMap = <String, String>{};
    for (var cat in categoriesResponse as List) {
      categoriesMap[cat['id']?.toString() ?? ''] =
          cat['name']?.toString() ?? 'Inconnue';
    }

    // Enrichir chaque produit
    for (var product in topProductsRaw) {
      final productId = product['productId'] as String? ?? '';
      if (productId.isEmpty) continue;

      try {
        // Récupérer le produit
        final productResponse = await _db
            .from('produits')
            .select('id, nom, categorie_id')
            .eq('id', productId)
            .maybeSingle();

        if (productResponse != null) {
          final productName =
              productResponse['nom']?.toString() ?? 'Produit inconnu';
          final categoryId = productResponse['categorie_id']?.toString() ?? '';
          final categoryName = categoriesMap[categoryId] ?? 'Sans catégorie';

          enrichedProducts.add({
            'productId': productId,
            'productName': productName,
            'categoryName': categoryName,
            'totalQuantity': product['totalQuantity'],
          });
        } else {
          // Si le produit n'existe plus, on garde l'ID
          enrichedProducts.add({
            'productId': productId,
            'productName': 'Produit supprimé',
            'categoryName': 'Inconnue',
            'totalQuantity': product['totalQuantity'],
          });
        }
      } catch (e) {
        debugPrint('Erreur enrichissement produit $productId: $e');
        // En cas d'erreur, garder les données de base
        enrichedProducts.add({
          'productId': productId,
          'productName': 'Erreur de chargement',
          'categoryName': 'Inconnue',
          'totalQuantity': product['totalQuantity'],
        });
      }
    }

    return enrichedProducts;
  }

  /// Calcule les jours avec le plus de commandes
  List<Map<String, dynamic>> _calculateOrdersByDay(List allOrders) {
    final dayCounts = <String, int>{};

    for (var order in allOrders) {
      // Utiliser pickup_day si disponible, sinon utiliser created_at
      String dayKey;
      if (order['pickup_day'] != null &&
          order['pickup_day'].toString().isNotEmpty) {
        dayKey = order['pickup_day'].toString();
      } else if (order['pickup_date_time'] != null) {
        try {
          final pickupDate =
              DateTime.parse(order['pickup_date_time'].toString());
          final weekday = pickupDate.weekday;
          dayKey = _weekdayToFrenchDay(weekday);
        } catch (e) {
          // Si erreur de parsing, utiliser created_at
          try {
            final createdDate = DateTime.parse(order['created_at'].toString());
            final weekday = createdDate.weekday;
            dayKey = _weekdayToFrenchDay(weekday);
          } catch (e2) {
            continue;
          }
        }
      } else if (order['created_at'] != null) {
        try {
          final createdDate = DateTime.parse(order['created_at'].toString());
          final weekday = createdDate.weekday;
          dayKey = _weekdayToFrenchDay(weekday);
        } catch (e) {
          continue;
        }
      } else {
        continue;
      }

      dayCounts[dayKey] = (dayCounts[dayKey] ?? 0) + 1;
    }

    // Trier par nombre de commandes décroissant et prendre le top 7
    final sortedDays = dayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedDays
        .take(7)
        .map((entry) => {
              'day': entry.key,
              'count': entry.value,
            })
        .toList();
  }

  /// Calcule les heures de pickup les plus fréquentes
  List<Map<String, dynamic>> _calculatePickupHours(List allOrders) {
    final hourCounts = <String, int>{};

    for (var order in allOrders) {
      String? hourKey;

      // Essayer d'abord pickup_time_range (format "HH:MM - HH:MM")
      if (order['pickup_time_range'] != null &&
          order['pickup_time_range'].toString().isNotEmpty) {
        final timeRange = order['pickup_time_range'].toString();
        // Extraire l'heure de début (avant le "-")
        final parts = timeRange.split(' - ');
        if (parts.isNotEmpty) {
          final timeStr = parts[0].trim();
          // Extraire l'heure (avant les ":")
          final hourParts = timeStr.split(':');
          if (hourParts.isNotEmpty) {
            final hour = int.tryParse(hourParts[0]) ?? 0;
            hourKey = '${hour.toString().padLeft(2, '0')}:00';
          }
        }
      }

      // Si pas de pickup_time_range, utiliser pickup_date_time
      if (hourKey == null && order['pickup_date_time'] != null) {
        try {
          final pickupDate =
              DateTime.parse(order['pickup_date_time'].toString());
          hourKey = '${pickupDate.hour.toString().padLeft(2, '0')}:00';
        } catch (e) {
          continue;
        }
      }

      if (hourKey != null) {
        hourCounts[hourKey] = (hourCounts[hourKey] ?? 0) + 1;
      }
    }

    // Trier par nombre de commandes décroissant et prendre le top 10
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours
        .take(10)
        .map((entry) => {
              'hour': entry.key,
              'count': entry.value,
            })
        .toList();
  }

  /// Convertit le numéro de jour de la semaine (1-7) en nom français
  String _weekdayToFrenchDay(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Inconnu';
    }
  }

  /// Calcule les top 10 utilisateurs les plus fidèles (avec le plus de commandes)
  Future<List<Map<String, dynamic>>> _calculateTopUsers(List allOrders) async {
    final userOrderCounts = <String, int>{};
    final userTotalSpent = <String, double>{};

    // Compter les commandes et calculer le total dépensé par utilisateur
    for (var order in allOrders) {
      final userId = order['user_id']?.toString() ?? '';
      if (userId.isEmpty) continue;

      // Exclure les commandes annulées ou refusées
      final status = order['status']?.toString() ?? '';
      if (status == 'cancelled' || status == 'refused') continue;

      userOrderCounts[userId] = (userOrderCounts[userId] ?? 0) + 1;

      final totalAmount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
      userTotalSpent[userId] = (userTotalSpent[userId] ?? 0.0) + totalAmount;
    }

    // Trier par nombre de commandes décroissant et prendre le top 10
    final sortedUsers = userOrderCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topUserIds = sortedUsers.take(10).map((e) => e.key).toList();

    // Enrichir avec les informations des utilisateurs
    final enrichedUsers = <Map<String, dynamic>>[];

    for (var userId in topUserIds) {
      try {
        final userResponse = await _db
            .from('users')
            .select(
                'id, first_name, last_name, email, phone, profile_image_url')
            .eq('id', userId)
            .maybeSingle();

        if (userResponse != null) {
          final firstName = userResponse['first_name']?.toString() ?? '';
          final lastName = userResponse['last_name']?.toString() ?? '';
          final email = userResponse['email']?.toString() ?? 'N/A';
          final phone = userResponse['phone']?.toString() ?? 'N/A';
          final profileImageUrl = userResponse['profile_image_url']?.toString();

          enrichedUsers.add({
            'userId': userId,
            'firstName': firstName,
            'lastName': lastName,
            'fullName': '$firstName $lastName'.trim().isEmpty
                ? 'Utilisateur'
                : '$firstName $lastName',
            'email': email,
            'phone': phone,
            'profileImageUrl': profileImageUrl,
            'orderCount': userOrderCounts[userId] ?? 0,
            'totalSpent': userTotalSpent[userId] ?? 0.0,
          });
        } else {
          // Utilisateur supprimé mais avec des commandes
          enrichedUsers.add({
            'userId': userId,
            'firstName': '',
            'lastName': '',
            'fullName': 'Utilisateur supprimé',
            'email': 'N/A',
            'phone': 'N/A',
            'profileImageUrl': null,
            'orderCount': userOrderCounts[userId] ?? 0,
            'totalSpent': userTotalSpent[userId] ?? 0.0,
          });
        }
      } catch (e) {
        debugPrint('Erreur enrichissement utilisateur $userId: $e');
        // En cas d'erreur, garder les données de base
        enrichedUsers.add({
          'userId': userId,
          'firstName': '',
          'lastName': '',
          'fullName': 'Erreur de chargement',
          'email': 'N/A',
          'phone': 'N/A',
          'profileImageUrl': null,
          'orderCount': userOrderCounts[userId] ?? 0,
          'totalSpent': userTotalSpent[userId] ?? 0.0,
        });
      }
    }

    return enrichedUsers;
  }

  // ==================== MÉTHODES POUR LES GRAPHIQUES ====================

  /// Récupère les revenus cumulatifs selon la période sélectionnée
  Future<List<Map<String, dynamic>>> getDailyRevenue() async {
    try {
      final now = DateTime.now();
      final List<Map<String, dynamic>> revenueData = [];

      // Vérifier le rôle de l'utilisateur pour filtrer par établissement si nécessaire
      final userRole = userController.userRole;
      String? etablissementId;

      // Si c'est un gérant, récupérer son établissement
      if (userRole == 'Gérant') {
        final etab = await etablissementController.getEtablissementUtilisateurConnecte();
        if (etab != null) {
          etablissementId = etab.id.toString();
        }
      } else if (userRole == 'Admin') {
        // Pour l'admin, utiliser le filtre d'établissement sélectionné s'il existe
        etablissementId = selectedEtablissementId.value;
      }

      final period = revenuePeriodFilter.value;
      DateTime startDate;
      bool isMonthly = false; // Pour l'affichage mensuel vs quotidien

      // Déterminer la période de début selon le filtre
      switch (period) {
        case '7days':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        case '3months':
          if (now.month <= 2) {
            startDate = DateTime(now.year - 1, 12 + now.month - 2, 1);
          } else {
            startDate = DateTime(now.year, now.month - 2, 1);
          }
          break;
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          isMonthly = true; // Afficher par mois pour l'année
          break;
        case 'all':
          // Récupérer la date de la première commande
          var firstOrderQuery = _db
              .from('orders')
              .select('delivery_date')
              .eq('status', 'delivered')
              .not('delivery_date', 'is', null);
          if (etablissementId != null && etablissementId.isNotEmpty) {
            firstOrderQuery = firstOrderQuery.eq('etablissement_id', etablissementId);
          }
          final firstOrderResponse = await firstOrderQuery
              .order('delivery_date', ascending: true)
              .limit(1);
          if (firstOrderResponse.isNotEmpty) {
            try {
              startDate = DateTime.parse(firstOrderResponse[0]['delivery_date']);
            } catch (e) {
              startDate = DateTime(now.year - 1, 1, 1); // Par défaut, 1 an en arrière
            }
          } else {
            startDate = DateTime(now.year - 1, 1, 1);
          }
          isMonthly = true; // Afficher par mois pour toutes périodes
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      double cumulativeRevenue = 0.0;

      if (isMonthly) {
        // Calcul par mois (pour année et toutes périodes)
        final currentMonth = DateTime(now.year, now.month, 1);
        DateTime monthStart = DateTime(startDate.year, startDate.month, 1);
        
        while (monthStart.isBefore(currentMonth) || monthStart.isAtSameMomentAs(currentMonth)) {
          final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1).subtract(const Duration(days: 1));
          final endOfMonth = DateTime(monthEnd.year, monthEnd.month, monthEnd.day, 23, 59, 59);
          
          var query = _db
              .from('orders')
              .select('total_amount, status, delivery_date')
              .eq('status', 'delivered')
              .not('delivery_date', 'is', null)
              .gte('delivery_date', monthStart.toIso8601String())
              .lte('delivery_date', endOfMonth.toIso8601String());

          if (etablissementId != null && etablissementId.isNotEmpty) {
            query = query.eq('etablissement_id', etablissementId);
          }

          final orders = await query;
          final monthRevenue = (orders as List).fold<double>(0.0,
              (sum, o) => sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));
          
          cumulativeRevenue += monthRevenue;

          revenueData.add({
            'date': '${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}',
            'revenue': cumulativeRevenue,
            'periodRevenue': monthRevenue, // Revenu de la période (non cumulatif)
          });

          // Passer au mois suivant
          monthStart = DateTime(monthStart.year, monthStart.month + 1, 1);
        }
      } else {
        // Calcul par jour (pour 7 jours, mois, 3 mois)
        final daysDiff = now.difference(startDate).inDays;
        
        for (int i = daysDiff; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final startOfDay = DateTime(date.year, date.month, date.day);
          final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

          var query = _db
              .from('orders')
              .select('total_amount, status, delivery_date')
              .eq('status', 'delivered')
              .not('delivery_date', 'is', null)
              .gte('delivery_date', startOfDay.toIso8601String())
              .lte('delivery_date', endOfDay.toIso8601String());

          if (etablissementId != null && etablissementId.isNotEmpty) {
            query = query.eq('etablissement_id', etablissementId);
          }

          final orders = await query;
          final dayRevenue = (orders as List).fold<double>(0.0,
              (sum, o) => sum + ((o['total_amount'] as num?)?.toDouble() ?? 0.0));
          
          cumulativeRevenue += dayRevenue;

          revenueData.add({
            'date':
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
            'revenue': cumulativeRevenue,
            'periodRevenue': dayRevenue, // Revenu de la période (non cumulatif)
          });
        }
      }

      return revenueData;
    } catch (e) {
      debugPrint('Erreur getDailyRevenue: $e');
      return [];
    }
  }

  /// Récupère les top établissements par revenus
  Future<List<Map<String, dynamic>>> getTopEtablissements(int limit) async {
    try {
      final orders = await _db
          .from('orders')
          .select(
              'etablissement_id, total_amount, status, etablissement:etablissement_id(name)')
          .inFilter('status', ['delivered', 'ready']);

      final Map<String, double> revenueByEtab = {};
      final Map<String, String> namesByEtab = {};

      for (var order in orders as List) {
        final etabId = order['etablissement_id']?.toString() ?? '';
        if (etabId.isEmpty) continue;

        final amount = (order['total_amount'] as num?)?.toDouble() ?? 0.0;
        final etab = order['etablissement'] as Map?;
        final name = etab?['name']?.toString() ?? 'Inconnu';

        revenueByEtab[etabId] = (revenueByEtab[etabId] ?? 0.0) + amount;
        namesByEtab[etabId] = name;
      }

      final sorted = revenueByEtab.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted
          .take(limit)
          .map((e) => {
                'id': e.key,
                'name': namesByEtab[e.key] ?? 'Inconnu',
                'revenue': e.value,
              })
          .toList();
    } catch (e) {
      debugPrint('Erreur getTopEtablissements: $e');
      return [];
    }
  }

  /// Récupère les commandes par jour de la semaine (format pour bar chart)
  List<Map<String, dynamic>> getOrdersByDayForChart(
      List<Map<String, dynamic>> ordersByDay) {
    // Les jours de la semaine dans l'ordre
    final weekDays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];

    // Créer un map pour faciliter la recherche
    final ordersMap = <String, int>{};
    for (var order in ordersByDay) {
      final day = order['day'] as String? ?? '';
      final count = order['count'] as int? ?? 0;
      ordersMap[day] = count;
    }

    // Retourner dans l'ordre des jours de la semaine
    return weekDays.map((day) {
      return {
        'day': day,
        'count': ordersMap[day] ?? 0,
      };
    }).toList();
  }
}
