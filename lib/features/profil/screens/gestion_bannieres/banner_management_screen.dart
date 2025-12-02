import 'package:caferesto/features/profil/screens/gestion_bannieres/widgets/build_tabs.dart';
import 'package:caferesto/features/profil/screens/gestion_bannieres/widgets/search_bar.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:caferesto/features/shop/models/banner_model.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../common/widgets/loading/loading_screen.dart';
import '../../controllers/banner_management_controller.dart';
import 'add_banner_screen.dart';
import 'edit_banner_screen.dart';
import 'widgets/build_empty_state.dart';

class BannerManagementScreen extends StatelessWidget {
  const BannerManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser les controllers
    Get.put(BannerController());
    final controller = Get.put(BannerManagementController());

    return Scaffold(
      appBar: TAppBar(
        title: const Text("Gestion des bannières"),
      ),
      body: Column(
        children: [
          BuildTabs(controller: controller),
          BuildSearchBar(controller: controller),
          Expanded(child: _buildBody(context, controller)),
        ],
      ),
      floatingActionButton:
          controller.canManageBanners ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildBody(
      BuildContext context, BannerManagementController controller) {
    return Obx(() {
      if (controller.isLoading) {
        return LoadingScreen(
          screenName: 'Bannières',
        );
      }

      final banners = controller.filteredBanners;

      if (banners.isEmpty) {
        return BuildEmptyState(controller: controller);
      }

      return _buildBannerList(context, banners, controller);
    });
  }

  Widget _buildBannerList(BuildContext context, List<BannerModel> banners,
      BannerManagementController controller) {
    return RefreshIndicator(
      onRefresh: controller.refreshBanners,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        itemCount: banners.length,
        itemBuilder: (_, i) =>
            _buildBannerCard(banners[i], context, controller),
      ),
    );
  }

  Widget _buildBannerCard(BannerModel banner, BuildContext context,
      BannerManagementController controller) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: dark ? TColors.eerieBlack : TColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildBannerImage(banner),
        title: Flexible(
          child: Text(
            banner.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBannerSubtitle(banner),
            const SizedBox(height: 4),
            _buildStatusChip(banner, controller),
            // Afficher les modifications en attente pour l'admin
            if (controller.isAdmin && controller.hasPendingChanges(banner)) ...[
              const SizedBox(height: 8),
              _buildPendingChangesIndicator(banner, controller),
            ],
          ],
        ),
        trailing: controller.isAdmin
            ? (controller.hasPendingChanges(banner)
                ? _buildPendingChangesActions(banner, controller)
                : IconButton(
                    icon: const Icon(Iconsax.trash, color: Colors.red),
                    tooltip: 'Supprimer la bannière',
                    onPressed: () =>
                        _showDeleteDialog(context, banner, controller),
                  ))
            : controller.isGerant
                ? IconButton(
                    icon: const Icon(Iconsax.more),
                    onPressed: () =>
                        _showBannerOptions(context, banner, controller),
                  )
                : null,
        onTap: controller.isAdmin
            ? () {
                // Admin peut cliquer pour voir les détails et changer le statut
                controller.loadBannerForEditing(banner);
                Get.to(
                    () => EditBannerScreen(banner: banner, isAdminView: true));
              }
            : controller.isGerant
                ? () => _showBannerOptions(context, banner, controller)
                : null,
      ),
    );
  }

  Widget _buildStatusChip(
      BannerModel banner, BannerManagementController controller) {
    final statusColor = controller.getStatusColor(banner.status);
    final statusLabel = controller.getStatusLabel(banner.status);

    IconData statusIcon;
    switch (banner.status) {
      case 'publiee':
        statusIcon = Iconsax.tick_circle;
        break;
      case 'refusee':
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusIcon = Iconsax.clock;
    }

    return GestureDetector(
      onTap: controller.isAdmin
          ? () => _showStatusChangeDialog(banner, controller)
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.isAdmin
                ? statusColor.shade300
                : statusColor.shade200,
            width: controller.isAdmin ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 12, color: statusColor.shade700),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                statusLabel,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor.shade700,
                ),
              ),
            ),
            if (controller.isAdmin) ...[
              const SizedBox(width: 4),
              Icon(
                Iconsax.arrow_down_1,
                size: 10,
                color: statusColor.shade700,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(
      BannerModel banner, BannerManagementController controller) {
    final currentStatus = banner.status;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Changer le statut"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bannière: ${banner.name}"),
            const SizedBox(height: 16),
            const Text("Sélectionner le nouveau statut:"),
            const SizedBox(height: 16),
            _buildStatusOption('en_attente', 'En attente', Colors.orange,
                Iconsax.clock, currentStatus, banner, controller),
            const SizedBox(height: 8),
            _buildStatusOption('publiee', 'Publiée', Colors.green,
                Iconsax.tick_circle, currentStatus, banner, controller),
            const SizedBox(height: 8),
            _buildStatusOption('refusee', 'Refusée', Colors.red,
                Iconsax.close_circle, currentStatus, banner, controller),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    String label,
    MaterialColor color,
    IconData icon,
    String currentStatus,
    BannerModel banner,
    BannerManagementController controller,
  ) {
    final isSelected = status == currentStatus;

    return InkWell(
      onTap: isSelected
          ? null
          : () {
              Get.back();
              controller.updateBannerStatus(banner.id, status);
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.shade100 : color.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.shade300 : color.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color.shade700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle, color: color.shade700, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerImage(BannerModel banner) {
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          banner.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Iconsax.image, color: Colors.grey[400], size: 24),
          loadingBuilder: (context, child, loading) {
            if (loading == null) return child;
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      ),
    );
  }

  Widget _buildBannerSubtitle(BannerModel banner) {
    String subtitle = '';
    if (banner.linkType != null && banner.linkType!.isNotEmpty) {
      switch (banner.linkType) {
        case 'product':
          subtitle = 'Produit';
          break;
        case 'category':
          subtitle = 'Catégorie';
          break;
        case 'establishment':
          subtitle = 'Établissement';
          break;
        default:
          subtitle = 'Aucun lien';
      }
    } else {
      subtitle = 'Aucun lien';
    }

    return Text(
      subtitle,
      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton(
        onPressed: () => Get.to(() => const AddBannerScreen()),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Iconsax.additem, size: 28),
      );

  void _showBannerOptions(BuildContext context, BannerModel banner,
      BannerManagementController controller) {
    if (!controller.isGerant) return;

    Get.bottomSheet(
      _buildBottomSheetContent(context, banner, controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildBottomSheetContent(BuildContext context, BannerModel banner,
      BannerManagementController controller) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? TColors.eerieBlack : TColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHeader(banner, controller),
          const SizedBox(height: 16),
          _buildActionButtons(context, banner, controller),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Annuler"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHeader(
      BannerModel banner, BannerManagementController controller) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildBannerImage(banner),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                _buildBannerSubtitle(banner),
                const SizedBox(height: 8),
                _buildStatusChip(banner, controller),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, BannerModel banner,
      BannerManagementController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.back();
                controller.loadBannerForEditing(banner);
                Get.to(() => EditBannerScreen(banner: banner));
              },
              icon: const Icon(Iconsax.edit, size: 20),
              label: const Text("Éditer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteDialog(context, banner, controller),
              icon: const Icon(Iconsax.trash, size: 20),
              label: const Text("Supprimer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, BannerModel banner,
      BannerManagementController controller) {
    Get.back();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber),
            SizedBox(width: 12),
            Text("Confirmer la suppression"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Supprimer la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Cette action est irréversible.",
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Annuler",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Fermer le dialog de confirmation
              await controller.deleteBanner(banner.id);
              // Le snackbar de succès sera affiché par le contrôleur
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          )
        ],
      ),
    );
  }

  /// Widget pour afficher l'indicateur de modifications en attente
  Widget _buildPendingChangesIndicator(
      BannerModel banner, BannerManagementController controller) {
    return InkWell(
      onTap: () {
        controller.loadBannerForEditing(banner);
        Get.to(() => EditBannerScreen(banner: banner, isAdminView: true));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 6),
            Text(
              'Modifications en attente',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Iconsax.arrow_right_2, size: 14, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  /// Widget pour les boutons d'action sur les modifications en attente (Admin)
  Widget _buildPendingChangesActions(
      BannerModel banner, BannerManagementController controller) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Iconsax.tick_circle, color: Colors.green.shade600),
          tooltip: 'Approuver les modifications',
          onPressed: () => _showApprovePendingChangesDialog(banner, controller),
        ),
        IconButton(
          icon: Icon(Iconsax.close_circle, color: Colors.red.shade600),
          tooltip: 'Refuser les modifications',
          onPressed: () => _showRejectPendingChangesDialog(banner, controller),
        ),
        IconButton(
          icon: const Icon(Iconsax.eye),
          tooltip: 'Voir les modifications',
          onPressed: () {
            controller.loadBannerForEditing(banner);
            Get.to(() => EditBannerScreen(banner: banner, isAdminView: true));
          },
        ),
      ],
    );
  }

  /// Dialog pour confirmer l'approbation des modifications
  void _showApprovePendingChangesDialog(
      BannerModel banner, BannerManagementController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.tick_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text("Approuver les modifications"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Approuver les modifications pour la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Les modifications seront appliquées immédiatement.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.approvePendingChanges(banner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Approuver"),
          ),
        ],
      ),
    );
  }

  /// Dialog pour confirmer le refus des modifications
  void _showRejectPendingChangesDialog(
      BannerModel banner, BannerManagementController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.close_circle, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text("Refuser les modifications"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Refuser les modifications pour la bannière \"${banner.name}\" ?"),
            const SizedBox(height: 8),
            Text(
              "Les modifications en attente seront supprimées.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.rejectPendingChanges(banner.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Refuser"),
          ),
        ],
      ),
    );
  }
}
