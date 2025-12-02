import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/profil/models/address_model.dart';
import '../authentication/authentication_repository.dart';

class AddressRepository extends GetxController {

  final _db = Supabase.instance.client;
  final String _table = 'addresses';
  final controller = Get.find<AuthenticationRepository>();

  /// Extraire les addresses utilisateur; Ajouter addresse; Mettre à jour adresse; Supprimer adresse
  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final userId = controller.authUser!.id;
      if (userId.isEmpty) {
        throw ('Unable to find user information. Try again in few minutes');
      }

      final response = await _db.from(_table).select().eq('user_id', userId);

      // response is List<dynamic>
      final data = response as List<dynamic>;
      return data
          .map((row) => AddressModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching address information, try again later';
    }
  }

  Future<String> addAddress(AddressModel address) async {
    try {
      final userId = controller.authUser!.id;

      final response = await _db
          .from(_table)
          .insert({
            ...address.toJson(),
            'user_id': userId,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e, s) {
      debugPrint('Supabase insert error: $e\n$s');
      rethrow;
    }
  }

  Future<void> selectOtherAddress(String addressId, bool selected) async {
    try {
      final userId = controller.authUser!.id;

      await _db
          .from(_table)
          .update({'selected_address': selected})
          .eq('id', addressId)
          .eq('user_id', userId);
    } catch (e) {
      throw 'Something went wrong while updating address information, try again later';
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final userId = controller.authUser!.id;
      if (userId.isEmpty) {
        throw ('Unable to find user information. Try again in few minutes');
      }

      await _db.from(_table).delete().eq('id', addressId).eq('user_id', userId);
    } catch (e) {
      throw 'Something went wrong while deleting address information, try again later';
    }
  }
}
