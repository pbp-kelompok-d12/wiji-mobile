import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';

/// Halaman utama Modul C (Nadya).
// Masih isi sementara dari kerangka. Ganti `body` sama daftar hasil pemeriksaan (issue 10),
// tapi `ModuleScaffold`-nya biarin biar drawer tetap nyambung.
class DaftarHasilScreen extends StatelessWidget {
  const DaftarHasilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.hasil,
      body: EmptyView(
        icon: WijiMenu.hasil.icon,
        title: 'Daftar hasil lagi dibikin',
        message: 'Nanti di sini muncul hasil pemeriksaan tanah dari tiap lahan kamu.',
      ),
    );
  }
}
