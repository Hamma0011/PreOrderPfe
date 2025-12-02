import 'package:flutter/material.dart';
import '../../utils/constants/colors.dart';

class TShadowStyle {
  static final verticalProductShadow = BoxShadow(
    color: TColors.darkGrey.withValues(alpha: 0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );

  static final horizontalProductShadow = BoxShadow(
    color: TColors.darkGrey.withValues(alpha: 0.1),
    blurRadius: 50,
    spreadRadius: 7,
    offset: const Offset(0, 2),
  );

  static final vericalCardProductShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}
