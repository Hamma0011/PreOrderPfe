import 'package:flutter/material.dart';

class RevenueItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool dark;
  const RevenueItem({super.key, required this.label, required this.value, required this.color, required this.dark});

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${value.toStringAsFixed(0)} DT',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}