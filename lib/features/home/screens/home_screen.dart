import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/app_drawer.dart';
import 'package:wiji_mobile/features/home/widgets/menu_card.dart';

/// Beranda: halaman pertama dan halaman paling bawah di tumpukan navigasi.
// Nanti (issue 14) isinya disesuaiin sama peran dan ditambah ringkasan data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wiji')),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(WijiSpacing.md),
          children: [
            const _Sambutan(),
            const SizedBox(height: WijiSpacing.lg),
            Text(
              'Mau ngapain hari ini?',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: WijiSpacing.sm),
            const _DaftarMenu(),
          ],
        ),
      ),
    );
  }
}

class _Sambutan extends StatelessWidget {
  const _Sambutan();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: WijiColors.forest,
        borderRadius: WijiTheme.radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang di Wiji',
              style: textTheme.titleLarge?.copyWith(
                color: WijiColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: WijiSpacing.sm),
            Text(
              'Cek kondisi tanah lahanmu, terus temuin tanaman yang cocok '
              'buat ngerawat atau mulihin tanahnya.',
              style: textTheme.bodyMedium?.copyWith(color: WijiColors.mint),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaftarMenu extends StatelessWidget {
  const _DaftarMenu();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // HP: satu kolom. Tablet atau browser lebar: dua sampai tiga kolom.
        final kolom = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final lebarKartu =
            (constraints.maxWidth - WijiSpacing.md * (kolom - 1)) / kolom;
        return Wrap(
          spacing: WijiSpacing.md,
          runSpacing: WijiSpacing.md,
          children: [
            for (final menu in WijiMenu.values)
              SizedBox(
                width: lebarKartu,
                child: MenuCard(menu: menu),
              ),
          ],
        );
      },
    );
  }
}
