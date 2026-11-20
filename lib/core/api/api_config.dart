/// Alamat server Django Wiji.
///
/// Bawaannya server Wiji di PWS. Kalau mau ngetes ke Django di laptop sendiri:
/// `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000`
/// (di emulator Android pakai `http://10.0.2.2:8000`, soalnya 127.0.0.1 itu emulatornya sendiri).
abstract final class ApiConfig {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://muhammad-osman-wiji.pws.cs.ui.ac.id',
  );

  /// Semua endpoint DRF ada di bawah prefix ini (lihat docs/WORK-PLAN.md).
  static const apiPrefix = '/api/v1/';

  /// Batas nunggu respons. Server PWS kadang lambat pas baru bangun.
  static const timeout = Duration(seconds: 20);
}
