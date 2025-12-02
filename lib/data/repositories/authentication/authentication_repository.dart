import 'dart:async';

import 'package:caferesto/features/authentication/screens/signup/otp_verification_screen.dart';
import 'package:caferesto/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/authentication/screens/login/login.dart';
import '../../../features/profil/controllers/user_controller.dart';
import '../../../features/profil/models/user_model.dart';
import '../../../navigation_menu.dart';
import '../../../utils/popups/loaders.dart';
import '../user/user_repository.dart';

/// Exception interne pour identifier les utilisateurs bannis
/// Cette exception ne doit pas déclencher de snackbar dans le controller
class _BannedUserException implements Exception {
  @override
  String toString() => 'BannedUserException';
}

class AuthenticationRepository extends GetxController {
final userRepository = Get.find<UserRepository>();
final userController = Get.find<UserController>();
  final GetStorage deviceStorage = GetStorage();
  GoTrueClient get _auth => Supabase.instance.client.auth;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    _auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      final pending = deviceStorage.read('pending_user_data');

      try {
        if (event == AuthChangeEvent.signedIn && session != null) {
          // Si inscription en cours ne pas rediriger
          if (pending != null) return;

          // Connexion classique
          final userDetails = await userRepository.getUserDetails();

          // Vérifier si l'utilisateur est banni (sans afficher de snackbar ici,
          // car c'est déjà géré dans verifyOTP qui est le point d'entrée principal)
          if (userDetails != null && userDetails.isBanned) {
            // Déconnecter l'utilisateur banni silencieusement
            await _auth.signOut();
            Get.offAll(() => const LoginScreen());
            return;
          }

          if (userDetails == null) {
            await _auth.signOut();
            TLoaders.errorSnackBar(
              title: "Email inconnu",
              message:
                  "Aucun compte n'est associé à cet email. Veuillez vous inscrire.",
            );
            Get.offAll(() => const LoginScreen());
            return;
          }

          await TLocalStorage.init(session.user.id);
          Get.offAll(() => const NavigationMenu());
        }

        if (event == AuthChangeEvent.initialSession && session?.user == null) {
          Get.offAll(() => const LoginScreen());
          return;
        }
        if (event == AuthChangeEvent.signedOut) {
          await deviceStorage.remove('pending_user_data');
          Get.offAll(() => const LoginScreen());
        }
      } catch (e) {
        throw Exception('Erreur dans auth state change handler: $e');
      }
    });
    screenRedirect();
  }

  /// --- Redirection après démarrage
  Future<void> screenRedirect() async {
    final Map<String, dynamic> userData =
        (deviceStorage.read('pending_user_data')
                as Map<String, dynamic>?)?['user_data'] ??
            {};
    final user = authUser;
    final pending = deviceStorage.read('pending_user_data');

    if (user != null) {
      final meta = user.userMetadata ?? {};
      final emailVerified =
          (meta['email_verified'] == true) || (user.emailConfirmedAt != null);

      if (emailVerified) {
        // Vérifier si l'utilisateur est banni (sans afficher de snackbar ici,
        // car c'est déjà géré dans verifyOTP qui est le point d'entrée principal)
        final userDetails =
            await userRepository.getUserDetails(user.id);
        if (userDetails != null && userDetails.isBanned) {
          // Déconnecter l'utilisateur banni silencieusement
          await _auth.signOut();
          Get.offAll(() => const LoginScreen());
          return;
        }

        await TLocalStorage.init(user.id);
        Get.offAll(() => const NavigationMenu());
      } else {
        // OTP non vérifié
        final pendingMap = pending as Map<String, dynamic>?;
        final pendingEmail = pendingMap?['email'] as String? ?? user.email;
        final pendingUserData =
            pendingMap?['user_data'] as Map<String, dynamic>? ?? userData;

        Get.offAll(() => OTPVerificationScreen(
              email: pendingEmail ?? user.email!,
              userData: pendingUserData,
              isSignupFlow: pending != null,
            ));
      }
    } else {
      debugPrint("No user  SplashScreen will redirect");
    }
    debugPrint("[AuthRepo] screenRedirect() END\n");
  }

  /// --- Inscription avec OTP
  Future<void> signUpWithEmailOTP(
      String email, Map<String, dynamic> userData) async {
    try {
      await deviceStorage.write('pending_user_data', {
        'email': email,
        'user_data': userData,
      });

      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        data: userData,
        emailRedirectTo: null,
      );
    } catch (e) {
      throw Exception('Erreur signUpWithEmailOTP : $e');
    }
  }

  /// --- Connexion par OTP (email seulement)
  Future<bool> sendOtp(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// --- Renvoyer OTP
  Future<void> resendOTP(String email) async {
    try {
      await _auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
        emailRedirectTo: null,
      );
    } catch (e) {
      throw Exception('resendOTP erreur: $e');
    }
  }

  /// --- Vérification OTP (différenciée signup / login)
  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: otp,
      );

      final supabaseUser = response.user ?? _auth.currentUser;
      if (supabaseUser == null) {
        throw Exception(
            "Échec de la vérification OTP : aucun utilisateur retourné.");
      }

      final pending =
          deviceStorage.read('pending_user_data') as Map<String, dynamic>?;

      if (pending != null) {
        // --- CAS INSCRIPTION
        final savedUserData = Map<String, dynamic>.from(
          pending['user_data'] as Map? ?? {},
        );

        String get(Map<String, dynamic> m, String key) =>
            m[key]?.toString() ?? '';

        final userModel = UserModel(
          id: supabaseUser.id,
          email: supabaseUser.email ?? email,
          username: get(savedUserData, 'username'),
          firstName: get(savedUserData, 'first_name'),
          lastName: get(savedUserData, 'last_name'),
          phone: get(savedUserData, 'phone'),
          sex: get(savedUserData, 'sex'),
          role: get(savedUserData, 'role'),
          profileImageUrl: get(savedUserData, 'profile_image_url'),
        );

        await userRepository.saveUserRecord(userModel);
        await deviceStorage.remove('pending_user_data');
        await TLocalStorage.init(supabaseUser.id);
        await userController.fetchUserRecord();

        Get.offAll(() => const NavigationMenu());
      } else {
        // --- CAS CONNEXION
        final existingUser =
            await userRepository.getUserDetails(supabaseUser.id);

        if (existingUser == null) {
          throw Exception(
              "Aucun utilisateur associé à cet email. Veuillez vous inscrire.");
        }

        // Vérifier si l'utilisateur est banni
        if (existingUser.isBanned) {
          // Déconnecter l'utilisateur
          await _auth.signOut();
          // Afficher un seul snackbar pour l'utilisateur banni
          TLoaders.errorSnackBar(
            title: 'Accès refusé',
            message:
                "Votre compte a été banni. Veuillez contacter l'administrateur.",
          );
          Get.offAll(() => const LoginScreen());
          // Lancer une exception spéciale qui sera ignorée dans le controller
          throw _BannedUserException();
        }

        await TLocalStorage.init(supabaseUser.id);
        await userController.fetchUserRecord();

        Get.offAll(() => const NavigationMenu());
      }
    } catch (e) {
      // Si c'est une exception de bannissement, elle est déjà gérée (snackbar affiché)
      // Ne pas relancer cette exception pour éviter un double snackbar
      if (e is _BannedUserException) {
        return; // Sortir silencieusement car le snackbar est déjà affiché
      }

      // Pour les autres erreurs, afficher le snackbar dans le controller
      rethrow;
    }
  }

  /// --- Déconnexion
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await deviceStorage.remove('pending_user_data');
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      throw Exception('logout erreur: $e');
    }
  }
}
