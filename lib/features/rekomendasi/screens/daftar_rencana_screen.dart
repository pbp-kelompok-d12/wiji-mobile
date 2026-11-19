import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';

/// Halaman utama Modul E (Piedra).
// Masih isi sementara dari kerangka. Ganti `body` sama daftar rencana tanam (issue 12),
// tapi `ModuleScaffold`-nya biarin biar drawer tetap nyambung.
class DaftarRencanaScreen extends StatelessWidget {
  const DaftarRencanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.rekomendasi,
      body: EmptyView(
        icon: WijiMenu.rekomendasi.icon,
        title: 'Rencana tanam lagi dibikin',
        message: 'Nanti di sini muncul rencana tanam kamu, plus jalan ke rekomendasi tanaman per lahan.',
      ),
    );
  }
}
