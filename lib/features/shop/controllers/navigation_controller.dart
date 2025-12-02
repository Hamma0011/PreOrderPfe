import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profil/screens/settings/settings.dart';
import '../screens/accueil/home.dart';
import '../screens/etablissements/etablissements.dart';
import '../screens/favorite/favorite_screen.dart';

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  Widget getScreen(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const StoreScreen();
      case 2:
        return const FavoriteScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const HomeScreen();
    }
  }
}
