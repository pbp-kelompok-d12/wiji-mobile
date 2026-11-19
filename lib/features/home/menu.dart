import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/features/hasil/screens/daftar_hasil_screen.dart';
import 'package:wiji_mobile/features/katalog/screens/katalog_screen.dart';
import 'package:wiji_mobile/features/lahan/screens/daftar_lahan_screen.dart';
import 'package:wiji_mobile/features/pemeriksaan/screens/daftar_pesanan_screen.dart';
import 'package:wiji_mobile/features/rekomendasi/screens/daftar_rencana_screen.dart';

/// Menu utama aplikasi, satu per modul. Drawer sama kartu di beranda
/// sama-sama baca dari sini, jadi kalau nambah atau ganti menu cukup di sini.
enum WijiMenu {
  lahan(
    label: 'Lahan',
    keterangan: 'Data lahan yang kamu kelola',
    icon: Icons.landscape_outlined,
  ),
  pemeriksaan(
    label: 'Pemeriksaan',
    keterangan: 'Pesan dan pantau pemeriksaan tanah',
    icon: Icons.science_outlined,
  ),
  hasil(
    label: 'Hasil Pemeriksaan',
    keterangan: 'pH, unsur hara, dan kontaminan tanah',
    icon: Icons.assignment_outlined,
  ),
  katalog(
    label: 'Katalog Tanaman',
    keterangan: 'Cari tanaman dan kegunaannya',
    icon: Icons.local_florist_outlined,
  ),
  rekomendasi(
    label: 'Rekomendasi & Rencana',
    keterangan: 'Tanaman yang cocok dan rencana tanam',
    icon: Icons.eco_outlined,
  );

  const WijiMenu({
    required this.label,
    required this.keterangan,
    required this.icon,
  });

  final String label;
  final String keterangan;
  final IconData icon;

  /// Halaman utama tiap modul.
  Widget buildPage() => switch (this) {
    WijiMenu.lahan => const DaftarLahanScreen(),
    WijiMenu.pemeriksaan => const DaftarPesananScreen(),
    WijiMenu.hasil => const DaftarHasilScreen(),
    WijiMenu.katalog => const KatalogScreen(),
    WijiMenu.rekomendasi => const DaftarRencanaScreen(),
  };
}

/// Pindah dari menu [dari] ke menu [ke]. `null` artinya beranda.
///
/// Beranda selalu jadi halaman paling bawah. Dari beranda halaman modul
/// di-push, antarmodul diganti (pushReplacement), jadi tombol back dari
/// modul mana pun balik ke beranda dan halamannya nggak numpuk.
void bukaMenu(
  BuildContext context, {
  required WijiMenu? dari,
  required WijiMenu? ke,
}) {
  if (dari == ke) return;

  final navigator = Navigator.of(context);
  if (ke == null) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }

  final route = MaterialPageRoute<void>(builder: (_) => ke.buildPage());
  if (dari == null) {
    navigator.push(route);
  } else {
    navigator.pushReplacement(route);
  }
}
