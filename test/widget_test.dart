import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/screens/home_screen.dart';
import 'package:wiji_mobile/features/home/widgets/menu_card.dart';
import 'package:wiji_mobile/main.dart';

void main() {
  testWidgets('aplikasi kebuka di beranda dengan kartu tiap modul', (
    tester,
  ) async {
    // Ukuran HP biasa (360 x 780).
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const WijiApp());

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Wiji'), findsOneWidget);
    for (final menu in WijiMenu.values) {
      expect(find.widgetWithText(MenuCard, menu.label), findsOneWidget);
    }
  });

  testWidgets('beranda tetap aman pas teks HP diperbesar dua kali', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: const WijiApp(),
      ),
    );

    // Nggak ada overflow; kartu terakhir masih bisa dicapai pakai scroll.
    await tester.scrollUntilVisible(
      find.widgetWithText(MenuCard, WijiMenu.values.last.label),
      200,
    );
    expect(tester.takeException(), isNull);
  });
}
