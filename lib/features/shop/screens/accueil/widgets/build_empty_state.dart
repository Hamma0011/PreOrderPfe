import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'search_overlay.dart';

class BuildEmptyState extends StatelessWidget {
  const BuildEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.fastfood_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit populaire',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aller vers la page de recherche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          IconButton(
            padding: const EdgeInsets.all(12),
            iconSize: 40,
            icon: const Icon(Iconsax.search_normal_1, color: Colors.white),
            onPressed: () {
              Get.to(() => const SearchOverlay(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: 300));
            },
          ),
        ],
      ),
    );
  }
}
