/* --
      LIST OF Enums
      They cannot be created inside a class.
-- */

/// Switch of Custom Brand-Text-Size Widget
enum ProductType { single, variable }

enum TexAppSizes { small, medium, large }

enum OrderStatus { pending, cancelled, delivered, preparing, ready, refused }

enum StatutEtablissement { en_attente, approuve, rejete }

enum ProduitFilter { all, stockables, nonStockables, rupture }

enum CategoryFilter { all, featured }

enum UserRole {
  Client('Client', 'Client'),
  Gerant('Gérant', 'Gérant');

  final String dbValue;
  final String label;
  const UserRole(this.dbValue, this.label);

  static UserRole? fromDb(String? value) {
    if (value == null) return null;
    return UserRole.values.firstWhere(
      (role) => role.dbValue == value,
      orElse: () => UserRole.Client,
    );
  }
}

enum UserGender {
  Homme('Homme', 'Homme'),
  Femme('Femme', 'Femme');

  final String dbValue;
  final String label;
  const UserGender(this.dbValue, this.label);

  static UserGender? fromDb(String? value) {
    if (value == null) return null;
    return UserGender.values.firstWhere(
      (role) => role.dbValue == value,
      orElse: () => UserGender.Homme,
    );
  }
}

enum JourSemaine {
  lundi('lundi'),
  mardi('mardi'),
  mercredi('mercredi'),
  jeudi('jeudi'),
  vendredi('vendredi'),
  samedi('samedi'),
  dimanche('dimanche');

  const JourSemaine(this.valeur);
  final String valeur;

  factory JourSemaine.fromString(String valeur) {
    switch (valeur) {
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
        throw ArgumentError('Jour inconnu: $valeur');
    }
  }

  @override
  String toString() => valeur;
}

