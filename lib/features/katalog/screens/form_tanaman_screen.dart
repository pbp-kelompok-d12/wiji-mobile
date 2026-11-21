import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/api/api_client.dart';
import 'package:wiji_mobile/core/theme/wiji_colors.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';
import 'package:wiji_mobile/features/katalog/services/katalog_service.dart';

/// Halaman form tambah dan ubah tanaman (khusus admin).
class FormTanamanScreen extends StatefulWidget {
  const FormTanamanScreen({
    super.key,
    this.tanaman,
    this.service,
    this.daftarTujuan = const [],
  });

  final Tanaman? tanaman;
  final KatalogService? service;
  final List<TujuanTanaman> daftarTujuan;

  @override
  State<FormTanamanScreen> createState() => _FormTanamanScreenState();
}

class _FormTanamanScreenState extends State<FormTanamanScreen> {
  final _formKey = GlobalKey<FormState>();
  late final KatalogService _service;

  late final TextEditingController _namaController;
  late final TextEditingController _namaIlmiahController;
  late final TextEditingController _fungsiController;
  late final TextEditingController _deskripsiController;
  late final TextEditingController _kondisiController;
  late final TextEditingController _risikoController;

  late JenisTanaman _jenis;
  late bool _tersediaDiIndonesia;
  late Set<String> _selectedTujuanSlugs;
  List<TujuanTanaman> _opsiTujuan = const [];
  bool _submitting = false;

  bool get _isEdit => widget.tanaman != null;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? KatalogService();
    final t = widget.tanaman;
    _namaController = TextEditingController(text: t?.nama ?? '');
    _namaIlmiahController = TextEditingController(text: t?.namaIlmiah ?? '');
    _fungsiController = TextEditingController(text: t?.fungsi ?? '');
    _deskripsiController = TextEditingController(text: t?.deskripsi ?? '');
    _kondisiController = TextEditingController(text: t?.kondisiTumbuh ?? '');
    _risikoController = TextEditingController(text: t?.risiko ?? '');
    _jenis = t?.jenis ?? JenisTanaman.umum;
    _tersediaDiIndonesia = t?.tersediaDiIndonesia ?? true;
    _selectedTujuanSlugs = t?.tujuan.map((e) => e.slug).toSet() ?? <String>{};
    _opsiTujuan = widget.daftarTujuan;

    if (_opsiTujuan.isEmpty) {
      _muatTujuan();
    }
  }

  Future<void> _muatTujuan() async {
    try {
      final hasil = await _service.ambilTujuanPengelolaan();
      if (!mounted) return;
      setState(() {
        _opsiTujuan = hasil;
      });
    } on ApiException {
      // Tujuan opsional saat endpoint belum tersedia.
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _namaIlmiahController.dispose();
    _fungsiController.dispose();
    _deskripsiController.dispose();
    _kondisiController.dispose();
    _risikoController.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final payload = <String, dynamic>{
      'nama': _namaController.text.trim(),
      'nama_ilmiah': _namaIlmiahController.text.trim(),
      'jenis': _jenis.value,
      'fungsi': _fungsiController.text.trim(),
      'deskripsi': _deskripsiController.text.trim(),
      'kondisi_tumbuh': _kondisiController.text.trim(),
      'risiko': _risikoController.text.trim(),
      'tersedia_di_indonesia': _tersediaDiIndonesia,
      if (_selectedTujuanSlugs.isNotEmpty)
        'tujuan': _selectedTujuanSlugs.toList(),
    };

    try {
      final Tanaman hasil;
      if (_isEdit) {
        hasil = await _service.ubahTanaman(widget.tanaman!.id, payload);
      } else {
        hasil = await _service.tambahTanaman(payload);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Perubahan tanaman berhasil disimpan.'
                : 'Tanaman baru berhasil ditambahkan.',
          ),
        ),
      );
      Navigator.of(context).pop(hasil);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: WijiColors.brick,
          content: Text(e.message),
        ),
      );
      setState(() => _submitting = false);
    }
  }

  Future<void> _toggleArsip() async {
    final t = widget.tanaman;
    if (t == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      if (t.diarsipkan) {
        await _service.pulihkanTanaman(t.id);
      } else {
        await _service.arsipkanTanaman(t.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.diarsipkan
                ? 'Tanaman dipulihkan dari arsip.'
                : 'Tanaman berhasil diarsipkan.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: WijiColors.brick,
          content: Text(e.message),
        ),
      );
      setState(() => _submitting = false);
    }
  }

  Future<void> _hapus() async {
    final t = widget.tanaman;
    if (t == null || _submitting) return;

    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus tanaman?'),
        content: Text(
          'Tanaman "${t.nama}" akan dihapus permanen. '
          'Penghapusan ditolak kalau tanaman sudah dipakai di rekomendasi.',
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

    setState(() => _submitting = true);
    try {
      await _service.hapusTanaman(t.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanaman berhasil dihapus.')),
      );
      Navigator.of(context).pop('deleted');
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: WijiColors.brick,
          content: Text(e.message),
        ),
      );
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tanaman;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Tanaman' : 'Tambah Tanaman'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(WijiSpacing.md),
            children: [
              TextFormField(
                controller: _namaController,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Nama tanaman *',
                  hintText: 'Contoh: Akar Wangi',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama tanaman wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WijiSpacing.md),
              TextFormField(
                controller: _namaIlmiahController,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Nama ilmiah *',
                  hintText: 'Contoh: Chrysopogon zizanioides',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama ilmiah wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WijiSpacing.md),
              DropdownButtonFormField<JenisTanaman>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis tanaman *'),
                items: [
                  for (final jenis in JenisTanaman.values)
                    DropdownMenuItem(
                      value: jenis,
                      child: Text(jenis.label),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (value) {
                        if (value != null) setState(() => _jenis = value);
                      },
              ),
              const SizedBox(height: WijiSpacing.md),
              TextFormField(
                controller: _fungsiController,
                enabled: !_submitting,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Fungsi utama *',
                  hintText: 'Contoh: Menyerap logam berat dan menahan erosi',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Fungsi tanaman wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: WijiSpacing.md),
              TextFormField(
                controller: _deskripsiController,
                enabled: !_submitting,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Penjelasan singkat karakteristik tanaman',
                ),
              ),
              const SizedBox(height: WijiSpacing.md),
              TextFormField(
                controller: _kondisiController,
                enabled: !_submitting,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Kondisi tumbuh',
                  hintText: 'pH tanah, kebutuhan cahaya, kelembapan, iklim',
                ),
              ),
              const SizedBox(height: WijiSpacing.md),
              TextFormField(
                controller: _risikoController,
                enabled: !_submitting,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Risiko / catatan kehati-hatian',
                  hintText: 'Contoh: Potensi invasif atau beracun bagi ternak',
                ),
              ),
              const SizedBox(height: WijiSpacing.sm),
              Card(
                child: SwitchListTile(
                  value: _tersediaDiIndonesia,
                  onChanged: _submitting
                      ? null
                      : (value) => setState(() => _tersediaDiIndonesia = value),
                  title: const Text('Tersedia di Indonesia'),
                  subtitle: const Text(
                    'Tandai kalau bibit atau tanamannya mudah didapat di Indonesia.',
                  ),
                ),
              ),
              if (_opsiTujuan.isNotEmpty) ...[
                const SizedBox(height: WijiSpacing.md),
                Text(
                  'Tujuan Pengelolaan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: WijiSpacing.xs),
                Wrap(
                  spacing: WijiSpacing.xs,
                  runSpacing: WijiSpacing.xs,
                  children: [
                    for (final tujuan in _opsiTujuan)
                      FilterChip(
                        label: Text(tujuan.nama),
                        selected: _selectedTujuanSlugs.contains(tujuan.slug),
                        onSelected: _submitting
                            ? null
                            : (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTujuanSlugs.add(tujuan.slug);
                                  } else {
                                    _selectedTujuanSlugs.remove(tujuan.slug);
                                  }
                                });
                              },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: WijiSpacing.lg),
              FilledButton.icon(
                onPressed: _submitting ? null : _simpan,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: WijiColors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_submitting ? 'Lagi nyimpan...' : 'Simpan Tanaman'),
              ),
              if (_isEdit && t != null) ...[
                const SizedBox(height: WijiSpacing.md),
                OutlinedButton.icon(
                  onPressed: _submitting ? null : _toggleArsip,
                  icon: Icon(
                    t.diarsipkan
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  label: Text(
                    t.diarsipkan ? 'Pulihkan dari Arsip' : 'Arsipkan Tanaman',
                  ),
                ),
                const SizedBox(height: WijiSpacing.sm),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: WijiColors.brick,
                    side: const BorderSide(color: WijiColors.brick),
                  ),
                  onPressed: _submitting ? null : _hapus,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus Tanaman'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
