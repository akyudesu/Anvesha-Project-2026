import 'package:fire_evacuation_app/main.dart';
import 'package:fire_evacuation_app/features/dashboard/presentation/widgets/dashboard_school_map_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in const [Size(390, 844), Size(768, 820), Size(1280, 800)]) {
    testWidgets('login screen renders at ${size.width}px', (tester) async {
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const MyApp());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('campus map uses the provided image asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DashboardSchoolMapCard()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/unnamed.png',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
