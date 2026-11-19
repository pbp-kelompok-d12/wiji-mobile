import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/screens/home_screen.dart';
import 'package:wiji_mobile/features/home/widgets/menu_card.dart';
import 'package:wiji_mobile/main.dart';

Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const WijiApp());
}

Future<void> pilihDiDrawer(WidgetTester tester, String label) async {
  await tester.tap(find.byType(DrawerButton));
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(Drawer), matching: find.text(label)),
  );
  await tester.pumpAndSettle();
}

NavigatorState navigator(WidgetTester tester) =>
    tester.state<NavigatorState>(find.byType(Navigator));

/// Ngecek halaman yang lagi kebuka itu halaman modul [menu].
void expectHalaman(WijiMenu menu) {
  expect(
    find.descendant(of: find.byType(AppBar), matching: find.text(menu.label)),
    findsOneWidget,
  );
  expect(find.byType(HomeScreen), findsNothing);
}

void main() {
  testWidgets('kartu beranda buka modulnya, back balik ke beranda', (
    tester,
  ) async {
    await pumpApp(tester);

    for (final menu in WijiMenu.values) {
      // Kartu bawah ada di luar layar HP, jadi di-scroll dulu.
      final kartu = find.widgetWithText(MenuCard, menu.label);
      await tester.ensureVisible(kartu);
      await tester.pumpAndSettle();
      await tester.tap(kartu);
      await tester.pumpAndSettle();
      expectHalaman(menu);

      navigator(tester).pop();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    }
  });

  testWidgets('drawer di beranda bisa buka tiap modul', (tester) async {
    await pumpApp(tester);

    for (final menu in WijiMenu.values) {
      await pilihDiDrawer(tester, menu.label);
      expectHalaman(menu);
      expect(navigator(tester).canPop(), isTrue);

      await pilihDiDrawer(tester, 'Beranda');
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(navigator(tester).canPop(), isFalse);
    }
  });

  testWidgets('pindah antarmodul lewat drawer nggak numpuk halaman', (
    tester,
  ) async {
    await pumpApp(tester);

    await pilihDiDrawer(tester, WijiMenu.lahan.label);
    await pilihDiDrawer(tester, WijiMenu.pemeriksaan.label);
    await pilihDiDrawer(tester, WijiMenu.katalog.label);
    expectHalaman(WijiMenu.katalog);

    // Satu kali back langsung ke beranda, bukan ke halaman sebelumnya.
    navigator(tester).pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navigator(tester).canPop(), isFalse);
  });

  testWidgets('milih menu yang lagi kebuka cuma nutup drawer', (tester) async {
    await pumpApp(tester);
    await pilihDiDrawer(tester, WijiMenu.hasil.label);

    await pilihDiDrawer(tester, WijiMenu.hasil.label);

    expectHalaman(WijiMenu.hasil);
    expect(find.byType(Drawer), findsNothing);
    expect(navigator(tester).canPop(), isTrue);
  });

  testWidgets('menu yang lagi kebuka ditandain di drawer', (tester) async {
    await pumpApp(tester);
    await pilihDiDrawer(tester, WijiMenu.rekomendasi.label);

    await tester.tap(find.byType(DrawerButton));
    await tester.pumpAndSettle();

    ListTile tile(String label) =>
        tester.widget<ListTile>(find.widgetWithText(ListTile, label));
    expect(tile(WijiMenu.rekomendasi.label).selected, isTrue);
    expect(tile('Beranda').selected, isFalse);
  });
}
