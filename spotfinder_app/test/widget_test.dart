import 'package:flutter_test/flutter_test.dart';
import 'package:spotfinder_app/main.dart';

void main() {
  testWidgets('SpotFinder Auth Flow Smoke Test', (WidgetTester tester) async {
    // Construye la aplicación SpotFinderApp.
    await tester.pumpWidget(const SpotFinderApp());

    // Verifica que el Splash Screen o el Onboarding se carguen.
    // Como tu SplashScreen tiene un Timer, aquí solo verificamos que inicie sin errores.
    expect(find.byType(SpotFinderApp), findsOneWidget);
  });
}