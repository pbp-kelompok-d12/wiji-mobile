import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/api/api_client.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/core/widgets/state_views.dart';
import 'package:wiji_mobile/features/home/menu.dart';
import 'package:wiji_mobile/features/home/widgets/module_scaffold.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';
import 'package:wiji_mobile/features/katalog/screens/detail_tanaman_screen.dart';
import 'package:wiji_mobile/features/katalog/screens/form_tanaman_screen.dart';
import 'package:wiji_mobile/features/katalog/services/katalog_service.dart';
import 'package:wiji_mobile/features/katalog/widgets/tanaman_card.dart';

/// Halaman utama Modul D: Katalog Tanaman.
class KatalogScreen extends StatefulWidget {
  const KatalogScreen({
    super.key,
    this.isAdmin = false,
    this.service,
  });

  final bool isAdmin;
  final KatalogService? service;

  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  late final KatalogService _service;
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Tanaman> _daftarTanaman = const [];
  List<TujuanTanaman> _daftarTujuan = const [];
  bool _loading = true;
  String? _error;

  JenisTanaman? _selectedJenis;
  String? _selectedTujuanSlug;
  bool _hanyaLokal = false;
  bool _hanyaFavorit = false;
  bool _lihatArsip = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? KatalogService();
    _muatAwal();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _muatAwal() async {
    await Future.wait([
      _muatTanaman(),
      _muatTujuan(),
    ]);
  }

  Future<void> _muatTujuan() async {
    try {
      final tujuan = await _service.ambilTujuanPengelolaan();
      if (!mounted) return;
      setState(() => _daftarTujuan = tujuan);
    } on ApiException {
      // Kalau endpoint tujuan butuh login atau belum siap, pakai dari data tanaman.
    }
  }

  Future<void> _muatTanaman() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final hasil = await _service.ambilDaftarTanaman(
        query: _searchController.text,
        tujuanSlug: _selectedTujuanSlug,
        jenis: _selectedJenis,
        hanyaLokal: _hanyaLokal,
        arsip: widget.isAdmin && _lihatArsip,
      );
      if (!mounted) return;

      // Pengunjung tidak boleh melihat tanaman yang diarsipkan.
      final tersaring = widget.isAdmin
          ? hasil
          : hasil.where((t) => !t.diarsipkan).toList();

      setState(() {
        _daftarTanaman = tersaring;
        if (_daftarTujuan.isEmpty) {
          final unik = <String, TujuanTanaman>{};
          for (final t in tersaring) {
            for (final tj in t.tujuan) {
              unik.putIfAbsent(tj.slug, () => tj);
            }
          }
          _daftarTujuan = unik.values.toList();
        }
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

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _muatTanaman);
    setState(() {});
  }

  void _resetFilter() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedJenis = null;
      _selectedTujuanSlug = null;
      _hanyaLokal = false;
      _hanyaFavorit = false;
      _lihatArsip = false;
    });
    _muatTanaman();
  }

  bool get _adaFilterAktif =>
      _searchController.text.trim().isNotEmpty ||
      _selectedJenis != null ||
      _selectedTujuanSlug != null ||
      _hanyaLokal ||
      _hanyaFavorit ||
      _lihatArsip;

  Future<void> _bukaDetail(Tanaman tanaman) async {
    final adaPerubahan = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DetailTanamanScreen(
          tanamanId: tanaman.id,
          isAdmin: widget.isAdmin,
          service: _service,
          daftarTujuan: _daftarTujuan,
        ),
      ),
    );
    if (adaPerubahan == true && mounted) {
      _muatTanaman();
    }
  }

  Future<void> _bukaFormTambah() async {
    final hasil = await Navigator.of(context).push<Object?>(
      MaterialPageRoute(
        builder: (_) => FormTanamanScreen(
          service: _service,
          daftarTujuan: _daftarTujuan,
        ),
      ),
    );
    if (hasil != null && mounted) {
      _muatTanaman();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      menu: WijiMenu.katalog,
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _bukaFormTambah,
              backgroundColor: WijiColors.forest,
              foregroundColor: WijiColors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      body: Column(
        children: [
          _FilterPanel(
            searchController: _searchController,
            onSearchChanged: _onSearchChanged,
            onClearSearch: () {
              _searchController.clear();
              _muatTanaman();
            },
            selectedJenis: _selectedJenis,
            onSelectJenis: (jenis) {
              setState(() {
                _selectedJenis = _selectedJenis == jenis ? null : jenis;
              });
              _muatTanaman();
            },
            hanyaLokal: _hanyaLokal,
            onToggleLokal: (val) {
              setState(() => _hanyaLokal = val);
              _muatTanaman();
            },
            hanyaFavorit: _hanyaFavorit,
            onToggleFavorit: (val) {
              setState(() => _hanyaFavorit = val);
            },
            isAdmin: widget.isAdmin,
            lihatArsip: _lihatArsip,
            onToggleArsip: (val) {
              setState(() => _lihatArsip = val);
              _muatTanaman();
            },
            daftarTujuan: _daftarTujuan,
            selectedTujuanSlug: _selectedTujuanSlug,
            onSelectTujuan: (slug) {
              setState(() => _selectedTujuanSlug = slug);
              _muatTanaman();
            },
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const LoadingView(message: 'Lagi ngambil katalog tanaman...');
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _muatTanaman);
    }

    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoritTanamanStore.instance,
      builder: (context, favoritIds, _) {
        final items = _hanyaFavorit
            ? _daftarTanaman.where((t) => favoritIds.contains(t.id)).toList()
            : _daftarTanaman;

        if (items.isEmpty) {
          return EmptyView(
            icon: WijiMenu.katalog.icon,
            title: _adaFilterAktif
                ? 'Nggak ada tanaman yang cocok'
                : 'Katalog tanaman masih kosong',
            message: _adaFilterAktif
                ? 'Coba ganti kata kunci atau reset filter pencarian.'
                : 'Belum ada data tanaman di katalog.',
            action: _adaFilterAktif
                ? OutlinedButton.icon(
                    onPressed: _resetFilter,
                    icon: const Icon(Icons.filter_alt_off_outlined),
                    label: const Text('Reset filter'),
                  )
                : null,
          );
        }

        return RefreshIndicator(
          onRefresh: _muatTanaman,
          child: ListView.separated(
            padding: const EdgeInsets.all(WijiSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: WijiSpacing.sm),
            itemBuilder: (context, index) {
              final tanaman = items[index];
              return TanamanCard(
                tanaman: tanaman,
                isFavorit: favoritIds.contains(tanaman.id),
                onToggleFavorit: () =>
                    FavoritTanamanStore.instance.toggle(tanaman.id),
                onTap: () => _bukaDetail(tanaman),
              );
            },
          ),
        );
      },
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedJenis,
    required this.onSelectJenis,
    required this.hanyaLokal,
    required this.onToggleLokal,
    required this.hanyaFavorit,
    required this.onToggleFavorit,
    required this.isAdmin,
    required this.lihatArsip,
    required this.onToggleArsip,
    required this.daftarTujuan,
    required this.selectedTujuanSlug,
    required this.onSelectTujuan,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final JenisTanaman? selectedJenis;
  final ValueChanged<JenisTanaman> onSelectJenis;
  final bool hanyaLokal;
  final ValueChanged<bool> onToggleLokal;
  final bool hanyaFavorit;
  final ValueChanged<bool> onToggleFavorit;
  final bool isAdmin;
  final bool lihatArsip;
  final ValueChanged<bool> onToggleArsip;
  final List<TujuanTanaman> daftarTujuan;
  final String? selectedTujuanSlug;
  final ValueChanged<String?> onSelectTujuan;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: WijiColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          WijiSpacing.md,
          WijiSpacing.md,
          WijiSpacing.md,
          WijiSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama, nama ilmiah, atau fungsi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: WijiSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final jenis in JenisTanaman.values) ...[
                    FilterChip(
                      label: Text(jenis.label),
                      selected: selectedJenis == jenis,
                      onSelected: (_) => onSelectJenis(jenis),
                    ),
                    const SizedBox(width: WijiSpacing.xs),
                  ],
                  FilterChip(
                    label: const Text('Tersedia di Indonesia'),
                    selected: hanyaLokal,
                    onSelected: onToggleLokal,
                  ),
                  const SizedBox(width: WijiSpacing.xs),
                  FilterChip(
                    label: const Text('Favorit'),
                    selected: hanyaFavorit,
                    onSelected: onToggleFavorit,
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: WijiSpacing.xs),
                    FilterChip(
                      label: const Text('Arsip'),
                      selected: lihatArsip,
                      onSelected: onToggleArsip,
                    ),
                  ],
                ],
              ),
            ),
            if (daftarTujuan.isNotEmpty) ...[
              const SizedBox(height: WijiSpacing.xs),
              DropdownButtonFormField<String?>(
                initialValue: daftarTujuan.any((t) => t.slug == selectedTujuanSlug)
                    ? selectedTujuanSlug
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Filter tujuan pengelolaan',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua tujuan'),
                  ),
                  for (final tujuan in daftarTujuan)
                    DropdownMenuItem<String?>(
                      value: tujuan.slug,
                      child: Text(tujuan.nama),
                    ),
                ],
                onChanged: onSelectTujuan,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
