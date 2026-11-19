import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';

/// Halaman utama Modul D (Yosua).
// Masih isi sementara dari kerangka. Ganti `body` sama katalog tanaman dari API (issue 11),
// tapi `ModuleScaffold`-nya biarin biar drawer tetap nyambung.
class KatalogScreen extends StatelessWidget {
  const KatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.katalog,
      body: EmptyView(
        icon: WijiMenu.katalog.icon,
        title: 'Katalog lagi dibikin',
        message: 'Nanti di sini kamu bisa cari tanaman dan liat kegunaannya.',
      ),
    );
  }
}
