import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/home/menu.dart';

/// Kartu menu di beranda. Ditekan langsung buka halaman modulnya.
class MenuCard extends StatelessWidget {
  const MenuCard({super.key, required this.menu});

  final WijiMenu menu;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => bukaMenu(context, dari: null, ke: menu),
        child: Padding(
          padding: const EdgeInsets.all(WijiSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: WijiColors.leaf,
                child: Icon(menu.icon, color: WijiColors.moss),
              ),
              const SizedBox(width: WijiSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.label,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: WijiSpacing.xs),
                    Text(
                      menu.keterangan,
                      style: textTheme.bodySmall?.copyWith(
                        color: WijiColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: WijiColors.inkSoft),
            ],
          ),
        ),
      ),
    );
  }
}
