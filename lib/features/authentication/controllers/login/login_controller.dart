import 'package:caferesto/features/authentication/screens/signup/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../profil/controllers/user_controller.dart';

class LoginController extends GetxController {

  final userController = Get.find<UserController>();
  final authRepo = Get.find<AuthenticationRepository>();
  final NetworkManager networkManager = Get.find<NetworkManager>();

  /// Variables
  final email = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  
  final _rememberMe = false.obs;
  final localStorage = GetStorage();

  bool get rememberMe => _rememberMe.value;

  @override
  void onInit() {
    email.text = localStorage.read("REMEMBER_ME_EMAIL") ?? '';
    super.onInit();
  }

  void emailOtpSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialog(
        "Envoi du code OTP...",
        TImages.docerAnimation,
      );

      // Vérifier connexion internet
      final isConnected = await networkManager.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Valider formulaire
      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      // Sauvegarder email si "Remember Me"
      if (_rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
      }

      // Envoi OTP via AuthenticationRepository
      final otpSent =
          await authRepo.sendOtp(email.text.trim());

      TFullScreenLoader.stopLoading();

      if (!otpSent) {
        return;
      }
      // Aller vers l'écran OTP
      Get.to(() => OTPVerificationScreen(
            email: email.text.trim(),
            userData: {},
            isSignupFlow: false,
          ));
      TLoaders.successSnackBar(
          title: 'OTP envoyé !', message: 'Vérifier votre boîte e-mail');
    } catch (e,st) {
      TFullScreenLoader.stopLoading();
      final errorMessage = e.toString();
      if (errorMessage.contains("you can only request this")) {
        TLoaders.errorSnackBar(
          title: "Trop de demandes",
          message: "Attendez avant de demander un nouveau code OTP.",
        );
      } else if (errorMessage.contains("otp_disabled") ||
          errorMessage.contains("signups not allowed")) {
        TLoaders.errorSnackBar(
          title: "Email inconnu",
          message: "Aucun utilisateur n'est associé à cet email.",
        );
      } else {
        TLoaders.errorSnackBar(
          title: 'Erreur Login !',
          message: errorMessage + st.toString(),
        );
        debugPrintStack(stackTrace: st);
      }
    }
  }
}
