import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/enums.dart';

class THelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }

  static String getFormattedDate(DateTime date,
      {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static List<String> generateTimeSlots(String start, String end,
      {int intervalMinutes = 30}) {
    final List<String> slots = [];
    final startParts = start.split(':').map(int.parse).toList();
    final endParts = end.split(':').map(int.parse).toList();

    DateTime startTime = DateTime(0, 0, 0, startParts[0], startParts[1]);
    DateTime endTime = DateTime(0, 0, 0, endParts[0], endParts[1]);

    while (startTime.isBefore(endTime)) {
      final slotEnd = startTime.add(Duration(minutes: intervalMinutes));
      if (slotEnd.isAfter(endTime)) break;

      final slotStr =
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${slotEnd.hour.toString().padLeft(2, '0')}:${slotEnd.minute.toString().padLeft(2, '0')}';
      slots.add(slotStr);
      startTime = slotEnd;
    }

    return slots;
  }

  static int weekdayFromJour(JourSemaine jour) {
    switch (jour) {
      case JourSemaine.lundi:
        return 1;
      case JourSemaine.mardi:
        return 2;
      case JourSemaine.mercredi:
        return 3;
      case JourSemaine.jeudi:
        return 4;
      case JourSemaine.vendredi:
        return 5;
      case JourSemaine.samedi:
        return 6;
      case JourSemaine.dimanche:
        return 7;
    }
  }

  static JourSemaine stringToJourSemaine(String jour) {
    switch (jour.toLowerCase()) {
      case 'lundi':
        return JourSemaine.lundi;
      case 'mardi':
        return JourSemaine.mardi;
      case 'mercredi':
        return JourSemaine.mercredi;
      case 'jeudi':
        return JourSemaine.jeudi;
      case 'vendredi':
        return JourSemaine.vendredi;
      case 'samedi':
        return JourSemaine.samedi;
      case 'dimanche':
        return JourSemaine.dimanche;
      default:
        throw Exception('Invalid day string: $jour');
    }
  }

  static String getJourAbrege(JourSemaine jour) {
    switch (jour) {
      case JourSemaine.lundi:
        return 'LUN';
      case JourSemaine.mardi:
        return 'MAR';
      case JourSemaine.mercredi:
        return 'MER';
      case JourSemaine.jeudi:
        return 'JEU';
      case JourSemaine.vendredi:
        return 'VEN';
      case JourSemaine.samedi:
        return 'SAM';
      case JourSemaine.dimanche:
        return 'DIM';
    }
  }

  // Fonctions utilitaires privées
  static JourSemaine getJourSemaineFromDateTime(DateTime date) {
    switch (date.weekday) {
      case 1:
        return JourSemaine.lundi;
      case 2:
        return JourSemaine.mardi;
      case 3:
        return JourSemaine.mercredi;
      case 4:
        return JourSemaine.jeudi;
      case 5:
        return JourSemaine.vendredi;
      case 6:
        return JourSemaine.samedi;
      case 7:
        return JourSemaine.dimanche;
      default:
        return JourSemaine.lundi;
    }
  }

  // Méthode pour le statut
  static String getStatutText(StatutEtablissement statut) {
    switch (statut) {
      case StatutEtablissement.approuve:
        return 'Approuvé ✓';
      case StatutEtablissement.rejete:
        return 'Rejeté ✗';
      case StatutEtablissement.en_attente:
        return 'En attente de validation';
    }
  }

  static Color getStatutColor(StatutEtablissement statut) {
    switch (statut) {
      case StatutEtablissement.approuve:
        return Colors.green;
      case StatutEtablissement.rejete:
        return Colors.red;
      case StatutEtablissement.en_attente:
        return Colors.orange;
    }
  }

  static (Color, String) getStatutInfo(StatutEtablissement statut) {
    switch (statut) {
      case StatutEtablissement.en_attente:
        return (Colors.orange, "En attente");
      case StatutEtablissement.approuve:
        return (Colors.green, "Approuvé");
      case StatutEtablissement.rejete:
        return (Colors.red, "Rejeté");
    }
  }

  static String getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.preparing:
        return 'En préparation';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.refused:
        return 'Refusée';
    }
  }
}
