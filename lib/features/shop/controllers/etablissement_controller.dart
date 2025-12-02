import 'package:caferesto/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/etablissement/etablissement_repository.dart';
import '../../../utils/constants/enums.dart';
import '../../profil/controllers/user_controller.dart';
import '../models/etablissement_model.dart';

class EtablissementController extends GetxController {
  final EtablissementRepository repo;
  final UserController userController = Get.find<UserController>();
  final _isLoading = false.obs;
  final etablissements = <Etablissement>[].obs;
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final selectedFilter = 'Récents'.obs;
  bool get isLoading => _isLoading.value;

  EtablissementController(this.repo);

  @override
  void onInit() {
    super.onInit();
    _subscribeToRealtimeEtablissements();
    fetchApprovedEtablissements(); // Changed from getTousEtablissements()
  }

  @override
  void onClose() {
    _unsubscribeFromRealtime();
    super.onClose();
  }

  void _subscribeToRealtimeEtablissements() {
    _channel = _supabase.channel('approved_etablissements_changes');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'etablissements',
      callback: (payload) {
        final type = payload.eventType;
        final newData = payload.newRecord;
        final oldData = payload.oldRecord;
        final etab = Etablissement.fromJson(
          type == PostgresChangeEvent.delete ? oldData : newData,
        );

        // Only handle approved establishments
        if (etab.statut != StatutEtablissement.approuve) {
          // If status changed from approved to something else, remove it
          if (type == PostgresChangeEvent.update) {
            etablissements.removeWhere((e) => e.id == etab.id);
            etablissements.refresh();
          }
          return;
        }

        if (type == PostgresChangeEvent.insert) {
          etablissements.add(etab);
        }
        if (type == PostgresChangeEvent.update) {
          final index = etablissements.indexWhere((e) => e.id == etab.id);
          if (index != -1) {
            etablissements[index] = etab;
          } else {
            // If it became approved, add it
            etablissements.add(etab);
          }
        }
        if (type == PostgresChangeEvent.delete) {
          etablissements.removeWhere((e) => e.id == etab.id);
        }
        etablissements.refresh();
      },
    );
    _channel!.subscribe();
  }

  Future<List<Etablissement>> fetchApprovedEtablissements() async {
    debugPrint(
        "🟢 [EtablissementController] Chargement des établissements approuvés");
    try {
      _isLoading.value = true;
      final data = await repo.getApprovedEtablissements();
      etablissements.assignAll(data);
      return data;
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur chargement établissements: $e');
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  void _unsubscribeFromRealtime() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  Future<String?> uploadEtablissementImage(XFile file) async {
    try {
      return repo.uploadEtablissementImage(file);
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur upload image: $e');
      return null;
    }
  }
}
