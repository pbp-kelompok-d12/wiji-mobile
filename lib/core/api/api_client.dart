import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:wiji_mobile/core/api/api_config.dart';

/// Error dari API yang pesannya udah siap ditampilin ke pengguna.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;

  /// Kode HTTP dari server. Kosong kalau request-nya bahkan nggak nyampe server.
  final int? statusCode;

  @override
  String toString() => message;
}

/// Satu-satunya pintu buat ngobrol sama server Wiji. Semua modul pakai ini,
/// jangan bikin `http.get` sendiri di halaman.
///
/// Contoh di service modul:
/// ```dart
/// final data = await ApiClient.instance.get('tanaman/', query: {'q': 'akar'});
/// return (data as List).map((json) => Tanaman.fromJson(json)).toList();
/// ```
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
    : _http = httpClient ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Dipakai bareng seluruh aplikasi biar tanda login-nya cuma disimpen di satu tempat.
  static final instance = ApiClient();

  final http.Client _http;
  final String _baseUrl;

  /// Tanda login dari halaman masuk (issue 14). Kalau diisi, ikut dikirim di tiap request.
  String? token;

  /// Ngerakit alamat lengkap. `path` ditulis tanpa prefix, misalnya `pesanan/12/`.
  Uri uri(String path, [Map<String, String>? query]) {
    final url = Uri.parse('$_baseUrl${ApiConfig.apiPrefix}$path');
    return query == null || query.isEmpty
        ? url
        : url.replace(queryParameters: query);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _send('GET', uri(path, query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send('POST', uri(path), body: body);

  Future<dynamic> patch(String path, {Object? body}) =>
      _send('PATCH', uri(path), body: body);

  Future<dynamic> delete(String path) => _send('DELETE', uri(path));

  Future<dynamic> _send(String method, Uri url, {Object? body}) async {
    final request = http.Request(method, url)
      ..headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Token $token';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(ApiConfig.timeout),
      );
    } on TimeoutException {
      throw ApiException('Server kelamaan jawab. Coba lagi bentar ya.');
    } on http.ClientException {
      throw ApiException('Nggak bisa nyambung ke server. Cek internet kamu.');
    }

    // 204 (misalnya habis hapus) emang nggak ada isinya, jangan di-decode.
    if (response.statusCode == 204) return null;

    final data = _decode(response);
    if (response.statusCode >= 400) {
      throw ApiException(
        pesanError(data, response.statusCode),
        statusCode: response.statusCode,
      );
    }
    return data;
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      // Pakai utf8 biar huruf kayak "é" atau "–" dari server nggak rusak.
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      // Biasanya halaman HTML (misalnya error 500 atau 404 dari Django), bukan JSON.
      return null;
    }
  }

  /// Ngumpulin pesan error dari format DRF, baik `{"detail": "..."}`
  /// maupun `{"nama_field": ["pesan", ...]}`.
  static String pesanError(Object? data, int statusCode) {
    final pesan = <String>[];
    void ambil(Object? nilai) {
      if (nilai is String) {
        pesan.add(nilai);
      } else if (nilai is List) {
        nilai.forEach(ambil);
      } else if (nilai is Map) {
        nilai.values.forEach(ambil);
      }
    }

    ambil(data);
    return pesan.isEmpty
        ? 'Permintaan gagal (HTTP $statusCode).'
        : pesan.join(' ');
  }
}
