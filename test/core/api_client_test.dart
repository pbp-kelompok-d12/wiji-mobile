import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wiji_mobile/core/api/api_client.dart';

// Server palsu: tiap test nentuin sendiri server-nya jawab apa.
ApiClient clientWith(MockClientHandler handler) =>
    ApiClient(httpClient: MockClient(handler), baseUrl: 'https://wiji.test');

http.Response json(Object? body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('alamatnya pakai prefix api/v1 dan query', () {
    final api = clientWith((_) async => json([], 200));

    expect(
      api.uri('tanaman/', {'q': 'akar wangi'}).toString(),
      'https://wiji.test/api/v1/tanaman/?q=akar+wangi',
    );
    expect(
      api.uri('pesanan/3/').toString(),
      'https://wiji.test/api/v1/pesanan/3/',
    );
  });

  test('GET balikin JSON yang udah di-decode', () async {
    final api = clientWith((request) async {
      expect(request.method, 'GET');
      expect(request.headers['Accept'], 'application/json');
      return json([
        {'id': 1, 'nama': 'Akar wangi'},
      ], 200);
    });

    final data = await api.get('tanaman/');

    expect(data, [
      {'id': 1, 'nama': 'Akar wangi'},
    ]);
  });

  test('POST ngirim body JSON dan tanda login kalau ada', () async {
    final api = clientWith((request) async {
      expect(request.headers['Content-Type'], startsWith('application/json'));
      expect(request.headers['Authorization'], 'Token abc123');
      expect(jsonDecode(request.body), {'catatan': 'pagi aja'});
      return json({'id': 7}, 201);
    })..token = 'abc123';

    expect(await api.post('pesanan/', body: {'catatan': 'pagi aja'}), {
      'id': 7,
    });
  });

  test('tanpa login nggak ngirim header Authorization', () async {
    final api = clientWith((request) async {
      expect(request.headers.containsKey('Authorization'), isFalse);
      return json([], 200);
    });

    await api.get('tanaman/');
  });

  test('204 balikin null tanpa error', () async {
    final api = clientWith((_) async => http.Response('', 204));

    expect(await api.delete('rencana/2/'), isNull);
  });

  test('error validasi DRF digabung jadi satu pesan', () async {
    final api = clientWith(
      (_) async => json({
        'tanggal_usulan': ['Tanggal harus setelah hari ini.'],
        'sesi_usulan': ['Pilih pagi atau siang.'],
      }, 400),
    );

    await expectLater(
      api.post('pesanan/', body: {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having(
              (e) => e.message,
              'message',
              'Tanggal harus setelah hari ini. Pilih pagi atau siang.',
            ),
      ),
    );
  });

  test('error detail DRF dipakai apa adanya', () async {
    final api = clientWith((_) async => json({'detail': 'Masuk dulu.'}, 401));

    await expectLater(
      api.get('lahan/'),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', 'Masuk dulu.'),
      ),
    );
  });

  test('respons HTML dikasih pesan umum plus kode HTTP', () async {
    final api = clientWith(
      (_) async => http.Response('<h1>Server Error</h1>', 500),
    );

    await expectLater(
      api.get('lahan/'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Permintaan gagal (HTTP 500).',
        ),
      ),
    );
  });

  test('gagal konek dikasih pesan yang jelas', () async {
    final api = clientWith((_) async => throw http.ClientException('offline'));

    await expectLater(
      api.get('lahan/'),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', isNull),
      ),
    );
  });
}
