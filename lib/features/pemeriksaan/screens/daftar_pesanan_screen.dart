import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';

/// Halaman utama Modul B (Osman).
// Masih isi sementara dari kerangka. Ganti `body` sama daftar pesanan (issue 09),
// tapi `ModuleScaffold`-nya biarin biar drawer tetap nyambung.
class DaftarPesananScreen extends StatelessWidget {
  const DaftarPesananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.pemeriksaan,
      body: EmptyView(
        icon: WijiMenu.pemeriksaan.icon,
        title: 'Daftar pesanan lagi dibikin',
        message: 'Nanti di sini muncul pesanan pemeriksaan tanah kamu beserta statusnya.',
      ),
    );
  }
}
