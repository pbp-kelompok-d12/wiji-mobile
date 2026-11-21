import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/api/api_client.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';

/// Penyimpan daftar ID tanaman favorit di HP selama sesi aplikasi berjalan.
class FavoritTanamanStore extends ValueNotifier<Set<int>> {
  FavoritTanamanStore._() : super(<int>{});

  static final instance = FavoritTanamanStore._();

  bool isFavorit(int tanamanId) => value.contains(tanamanId);

  void toggle(int tanamanId) {
    final next = Set<int>.from(value);
    if (!next.add(tanamanId)) {
      next.remove(tanamanId);
    }
    value = next;
  }
}

/// Layanan API untuk Modul D (Katalog Tanaman).
class KatalogService {
  KatalogService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient.instance;

  final ApiClient _api;

  /// Mengambil daftar tanaman dengan pencarian dan filter opsional.
  Future<List<Tanaman>> ambilDaftarTanaman({
    String? query,
    String? tujuanSlug,
    JenisTanaman? jenis,
    bool hanyaLokal = false,
    bool arsip = false,
  }) async {
    final params = <String, String>{};
    final q = query?.trim();
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (tujuanSlug != null && tujuanSlug.isNotEmpty) {
      params['tujuan'] = tujuanSlug;
    }
    if (jenis != null) params['jenis'] = jenis.value;
    if (hanyaLokal) params['lokal'] = '1';
    if (arsip) params['arsip'] = '1';

    final data = await _api.get('tanaman/', query: params);
    return _extractList(data)
        .map((item) => Tanaman.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  /// Mengambil detail lengkap tanaman beserta kemampuan kontaminan dan referensi.
  Future<Tanaman> ambilDetailTanaman(int id) async {
    final data = await _api.get('tanaman/$id/');
    return Tanaman.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Menambahkan tanaman baru (khusus admin).
  Future<Tanaman> tambahTanaman(Map<String, dynamic> payload) async {
    final data = await _api.post('tanaman/', body: payload);
    return Tanaman.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Mengubah data tanaman yang sudah ada (khusus admin).
  Future<Tanaman> ubahTanaman(int id, Map<String, dynamic> payload) async {
    final data = await _api.patch('tanaman/$id/', body: payload);
    return Tanaman.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Menghapus tanaman (khusus admin; ditolak server jika sudah dipakai rekomendasi).
  Future<void> hapusTanaman(int id) async {
    await _api.delete('tanaman/$id/');
  }

  /// Mengarsipkan tanaman agar tidak muncul untuk pengunjung (khusus admin).
  Future<void> arsipkanTanaman(int id) async {
    await _api.post('tanaman/$id/arsip/');
  }

  /// Memulihkan tanaman dari arsip (khusus admin).
  Future<void> pulihkanTanaman(int id) async {
    await _api.post('tanaman/$id/pulihkan/');
  }

  /// Mengambil daftar jenis kontaminan publik.
  Future<List<JenisKontaminan>> ambilJenisKontaminan() async {
    final data = await _api.get('jenis-kontaminan/');
    return _extractList(data)
        .map(
          (item) => JenisKontaminan.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  /// Mengambil daftar tujuan pengelolaan untuk opsi filter.
  Future<List<TujuanTanaman>> ambilTujuanPengelolaan() async {
    final data = await _api.get('tujuan-pengelolaan/');
    return _extractList(data).map(TujuanTanaman.fromJson).toList();
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['results'] is List) {
      return data['results'] as List<dynamic>;
    }
    return const [];
  }
}
