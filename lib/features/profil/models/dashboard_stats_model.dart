class DashboardStats {
  final int totalOrders;
  final int pendingOrders;
  final int activeOrders;
  final int completedOrders;
  final double totalRevenue;
  final double todayRevenue;
  final double monthlyRevenue;
  final int totalProducts;
  final int totalEtablissements;
  final int totalUsers;
  final int lowStockProducts;
  final Map<String, int> ordersByStatus;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> recentOrders;
  final double averageOrderValue;
  final int ordersToday;
  final int ordersThisMonth;
  final List<Map<String, dynamic>> ordersByDay; // Jour avec le plus de commandes
  final List<Map<String, dynamic>> pickupHours; // Heures de pickup les plus fréquentes
  final List<Map<String, dynamic>> topUsers; // Top 10 utilisateurs les plus fidèles

  DashboardStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.todayRevenue,
    required this.monthlyRevenue,
    required this.totalProducts,
    required this.totalEtablissements,
    required this.totalUsers,
    required this.lowStockProducts,
    required this.ordersByStatus,
    required this.topProducts,
    required this.recentOrders,
    required this.averageOrderValue,
    required this.ordersToday,
    required this.ordersThisMonth,
    required this.ordersByDay,
    required this.pickupHours,
    required this.topUsers,
  });
}