import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';

/// Halaman utama Modul A (Rania).
// Masih isi sementara dari kerangka. Ganti `body` sama daftar lahan (issue 08),
// tapi `ModuleScaffold`-nya biarin biar drawer tetap nyambung.
class DaftarLahanScreen extends StatelessWidget {
  const DaftarLahanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.lahan,
      body: EmptyView(
        icon: WijiMenu.lahan.icon,
        title: 'Daftar lahan lagi dibikin',
        message: 'Nanti di sini muncul semua lahan kamu, plus tombol buat nambah lahan baru.',
      ),
    );
  }
}
