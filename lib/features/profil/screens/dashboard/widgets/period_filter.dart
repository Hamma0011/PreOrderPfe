import 'package:caferesto/features/profil/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/popups/loaders.dart';

class PeriodFilter extends StatelessWidget {
  final bool dark;
  final DashboardController controller;
  final bool isAdmin;
  const PeriodFilter({
    super.key,
    required this.controller,
    required this.dark,
    this.isAdmin = false,
  });

  bool _isDateRangeValid(DateTime? start, DateTime? end) {
    if (start == null || end == null) return false;
    return start.isBefore(end) || start.isAtSameMomentAs(end);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusSm),
        border: Border.all(
          color: Colors.blue.shade400.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.calendar, size: 20, color: Colors.blue.shade400),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Filtre par période',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          // Filtre par établissement (Admin uniquement)
          if (isAdmin) ...[
            Obx(() {
              final etablissements = controller.etablissements;
              final selectedId = controller.selectedEtablissementId.value;
              
              return Wrap(
                spacing: AppSizes.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Établissement: '),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade400.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String?>(
                      value: selectedId,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      icon: Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      hint: const Text('Tous les établissements'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Tous les établissements'),
                        ),
                        ...etablissements.map((etab) {
                          final id = etab['id'] as String? ?? '';
                          return DropdownMenuItem<String?>(
                            value: id.isEmpty ? null : id,
                            child: Text(
                              etab['name'] as String? ?? 'Inconnu',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        controller.updateEtablissementFilter(value);
                      },
                    ),
                  ),
                  if (selectedId != null)
                    IconButton(
                      icon: Icon(
                        Iconsax.close_circle,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      onPressed: () => controller.clearEtablissementFilter(),
                      tooltip: 'Effacer le filtre',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              );
            }),
            const SizedBox(height: AppSizes.md),
          ],
          // Options de période rapide
          Wrap(
            spacing: AppSizes.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Période rapide: '),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.shade400.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => DropdownButton<String>(
                      value: controller.useCustomDateRange.value
                          ? 'custom'
                          : controller.selectedPeriod.value,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      icon: Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '7',
                          child: Text('7 jours'),
                        ),
                        const DropdownMenuItem(
                          value: '30',
                          child: Text('30 jours'),
                        ),
                        const DropdownMenuItem(
                          value: '90',
                          child: Text('90 jours'),
                        ),
                        const DropdownMenuItem(
                          value: 'custom',
                          child: Text('Personnalisé'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          if (value == 'custom') {
                            controller.useCustomDateRange.value = true;
                          } else {
                            controller.updatePeriod(value);
                          }
                        }
                      },
                    )),
              ),
            ],
          ),
          // Filtre par dates personnalisées
          Obx(() {
            if (controller.useCustomDateRange.value) {
              final startDate = controller.startDate.value;
              final endDate = controller.endDate.value;
              final isValid = _isDateRangeValid(startDate, endDate);
              final hasError = startDate != null &&
                  endDate != null &&
                  !_isDateRangeValid(startDate, endDate);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSizes.md),
                  // Message d'erreur si dates invalides
                  if (hasError)
                    Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.warning_2,
                            size: 16,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              'La date de début doit être antérieure à la date de fin',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Champs de date avec Wrap pour responsive
                  Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Date de début
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: endDate ?? DateTime.now(),
                              locale: const Locale('fr', 'FR'),
                            );
                            if (pickedDate != null) {
                              controller.startDate.value = pickedDate;
                              // Si la date de fin est avant la nouvelle date de début, la réinitialiser
                              if (endDate != null &&
                                  pickedDate.isAfter(endDate)) {
                                controller.endDate.value = null;
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: hasError
                                    ? Colors.red
                                    : Colors.blue.shade400.withValues(alpha: 0.3),
                                width: hasError ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: hasError
                                  ? Colors.red.withValues(alpha: 0.05)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.calendar_1,
                                  size: 16,
                                  color: hasError
                                      ? Colors.red
                                      : Colors.blue.shade400,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Flexible(
                                  child: Text(
                                    startDate != null
                                        ? _formatDate(startDate)
                                        : 'Date de début',
                                    style: TextStyle(
                                      color: startDate != null
                                          ? (dark ? Colors.white : Colors.black)
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Séparateur "à"
                      Text(
                        'à',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      // Date de fin
                      Flexible(
                        child: InkWell(
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime(2020),
                              lastDate: DateTime.now(),
                              locale: const Locale('fr', 'FR'),
                            );
                            if (pickedDate != null) {
                              controller.endDate.value = pickedDate;
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: hasError
                                    ? Colors.red
                                    : Colors.blue.shade400.withValues(alpha: 0.3),
                                width: hasError ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: hasError
                                  ? Colors.red.withValues(alpha: 0.05)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Iconsax.calendar_1,
                                  size: 16,
                                  color: hasError
                                      ? Colors.red
                                      : Colors.blue.shade400,
                                ),
                                const SizedBox(width: AppSizes.xs),
                                Flexible(
                                  child: Text(
                                    endDate != null
                                        ? _formatDate(endDate)
                                        : 'Date de fin',
                                    style: TextStyle(
                                      color: endDate != null
                                          ? (dark ? Colors.white : Colors.black)
                                          : Colors.grey,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bouton effacer
                      if (startDate != null || endDate != null)
                        IconButton(
                          icon: Icon(
                            Iconsax.close_circle,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () => controller.clearCustomDateRange(),
                          tooltip: 'Effacer',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  // Bouton Valider
                  if (startDate != null && endDate != null) ...[
                    const SizedBox(height: AppSizes.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isValid
                            ? () {
                                controller.updateCustomDateRange(
                                  startDate,
                                  endDate,
                                );
                                TLoaders.successSnackBar(
                                  title: 'Succès',
                                  message: 'Période personnalisée appliquée',
                                );
                              }
                            : null,
                        icon: const Icon(Iconsax.tick_circle, size: 18),
                        label: const Text('Valider'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
