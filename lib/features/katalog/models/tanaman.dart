/// Jenis tanaman dalam katalog Wiji.
enum JenisTanaman {
  umum('umum', 'Umum'),
  fitoremediasi('fitoremediasi', 'Fitoremediasi');

  const JenisTanaman(this.value, this.label);

  final String value;
  final String label;

  static JenisTanaman fromValue(String? raw) {
    final normalized = raw?.trim().toLowerCase();
    return JenisTanaman.values.firstWhere(
      (item) => item.value == normalized,
      orElse: () => JenisTanaman.umum,
    );
  }
}

/// Tujuan pengelolaan lahan yang didukung tanaman.
class TujuanTanaman {
  const TujuanTanaman({
    this.id,
    required this.slug,
    required this.nama,
  });

  final int? id;
  final String slug;
  final String nama;

  factory TujuanTanaman.fromJson(Object? json) {
    if (json is String) {
      return TujuanTanaman(slug: json, nama: json);
    }
    final map = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    final slug = (map['slug'] ?? map['kode'] ?? map['nama'] ?? '').toString();
    final nama = (map['nama'] ?? map['label'] ?? slug).toString();
    return TujuanTanaman(
      id: _asInt(map['id']),
      slug: slug,
      nama: nama,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'slug': slug,
        'nama': nama,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TujuanTanaman && slug == other.slug && nama == other.nama;

  @override
  int get hashCode => Object.hash(slug, nama);
}

/// Master data jenis kontaminan dari `/api/v1/jenis-kontaminan/`.
class JenisKontaminan {
  const JenisKontaminan({
    required this.id,
    required this.nama,
    this.kategori,
    this.satuan,
  });

  final int id;
  final String nama;
  final String? kategori;
  final String? satuan;

  factory JenisKontaminan.fromJson(Map<String, dynamic> json) {
    return JenisKontaminan(
      id: _asInt(json['id']) ?? 0,
      nama: (json['nama'] ?? json['name'] ?? '').toString(),
      kategori: _asNullableString(json['kategori']),
      satuan: _asNullableString(json['satuan']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': nama,
        if (kategori != null) 'kategori': kategori,
        if (satuan != null) 'satuan': satuan,
      };
}

/// Kemampuan tanaman dalam menangani kontaminan tertentu.
class KemampuanKontaminan {
  const KemampuanKontaminan({
    this.kontaminanId,
    required this.nama,
    this.efektivitas,
    this.catatan,
  });

  final int? kontaminanId;
  final String nama;
  final String? efektivitas;
  final String? catatan;

  factory KemampuanKontaminan.fromJson(Object? json) {
    if (json is String) {
      return KemampuanKontaminan(nama: json);
    }
    final map = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    final nested = map['jenis_kontaminan'] ?? map['kontaminan'];
    final nestedMap = nested is Map ? Map<String, dynamic>.from(nested) : null;

    return KemampuanKontaminan(
      kontaminanId: _asInt(map['jenis_kontaminan_id'] ?? map['kontaminan_id'] ?? nestedMap?['id']),
      nama: (map['nama'] ??
              map['nama_kontaminan'] ??
              nestedMap?['nama'] ??
              (nested is String ? nested : null) ??
              'Kontaminan')
          .toString(),
      efektivitas: _asNullableString(map['efektivitas'] ?? map['tingkat']),
      catatan: _asNullableString(map['catatan'] ?? map['mekanisme']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (kontaminanId != null) 'jenis_kontaminan_id': kontaminanId,
        'nama': nama,
        if (efektivitas != null && efektivitas!.isNotEmpty) 'efektivitas': efektivitas,
        if (catatan != null && catatan!.isNotEmpty) 'catatan': catatan,
      };
}

/// Sumber atau referensi ilmiah tanaman.
class ReferensiTanaman {
  const ReferensiTanaman({
    required this.judul,
    this.penulis,
    this.tahun,
    this.url,
  });

  final String judul;
  final String? penulis;
  final int? tahun;
  final String? url;

  factory ReferensiTanaman.fromJson(Object? json) {
    if (json is String) {
      return ReferensiTanaman(judul: json);
    }
    final map = json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{};
    return ReferensiTanaman(
      judul: (map['judul'] ?? map['title'] ?? map['sumber'] ?? map['url'] ?? 'Referensi').toString(),
      penulis: _asNullableString(map['penulis'] ?? map['author']),
      tahun: _asInt(map['tahun'] ?? map['year']),
      url: _asNullableString(map['url'] ?? map['tautan']),
    );
  }

  Map<String, dynamic> toJson() => {
        'judul': judul,
        if (penulis != null && penulis!.isNotEmpty) 'penulis': penulis,
        if (tahun != null) 'tahun': tahun,
        if (url != null && url!.isNotEmpty) 'url': url,
      };
}

/// Model utama tanaman di Katalog Wiji (Modul D).
class Tanaman {
  const Tanaman({
    required this.id,
    required this.nama,
    required this.namaIlmiah,
    required this.jenis,
    required this.fungsi,
    this.deskripsi = '',
    this.kondisiTumbuh = '',
    this.risiko = '',
    this.tersediaDiIndonesia = false,
    this.diarsipkan = false,
    this.tujuan = const [],
    this.kemampuanKontaminan = const [],
    this.referensi = const [],
  });

  final int id;
  final String nama;
  final String namaIlmiah;
  final JenisTanaman jenis;
  final String fungsi;
  final String deskripsi;
  final String kondisiTumbuh;
  final String risiko;
  final bool tersediaDiIndonesia;
  final bool diarsipkan;
  final List<TujuanTanaman> tujuan;
  final List<KemampuanKontaminan> kemampuanKontaminan;
  final List<ReferensiTanaman> referensi;

  factory Tanaman.fromJson(Map<String, dynamic> json) {
    final rawTujuan = json['tujuan'] ?? json['tujuan_pengelolaan'];
    final rawKontaminan = json['kemampuan_kontaminan'] ?? json['kontaminan'];
    final rawReferensi = json['referensi'] ?? json['sumber'];

    return Tanaman(
      id: _asInt(json['id']) ?? 0,
      nama: (json['nama'] ?? json['nama_umum'] ?? '').toString(),
      namaIlmiah: (json['nama_ilmiah'] ?? json['nama_latin'] ?? '').toString(),
      jenis: JenisTanaman.fromValue(json['jenis']?.toString()),
      fungsi: (json['fungsi'] ?? json['kegunaan'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      kondisiTumbuh: (json['kondisi_tumbuh'] ?? json['syarat_tumbuh'] ?? '').toString(),
      risiko: (json['risiko'] ?? '').toString(),
      tersediaDiIndonesia: _asBool(
        json['tersedia_di_indonesia'] ?? json['lokal'] ?? json['tersedia_indonesia'],
      ),
      diarsipkan: _asBool(json['diarsipkan'] ?? json['is_archived']),
      tujuan: rawTujuan is List
          ? rawTujuan.map(TujuanTanaman.fromJson).toList()
          : const [],
      kemampuanKontaminan: rawKontaminan is List
          ? rawKontaminan.map(KemampuanKontaminan.fromJson).toList()
          : const [],
      referensi: rawReferensi is List
          ? rawReferensi.map(ReferensiTanaman.fromJson).toList()
          : const [],
    );
  }

  /// Payload untuk `POST /api/v1/tanaman/` dan `PATCH /api/v1/tanaman/<id>/`.
  Map<String, dynamic> toPayload() => {
        'nama': nama,
        'nama_ilmiah': namaIlmiah,
        'jenis': jenis.value,
        'fungsi': fungsi,
        'deskripsi': deskripsi,
        'kondisi_tumbuh': kondisiTumbuh,
        'risiko': risiko,
        'tersedia_di_indonesia': tersediaDiIndonesia,
        if (tujuan.isNotEmpty) 'tujuan': tujuan.map((t) => t.slug).toList(),
      };
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lower = value.toLowerCase();
    return lower == 'true' || lower == '1' || lower == 'ya';
  }
  return false;
}

String? _asNullableString(Object? value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty ? null : str;
}
