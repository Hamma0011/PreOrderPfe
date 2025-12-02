import 'package:flutter/material.dart';

import '../../../../../utils/constants/sizes.dart';

class SystemStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const SystemStatItem({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return     Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade400),
          const SizedBox(width: AppSizes.spaceBtwItems),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade400,
                ),
          ),
        ],
      ),
    );
  }
  }
