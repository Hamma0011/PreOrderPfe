import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../features/shop/models/etablissement_model.dart';
import '../../../features/shop/models/produit_model.dart';
import '../../../features/shop/models/statut_etablissement_model.dart';
import '../../../utils/constants/enums.dart';

class EtablissementRepository {
  final SupabaseClient _db = Supabase.instance.client;
  final _table = 'etablissements';

  // Création avec gestion d'erreur
  Future<String?> createEtablissement(Etablissement etablissement) async {
    try {
      final data = etablissement.toJson()..['statut'] = 'en_attente';

      final response = await _db
          .from(_table)
          .insert(data)
          .select('*, id_owner:users!id_owner(*)') // Jointure explicite
          .single();
      return response['id']?.toString();
    } catch (e, stack) {
      debugPrint('Erreur création établissement: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  // Mise à jour avec gestion d'erreur
  Future<bool> updateEtablissement(
      String? id, Map<String, dynamic> data) async {
    try {
      if (id == null || id.isEmpty) {
        throw 'ID établissement manquant';
      }

      debugPrint('Mise à jour établissement $id: $data');

      // S'assurer que le statut est bien converti
      if (data.containsKey('statut') && data['statut'] is String) {
        // Déjà converti par le contrôleur
      }

      await _db
          .from(_table)
          .update(data)
          .eq('id', id)
          .select('*, id_owner:users!id_owner(*)') // Jointure explicite
          .single();
      debugPrint('Établissement $id mis à jour avec succès');
      return true;
    } catch (e, stack) {
      debugPrint('Erreur mise à jour établissement $id: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  // Changement de statut
  Future<bool> changeStatut(String id, StatutEtablissement newStatut) async {
    try {
      await _db.from(_table).update({'statut': newStatut.value}).eq('id', id);
      return true;
    } catch (e, stack) {
      debugPrint('Erreur changement statut établissement $id: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  // Récupérer tous les établissements avec le nombre de produits
  Future<List<Etablissement>> getAllEtablissements() async {
    try {
      // Récupérer tous les établissements
      final response = await _db
          .from(_table)
          .select('*, id_owner:users!id_owner(*)') // Jointure explicite
          .order('created_at', ascending: false);

      final etablissements = response
          .map<Etablissement>((json) => Etablissement.fromJson(json))
          .toList();

      if (etablissements.isEmpty) return etablissements;

      // Optimisation: Compter tous les produits en UNE seule requête batch
      final etablissementIds = etablissements
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      if (etablissementIds.isNotEmpty) {
        try {
          // Récupérer tous les produits en une seule requête
          final countsResponse = await _db
              .from('produits')
              .select('etablissement_id')
              .inFilter('etablissement_id', etablissementIds);

          // Compter les produits par établissement
          final productCounts = <String, int>{};
          for (var product in countsResponse as List) {
            final etabId = product['etablissement_id']?.toString() ?? '';
            if (etabId.isNotEmpty) {
              productCounts[etabId] = (productCounts[etabId] ?? 0) + 1;
            }
          }

          // Assigner les comptages
          for (int i = 0; i < etablissements.length; i++) {
            final etablissement = etablissements[i];
            if (etablissement.id != null && etablissement.id!.isNotEmpty) {
              final count = productCounts[etablissement.id!] ?? 0;
              etablissements[i] =
                  etablissement.copyWith(nbProduits: count.toDouble());
            }
          }
        } catch (e) {
          debugPrint('Erreur comptage produits batch: $e');
          // En cas d'erreur, laisser nbProduits à 0 pour tous
        }
      }

      return etablissements;
    } catch (e, stack) {
      debugPrint('Erreur récupération établissements: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  // Récupérer les établissements par propriétaire avec le nombre de produits
  Future<List<Etablissement>> getEtablissementsByOwner(String ownerId) async {
    try {
      final response = await _db
          .from(_table)
          .select('*, id_owner:users!id_owner(*)') // Jointure explicite
          .eq('id_owner', ownerId)
          .order('created_at', ascending: false);

      final etablissements = response
          .map<Etablissement>((json) => Etablissement.fromJson(json))
          .toList();

      if (etablissements.isEmpty) return etablissements;

      // Optimisation: Compter tous les produits en UNE seule requête batch
      final etablissementIds = etablissements
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      if (etablissementIds.isNotEmpty) {
        try {
          // Récupérer tous les produits en une seule requête
          final countsResponse = await _db
              .from('produits')
              .select('etablissement_id')
              .inFilter('etablissement_id', etablissementIds);

          // Compter les produits par établissement
          final productCounts = <String, int>{};
          for (var product in countsResponse as List) {
            final etabId = product['etablissement_id']?.toString() ?? '';
            if (etabId.isNotEmpty) {
              productCounts[etabId] = (productCounts[etabId] ?? 0) + 1;
            }
          }

          // Assigner les comptages
          for (int i = 0; i < etablissements.length; i++) {
            final etablissement = etablissements[i];
            if (etablissement.id != null && etablissement.id!.isNotEmpty) {
              final count = productCounts[etablissement.id!] ?? 0;
              etablissements[i] =
                  etablissement.copyWith(nbProduits: count.toDouble());
            }
          }
        } catch (e) {
          debugPrint('Erreur comptage produits batch: $e');
          // En cas d'erreur, laisser nbProduits à 0 pour tous
        }
      }

      return etablissements;
    } catch (e, stack) {
      debugPrint('Erreur récupération établissements propriétaire: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

// Add after getEtablissementsByOwner method (around line 192)

// Récupérer uniquement les établissements approuvés (pour le store)
  Future<List<Etablissement>> getApprovedEtablissements() async {
    try {
      final response = await _db
          .from(_table)
          .select('*, id_owner:users!id_owner(*)')
          .eq('statut', 'approuve')
          .order('created_at', ascending: false);

      final etablissements = response
          .map<Etablissement>((json) => Etablissement.fromJson(json))
          .toList();

      if (etablissements.isEmpty) return etablissements;

      // Compter les produits
      final etablissementIds = etablissements
          .map((e) => e.id)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      if (etablissementIds.isNotEmpty) {
        try {
          final countsResponse = await _db
              .from('produits')
              .select('etablissement_id')
              .inFilter('etablissement_id', etablissementIds);

          final productCounts = <String, int>{};
          for (var product in countsResponse as List) {
            final etabId = product['etablissement_id']?.toString() ?? '';
            if (etabId.isNotEmpty) {
              productCounts[etabId] = (productCounts[etabId] ?? 0) + 1;
            }
          }

          for (int i = 0; i < etablissements.length; i++) {
            final etablissement = etablissements[i];
            if (etablissement.id != null && etablissement.id!.isNotEmpty) {
              final count = productCounts[etablissement.id!] ?? 0;
              etablissements[i] =
                  etablissement.copyWith(nbProduits: count.toDouble());
            }
          }
        } catch (e) {
          debugPrint('Erreur comptage produits batch: $e');
        }
      }

      return etablissements;
    } catch (e, stack) {
      debugPrint('Erreur récupération établissements approuvés: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  // Suppression avec gestion des dépendances
  Future<bool> deleteEtablissement(String id) async {
    try {
      // 1. Supprimer les horaires associés
      try {
        await _db.from('horaires').delete().eq('etablissement_id', id);
      } catch (e) {
        debugPrint('Aucun horaire à supprimer: $e');
      }

      // 2. Supprimer les produits associés
      try {
        await _db.from(_table).delete().eq('etablissement_id', id);
      } catch (e) {
        debugPrint('Aucun produit à supprimer: $e');
      }

      // 3. Supprimer l'établissement
      await _db.from(_table).delete().eq('id', id);
      return true;
    } catch (e, stack) {
      debugPrint('Erreur suppression établissement $id: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  Future<List<ProduitModel>> getProduitsEtablissement(
      String etablissementId) async {
    try {
      final response = await _db
          .from(_table)
          .select('*')
          .eq('id_etablissement', etablissementId);

      final produits =
          (response as List).map((p) => ProduitModel.fromJson(p)).toList();
      debugPrint('produits $produits');
      return produits;
    } catch (e) {
      debugPrint('Erreur getProduitsEtablissement: $e');
      rethrow;
    }
  }

  Future<bool> canUserCreateEtablissement(String userId) async {
    try {
      final response = await _db
          .from('etablissements')
          .select('id')
          .eq('id_owner', userId)
          .limit(1);

      return response.isEmpty; // true si l'utilisateur n'a pas d'établissement
    } catch (e) {
      debugPrint('Erreur vérification établissement: $e');
      return false;
    }
  }

  Future<String?> uploadEtablissementImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final filePath =
          'etablissements/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await _db.storage.from('etablissements').uploadBinary(filePath, bytes);
      return _db.storage.from('etablissements').getPublicUrl(filePath);
    } catch (e) {
      throw Exception('Erreur upload image: $e');
    }
  }
}
