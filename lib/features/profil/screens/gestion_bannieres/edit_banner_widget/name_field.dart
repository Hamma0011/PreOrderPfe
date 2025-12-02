import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';

class NameField extends StatelessWidget {
  final BannerController controller;
  final bool isAdminView;
  final BannerModel banner;
  const NameField(
      {super.key,
      required this.controller,
      required this.isAdminView,
      required this.banner});

  @override
  Widget build(BuildContext context) {
    final hasPendingName =
        banner.pendingChanges != null && banner.pendingChanges!['name'] != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller.nameController,
          readOnly: isAdminView,
          decoration: InputDecoration(
            labelText: 'Nom de la bannière',
            prefixIcon: const Icon(Iconsax.text),
            filled: isAdminView,
          ),
          validator: (value) {
            if (!isAdminView && (value == null || value.isEmpty)) {
              return 'Veuillez entrer un nom';
            }
            return null;
          },
        ),
        // Afficher le nom modifié sous le TextField
        if (hasPendingName) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nouveau nom:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        banner.pendingChanges!['name'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
