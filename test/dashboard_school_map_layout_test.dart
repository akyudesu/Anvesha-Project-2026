import 'package:fire_evacuation_app/features/dashboard/presentation/widgets/dashboard_school_map_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('campus map lays out inside a vertically scrolling page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: CampusMapHazardApp()),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
