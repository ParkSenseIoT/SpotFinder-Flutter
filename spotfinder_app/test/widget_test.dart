import 'package:flutter_test/flutter_test.dart';
import 'package:spotfinder_app/core/di/injection.dart';
import 'package:spotfinder_app/main.dart';

void main() {
  setUpAll(() async {
    await configureDependencies();
  });

  testWidgets('SpotFinder boots and renders splash', (tester) async {
    await tester.pumpWidget(const SpotFinderApp());
    await tester.pump();
    expect(find.byType(SpotFinderApp), findsOneWidget);
  });
}
