import 'package:caferesto/data/repositories/authentication/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Test minimaliste qui vérifie juste que le code compile et s'initialise
void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('AuthenticationRepository peut être créé', () {
    // Ce test vérifie simplement que la classe peut être instanciée
    // sans erreurs de compilation
    expect(() => AuthenticationRepository(), returnsNormally);
  });

  test('AuthenticationRepository.instance retourne une instance', () {
    // Arrange
    Get.put<AuthenticationRepository>(AuthenticationRepository());

    // Act
    final instance = Get.find<AuthenticationRepository>();

    // Assert
    expect(instance, isNotNull);
    expect(instance, isA<AuthenticationRepository>());
  });
}
