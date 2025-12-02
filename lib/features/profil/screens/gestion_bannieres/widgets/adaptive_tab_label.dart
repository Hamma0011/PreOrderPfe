import 'package:flutter/material.dart';

class AdaptiveTabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color badgeColor;
  final Color badgeTextColor;

  const AdaptiveTabLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Width thresholds (adjust as needed)
        const double minWidthForIcon = 110;
        const double minWidthForBadge = 150;

        final bool showBadge = constraints.maxWidth > minWidthForBadge;
        final bool showIcon = constraints.maxWidth > minWidthForIcon;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) Icon(icon, size: 16),
            if (showIcon) const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showBadge) const SizedBox(width: 6),
            if (showBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
