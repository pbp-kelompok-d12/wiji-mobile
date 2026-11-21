import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';

/// Kartu ringkas satu tanaman pada daftar Katalog.
class TanamanCard extends StatelessWidget {
  const TanamanCard({
    super.key,
    required this.tanaman,
    required this.onTap,
    this.isFavorit = false,
    this.onToggleFavorit,
  });

  final Tanaman tanaman;
  final VoidCallback onTap;
  final bool isFavorit;
  final VoidCallback? onToggleFavorit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFitoremediasi = tanaman.jenis == JenisTanaman.fitoremediasi;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(WijiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tanaman.nama,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (tanaman.namaIlmiah.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            tanaman.namaIlmiah,
                            style: textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: WijiColors.inkSoft,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onToggleFavorit != null)
                    IconButton(
                      onPressed: onToggleFavorit,
                      tooltip: isFavorit
                          ? 'Hapus dari favorit'
                          : 'Tandai favorit',
                      icon: Icon(
                        isFavorit ? Icons.favorite : Icons.favorite_border,
                        color: isFavorit ? WijiColors.brick : WijiColors.inkSoft,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: WijiSpacing.sm),
              Wrap(
                spacing: WijiSpacing.xs,
                runSpacing: WijiSpacing.xs,
                children: [
                  _Badge(
                    label: tanaman.jenis.label,
                    background: isFitoremediasi
                        ? WijiColors.sand
                        : WijiColors.leaf,
                    foreground: isFitoremediasi
                        ? WijiColors.clay
                        : WijiColors.mossDeep,
                  ),
                  if (tanaman.tersediaDiIndonesia)
                    const _Badge(
                      label: 'Tersedia di Indonesia',
                      background: WijiColors.mint,
                      foreground: WijiColors.forest,
                    ),
                  if (tanaman.diarsipkan)
                    const _Badge(
                      label: 'Diarsipkan',
                      background: WijiColors.brickBg,
                      foreground: WijiColors.brick,
                    ),
                ],
              ),
              if (tanaman.fungsi.isNotEmpty) ...[
                const SizedBox(height: WijiSpacing.sm),
                Text(
                  tanaman.fungsi,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: WijiColors.inkSoft,
                  ),
                ),
              ],
              if (tanaman.tujuan.isNotEmpty) ...[
                const SizedBox(height: WijiSpacing.sm),
                Wrap(
                  spacing: WijiSpacing.xs,
                  runSpacing: WijiSpacing.xs,
                  children: [
                    for (final tujuan in tanaman.tujuan.take(3))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: WijiSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: WijiColors.paper,
                          borderRadius: WijiTheme.radius,
                          border: Border.all(color: WijiColors.line),
                        ),
                        child: Text(
                          tujuan.nama,
                          style: textTheme.labelSmall?.copyWith(
                            color: WijiColors.inkSoft,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WijiSpacing.sm,
        vertical: WijiSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
