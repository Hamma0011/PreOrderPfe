import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/sizes.dart';


class ImageComparison extends StatelessWidget {
  final String currentImageUrl;
  final String pendingImageUrl;
  const ImageComparison({super.key, required this.currentImageUrl, required this.pendingImageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image actuelle
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image actuelle',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
              child: CachedNetworkImage(
                imageUrl: currentImageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 40),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Nouvelle image
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Iconsax.arrow_down_2,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'Nouvelle image',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                border: Border.all(color: Colors.blue.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
                child: CachedNetworkImage(
                  imageUrl: pendingImageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, size: 40),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
