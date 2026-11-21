import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wiji_mobile/core/api/api_client.dart';
import 'package:wiji_mobile/core/theme/wiji_theme.dart';
import 'package:wiji_mobile/features/katalog/models/tanaman.dart';
import 'package:wiji_mobile/features/katalog/screens/detail_tanaman_screen.dart';
import 'package:wiji_mobile/features/katalog/screens/katalog_screen.dart';
import 'package:wiji_mobile/features/katalog/services/katalog_service.dart';

ApiClient _clientWith(MockClientHandler handler) =>
    ApiClient(httpClient: MockClient(handler), baseUrl: 'https://wiji.test')
      ..token = 'admin-token';

http.Response _json(Object? body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _sampleTanamanJson({
  int id = 1,
  String nama = 'Akar Wangi',
  String jenis = 'fitoremediasi',
  bool lokal = true,
  bool diarsipkan = false,
}) => {
  'id': id,
  'nama': nama,
  'nama_ilmiah': 'Chrysopogon zizanioides',
  'jenis': jenis,
  'fungsi': 'Menyerap logam berat dan menahan erosi tanah.',
  'deskripsi': 'Rumput berakar dalam yang kuat untuk stabilisasi lereng.',
  'kondisi_tumbuh': 'pH 5.5 - 7.5, cahaya matahari penuh.',
  'risiko': 'Perlu pemangkasan berkala.',
  'tersedia_di_indonesia': lokal,
  'diarsipkan': diarsipkan,
  'tujuan': [
    {'id': 1, 'slug': 'fitoremediasi-logam', 'nama': 'Fitoremediasi Logam'},
  ],
  'kemampuan_kontaminan': [
    {
      'jenis_kontaminan_id': 10,
      'nama': 'Timbal (Pb)',
      'efektivitas': 'Tinggi',
      'catatan': 'Akumulasi pada sistem perakaran.',
    },
  ],
  'referensi': [
    {
      'judul': 'Vetiver System Applications',
      'penulis': 'Truong, P.',
      'tahun': 2008,
      'url': 'https://example.org/vetiver',
    },
  ],
};

Widget _wrapApp(Widget child) {
  return MaterialApp(theme: WijiTheme.light, home: child);
}

void main() {
  group('KatalogService', () {
    test('ambilDaftarTanaman mengirim query pencarian dan filter', () async {
      final api = _clientWith((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/tanaman/');
        expect(request.url.queryParameters, {
          'q': 'akar',
          'tujuan': 'fitoremediasi-logam',
          'jenis': 'fitoremediasi',
          'lokal': '1',
          'arsip': '1',
        });
        return _json([_sampleTanamanJson()], 200);
      });

      final service = KatalogService(apiClient: api);
      final hasil = await service.ambilDaftarTanaman(
        query: 'akar',
        tujuanSlug: 'fitoremediasi-logam',
        jenis: JenisTanaman.fitoremediasi,
        hanyaLokal: true,
        arsip: true,
      );

      expect(hasil, hasLength(1));
      expect(hasil.first.nama, 'Akar Wangi');
      expect(hasil.first.jenis, JenisTanaman.fitoremediasi);
      expect(hasil.first.tersediaDiIndonesia, isTrue);
    });

    test('ambilDaftarTanaman mendukung respons pagination DRF', () async {
      final api = _clientWith((_) async {
        return _json({
          'count': 1,
          'results': [_sampleTanamanJson(id: 2, nama: 'Sengon')],
        }, 200);
      });

      final service = KatalogService(apiClient: api);
      final hasil = await service.ambilDaftarTanaman();

      expect(hasil, hasLength(1));
      expect(hasil.first.id, 2);
      expect(hasil.first.nama, 'Sengon');
    });

    test('CRUD dan arsip/pulihkan memanggil endpoint yang sesuai', () async {
      final calls = <String>[];
      final api = _clientWith((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.method == 'DELETE') {
          return http.Response('', 204);
        }
        if (request.url.path.endsWith('/arsip/') ||
            request.url.path.endsWith('/pulihkan/')) {
          return _json({'detail': 'ok'}, 200);
        }
        if (request.url.path.endsWith('/jenis-kontaminan/')) {
          return _json([
            {'id': 10, 'nama': 'Timbal (Pb)', 'satuan': 'mg/kg'},
          ], 200);
        }
        return _json(_sampleTanamanJson(), 200);
      });

      final service = KatalogService(apiClient: api);
      await service.ambilDetailTanaman(1);
      await service.tambahTanaman({'nama': 'Akar Wangi'});
      await service.ubahTanaman(1, {'nama': 'Akar Wangi Baru'});
      await service.arsipkanTanaman(1);
      await service.pulihkanTanaman(1);
      await service.hapusTanaman(1);
      final kontaminan = await service.ambilJenisKontaminan();

      expect(calls, [
        'GET /api/v1/tanaman/1/',
        'POST /api/v1/tanaman/',
        'PATCH /api/v1/tanaman/1/',
        'POST /api/v1/tanaman/1/arsip/',
        'POST /api/v1/tanaman/1/pulihkan/',
        'DELETE /api/v1/tanaman/1/',
        'GET /api/v1/jenis-kontaminan/',
      ]);
      expect(kontaminan.single.nama, 'Timbal (Pb)');
    });
  });

  group('Halaman Katalog & Detail', () {
    testWidgets(
      'katalog tampil untuk pengunjung, menyembunyikan tanaman arsip, dan membuka detail',
      (tester) async {
        final api = _clientWith((request) async {
          if (request.url.path == '/api/v1/tujuan-pengelolaan/') {
            return _json([
              {'id': 1, 'slug': 'fitoremediasi-logam', 'nama': 'Fitoremediasi Logam'},
            ], 200);
          }
          if (request.url.path == '/api/v1/tanaman/1/') {
            return _json(_sampleTanamanJson(), 200);
          }
          return _json([
            _sampleTanamanJson(id: 1, nama: 'Akar Wangi', diarsipkan: false),
            _sampleTanamanJson(id: 2, nama: 'Tanaman Arsip', diarsipkan: true),
          ], 200);
        });

        await tester.pumpWidget(
          _wrapApp(KatalogScreen(service: KatalogService(apiClient: api))),
        );
        await tester.pumpAndSettle();

        expect(find.text('Akar Wangi'), findsOneWidget);
        expect(find.text('Tanaman Arsip'), findsNothing);
        expect(find.text('Tambah'), findsNothing);

        await tester.tap(find.text('Akar Wangi'));
        await tester.pumpAndSettle();

        expect(find.byType(DetailTanamanScreen), findsOneWidget);
        await tester.scrollUntilVisible(find.text('Timbal (Pb)'), 200);
        expect(find.text('Timbal (Pb)'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Vetiver System Applications'),
          200,
        );
        expect(find.text('Vetiver System Applications'), findsOneWidget);
      },
    );

    testWidgets(
      'mode admin menampilkan tombol Tambah dan chip Arsip serta form tambah',
      (tester) async {
        final api = _clientWith((request) async {
          if (request.url.path == '/api/v1/tujuan-pengelolaan/') {
            return _json([], 200);
          }
          if (request.method == 'POST' &&
              request.url.path == '/api/v1/tanaman/') {
            return _json(_sampleTanamanJson(id: 9, nama: 'Bambu'), 201);
          }
          return _json([_sampleTanamanJson()], 200);
        });

        await tester.pumpWidget(
          _wrapApp(
            KatalogScreen(
              isAdmin: true,
              service: KatalogService(apiClient: api),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Arsip'), findsOneWidget);
        expect(find.text('Tambah'), findsOneWidget);

        await tester.tap(find.text('Tambah'));
        await tester.pumpAndSettle();

        expect(find.text('Tambah Tanaman'), findsOneWidget);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama tanaman *'),
          'Bambu',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nama ilmiah *'),
          'Bambusa vulgaris',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Fungsi utama *'),
          'Menahan erosi tebing sungai.',
        );

        await tester.scrollUntilVisible(
          find.text('Simpan Tanaman'),
          200,
          scrollable: find.descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          ).first,
        );
        await tester.tap(find.text('Simpan Tanaman'));
        await tester.pumpAndSettle();

        expect(find.byType(KatalogScreen), findsOneWidget);
      },
    );
  });
}
