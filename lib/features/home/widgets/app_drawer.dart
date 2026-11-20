import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/home/menu.dart';

/// Drawer yang dipakai di beranda dan halaman utama tiap modul.
// Nanti (issue 14) menunya disaring sesuai peran: petugas nggak perlu menu lahan, dst.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.current});

  /// Menu yang lagi dibuka. Kosong artinya lagi di beranda.
  final WijiMenu? current;

  void _pilih(BuildContext context, WijiMenu? tujuan) {
    Scaffold.of(context).closeDrawer();
    bukaMenu(context, dari: current, ke: tujuan);
  }

  Widget _item(
    BuildContext context, {
    required WijiMenu? tujuan,
    required String label,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: current == tujuan,
      onTap: () => _pilih(context, tujuan),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const _DrawerHeader(),
            const SizedBox(height: WijiSpacing.sm),
            _item(
              context,
              tujuan: null,
              label: 'Beranda',
              icon: Icons.home_outlined,
            ),
            for (final menu in WijiMenu.values)
              _item(context, tujuan: menu, label: menu.label, icon: menu.icon),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Tingginya ikut isi, biar nggak kepotong pas ukuran teks HP diperbesar.
    return ColoredBox(
      color: WijiColors.forest,
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                'Wiji',
                style: textTheme.headlineSmall?.copyWith(
                  color: WijiColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: WijiSpacing.xs),
            Text(
              'Kenali tanahmu, tanam yang cocok.',
              style: textTheme.bodyMedium?.copyWith(color: WijiColors.mint),
            ),
          ],
        ),
      ),
    );
  }
}
