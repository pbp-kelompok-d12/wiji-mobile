import 'package:material_ui/material_ui.dart';

/// Warna Wiji. Nilainya diambil dari `static/css/wiji.css` di proyek web,
/// biar HP sama web kerasa satu aplikasi.
///
/// Di halaman jangan nulis kode warna langsung, ambil dari sini atau dari
/// `Theme.of(context)` aja.
abstract final class WijiColors {
  // Hijau hutan buat aksi utama dan panel gelap.
  static const forest = Color(0xFF142019);
  static const forestSoft = Color(0xFF2A3A2F);

  // Lumut buat aksen, tautan, dan item yang lagi dipilih.
  static const moss = Color(0xFF2F6B3F);
  static const mossDeep = Color(0xFF24552F);
  static const leaf = Color(0xFFE4EEE2);
  static const mint = Color(0xFFCFE2CB);

  // Tanah liat buat aksen kedua.
  static const clay = Color(0xFF8B5A3C);
  static const sand = Color(0xFFF3E8DD);

  // Latar, garis, dan teks.
  static const paper = Color(0xFFF6F4EE);
  static const line = Color(0xFFE2DCCD);
  static const ink = Color(0xFF1C2620);
  static const inkSoft = Color(0xFF4F5A52);
  static const white = Color(0xFFFFFFFF);

  // Merah bata buat error dan aksi berbahaya (hapus, batal).
  static const brick = Color(0xFFA33A2C);
  static const brickBg = Color(0xFFF7E1DC);
}
