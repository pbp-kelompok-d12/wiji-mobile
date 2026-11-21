import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/api/api_client.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';
import 'package:wiji_mobile/features/katalog/screens/form_tanaman_screen.dart';
import 'package:wiji_mobile/features/katalog/services/katalog_service.dart';

/// Halaman detail tanaman (Modul D).
///
/// Bisa dibuka dari Katalog atau dari Rekomendasi (Modul E) dengan `tanamanId`.
class DetailTanamanScreen extends StatefulWidget {
  const DetailTanamanScreen({
    super.key,
    required this.tanamanId,
    this.isAdmin = false,
    this.service,
    this.daftarTujuan = const [],
  });

  final int tanamanId;
  final bool isAdmin;
  final KatalogService? service;
  final List<TujuanTanaman> daftarTujuan;

  @override
  State<DetailTanamanScreen> createState() => _DetailTanamanScreenState();
}

class _DetailTanamanScreenState extends State<DetailTanamanScreen> {
  late final KatalogService _service;

  Tanaman? _tanaman;
  bool _loading = true;
  String? _error;
  bool _mutating = false;
  bool _adaPerubahan = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? KatalogService();
    _muatDetail();
  }

  Future<void> _muatDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final detail = await _service.ambilDetailTanaman(widget.tanamanId);
      if (!mounted) return;
      setState(() {
        _tanaman = detail;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _bukaFormUbah() async {
    final tanaman = _tanaman;
    if (tanaman == null) return;

    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => FormTanamanScreen(
          tanaman: tanaman,
          service: _service,
          daftarTujuan: widget.daftarTujuan,
        ),
      ),
    );

    if (!mounted) return;
    if (result == 'deleted') {
      Navigator.of(context).pop(true);
      return;
    }
    if (result != null) {
      _adaPerubahan = true;
      await _muatDetail();
    }
  }

  Future<void> _toggleArsip() async {
    final tanaman = _tanaman;
    if (tanaman == null || _mutating) return;

    setState(() => _mutating = true);
    try {
      if (tanaman.diarsipkan) {
        await _service.pulihkanTanaman(tanaman.id);
      } else {
        await _service.arsipkanTanaman(tanaman.id);
      }
      if (!mounted) return;
      _adaPerubahan = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tanaman.diarsipkan
                ? 'Tanaman dipulihkan dari arsip.'
                : 'Tanaman berhasil diarsipkan.',
          ),
        ),
      );
      await _muatDetail();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: WijiColors.brick, content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _mutating = false);
    }
  }

  Future<void> _hapus() async {
    final tanaman = _tanaman;
    if (tanaman == null || _mutating) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tanaman?'),
        content: Text(
          'Tanaman "${tanaman.nama}" akan dihapus permanen. '
          'Penghapusan ditolak kalau sudah dipakai rekomendasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: WijiColors.brick),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi != true || !mounted) return;

    setState(() => _mutating = true);
    try {
      await _service.hapusTanaman(tanaman.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanaman berhasil dihapus.')),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: WijiColors.brick, content: Text(e.message)),
      );
      setState(() => _mutating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).pop(_adaPerubahan);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_tanaman?.nama ?? 'Detail Tanaman'),
          actions: [
            ValueListenableBuilder<Set<int>>(
              valueListenable: FavoritTanamanStore.instance,
              builder: (context, favoritIds, _) {
                final isFav = favoritIds.contains(widget.tanamanId);
                return IconButton(
                  tooltip: isFav ? 'Hapus dari favorit' : 'Tandai favorit',
                  onPressed: () =>
                      FavoritTanamanStore.instance.toggle(widget.tanamanId),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                  ),
                );
              },
            ),
            if (widget.isAdmin && _tanaman != null)
              IconButton(
                tooltip: 'Ubah tanaman',
                onPressed: _mutating ? null : _bukaFormUbah,
                icon: const Icon(Icons.edit_outlined),
              ),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const LoadingView(message: 'Lagi ngambil detail tanaman...');
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _muatDetail);
    }
    final tanaman = _tanaman;
    if (tanaman == null) {
      return const EmptyView(
        title: 'Tanaman nggak ketemu',
        message: 'Data tanaman tidak tersedia.',
        icon: Icons.local_florist_outlined,
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final isFitoremediasi = tanaman.jenis == JenisTanaman.fitoremediasi;

    return RefreshIndicator(
      onRefresh: _muatDetail,
      child: ListView(
        padding: const EdgeInsets.all(WijiSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(WijiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tanaman.nama,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (tanaman.namaIlmiah.isNotEmpty) ...[
                    const SizedBox(height: WijiSpacing.xs),
                    Text(
                      tanaman.namaIlmiah,
                      style: textTheme.titleSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: WijiColors.inkSoft,
                      ),
                    ),
                  ],
                  const SizedBox(height: WijiSpacing.md),
                  Wrap(
                    spacing: WijiSpacing.xs,
                    runSpacing: WijiSpacing.xs,
                    children: [
                      _StatusChip(
                        label: tanaman.jenis.label,
                        background: isFitoremediasi
                            ? WijiColors.sand
                            : WijiColors.leaf,
                        foreground: isFitoremediasi
                            ? WijiColors.clay
                            : WijiColors.mossDeep,
                      ),
                      _StatusChip(
                        label: tanaman.tersediaDiIndonesia
                            ? 'Tersedia di Indonesia'
                            : 'Belum tersedia di Indonesia',
                        background: tanaman.tersediaDiIndonesia
                            ? WijiColors.mint
                            : WijiColors.paper,
                        foreground: tanaman.tersediaDiIndonesia
                            ? WijiColors.forest
                            : WijiColors.inkSoft,
                      ),
                      if (tanaman.diarsipkan)
                        const _StatusChip(
                          label: 'Diarsipkan',
                          background: WijiColors.brickBg,
                          foreground: WijiColors.brick,
                        ),
                    ],
                  ),
                  if (tanaman.tujuan.isNotEmpty) ...[
                    const SizedBox(height: WijiSpacing.md),
                    Text(
                      'Cocok untuk tujuan:',
                      style: textTheme.labelMedium?.copyWith(
                        color: WijiColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: WijiSpacing.xs),
                    Wrap(
                      spacing: WijiSpacing.xs,
                      runSpacing: WijiSpacing.xs,
                      children: [
                        for (final tujuan in tanaman.tujuan)
                          Chip(
                            label: Text(tujuan.nama),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: WijiSpacing.md),
          _InfoSection(
            title: 'Fungsi',
            icon: Icons.eco_outlined,
            content: tanaman.fungsi.isNotEmpty
                ? tanaman.fungsi
                : 'Belum ada keterangan fungsi.',
          ),
          const SizedBox(height: WijiSpacing.md),
          _InfoSection(
            title: 'Deskripsi',
            icon: Icons.description_outlined,
            content: tanaman.deskripsi.isNotEmpty
                ? tanaman.deskripsi
                : 'Belum ada deskripsi.',
          ),
          const SizedBox(height: WijiSpacing.md),
          _InfoSection(
            title: 'Kondisi Tumbuh',
            icon: Icons.wb_sunny_outlined,
            content: tanaman.kondisiTumbuh.isNotEmpty
                ? tanaman.kondisiTumbuh
                : 'Belum ada info kondisi tumbuh.',
          ),
          const SizedBox(height: WijiSpacing.md),
          _KontaminanSection(items: tanaman.kemampuanKontaminan),
          const SizedBox(height: WijiSpacing.md),
          _InfoSection(
            title: 'Risiko & Kehati-hatian',
            icon: Icons.warning_amber_outlined,
            accentColor: WijiColors.clay,
            content: tanaman.risiko.isNotEmpty
                ? tanaman.risiko
                : 'Tidak ada catatan risiko khusus.',
          ),
          const SizedBox(height: WijiSpacing.md),
          _ReferensiSection(items: tanaman.referensi),
          if (widget.isAdmin) ...[
            const SizedBox(height: WijiSpacing.lg),
            Text(
              'Kelola Tanaman (Admin)',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: WijiSpacing.sm),
            FilledButton.icon(
              onPressed: _mutating ? null : _bukaFormUbah,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Ubah Data Tanaman'),
            ),
            const SizedBox(height: WijiSpacing.sm),
            OutlinedButton.icon(
              onPressed: _mutating ? null : _toggleArsip,
              icon: Icon(
                tanaman.diarsipkan
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              label: Text(
                tanaman.diarsipkan
                    ? 'Pulihkan dari Arsip'
                    : 'Arsipkan Tanaman',
              ),
            ),
            const SizedBox(height: WijiSpacing.sm),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: WijiColors.brick,
                side: const BorderSide(color: WijiColors.brick),
              ),
              onPressed: _mutating ? null : _hapus,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus Tanaman'),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
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

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.content,
    this.accentColor = WijiColors.moss,
  });

  final String title;
  final IconData icon;
  final String content;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: accentColor),
                const SizedBox(width: WijiSpacing.sm),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WijiSpacing.sm),
            Text(content, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _KontaminanSection extends StatelessWidget {
  const _KontaminanSection({required this.items});

  final List<KemampuanKontaminan> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.science_outlined,
                  size: 20,
                  color: WijiColors.moss,
                ),
                const SizedBox(width: WijiSpacing.sm),
                Text(
                  'Kontaminan yang Bisa Ditangani',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WijiSpacing.sm),
            if (items.isEmpty)
              Text(
                'Belum ada data kemampuan penanganan kontaminan.',
                style: textTheme.bodyMedium?.copyWith(
                  color: WijiColors.inkSoft,
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: WijiSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[i].nama,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (items[i].catatan != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  items[i].catatan!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: WijiColors.inkSoft,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (items[i].efektivitas != null)
                          _StatusChip(
                            label: items[i].efektivitas!,
                            background: WijiColors.leaf,
                            foreground: WijiColors.mossDeep,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _ReferensiSection extends StatelessWidget {
  const _ReferensiSection({required this.items});

  final List<ReferensiTanaman> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(WijiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: WijiColors.moss,
                ),
                const SizedBox(width: WijiSpacing.sm),
                Text(
                  'Referensi & Sumber',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WijiSpacing.sm),
            if (items.isEmpty)
              Text(
                'Belum ada referensi tercatat.',
                style: textTheme.bodyMedium?.copyWith(
                  color: WijiColors.inkSoft,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const Divider(height: WijiSpacing.md),
                    Text(
                      items[i].judul,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (items[i].penulis != null || items[i].tahun != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (items[i].penulis != null) items[i].penulis!,
                          if (items[i].tahun != null) '${items[i].tahun}',
                        ].join(' · '),
                        style: textTheme.bodySmall?.copyWith(
                          color: WijiColors.inkSoft,
                        ),
                      ),
                    ],
                    if (items[i].url != null) ...[
                      const SizedBox(height: 2),
                      SelectableText(
                        items[i].url!,
                        style: textTheme.bodySmall?.copyWith(
                          color: WijiColors.moss,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
