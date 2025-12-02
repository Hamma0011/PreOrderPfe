class TValidator {
  static String? validateEmptyText(String? fildName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fildName est requis.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis.';
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Addresse email invalide.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe est requis.';
    }

    if (value.length < 6) {
      return 'Mot de passe doit contenir au moins 6 caractères.';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mot de passe doit contenir au moins une lettre majuscule.';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mot de passe doit contenir au moins un caractère numérique.';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Mot de passe doit contenir au moins un caractère spécial.';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro de téléphone requis.';
    }

    final phoneRegExp = RegExp(r'^\d{8}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Numéro de téléphone invalide (8 nombres requis).';
    }

    return null;
  }

}
