# Rencana Kerja Wiji Mobile

Dokumen ini isinya pembagian kerja Wiji Mobile: tiap orang ngerjain apa, endpoint API apa yang dibikin, halaman apa yang ada di HP, dan kapan harus jadi. Kalau bingung mau ngerjain apa, buka bagian modulmu di bawah.

Acuan:

- Soal tugas: Proyek Akhir Semester PBP (Flutter + Django REST Framework)
- Repo web: [pbp-kelompok-d12/wiji](https://github.com/pbp-kelompok-d12/wiji), web live di [PWS](https://muhammad-osman-wiji.pws.cs.ui.ac.id/)
- Istilah: [DOMAIN.md di repo web](https://github.com/pbp-kelompok-d12/wiji/blob/main/docs/DOMAIN.md)
- Pola API: Tutorial 07 (DRF). Pola halaman dan navigasi: Tutorial 08 sampai 09 (Flutter)

## Gambaran Singkat

- Wiji Mobile itu versi HP dari web Wiji. **Datanya tetap di Django Wiji** (database yang sama dengan web di PWS). Aplikasi HP cuma ngambil dan ngirim data lewat API.
- API-nya **wajib pakai Django REST Framework (DRF)**. Endpoint JSON lama di web (yang pakai `JsonResponse`) nggak dihitung, jadi kita bikin versi DRF-nya di `/api/v1/`.
- Satu orang pegang satu modul, sama kayak di proyek web. Tiap modul ada dua bagian:
  1. **API DRF** di repo `wiji` (Django), di app modulnya sendiri.
  2. **Halaman Flutter** di repo `wiji-mobile`, di folder modulnya sendiri.

## Pembagian Modul

| Modul | Penanggung jawab | Di HP ngapain | App Django | Folder Flutter |
|---|---|---|---|---|
| Bersama | Muhammad Osman Fardin | Kerangka aplikasi, tema, navigasi, login dan daftar, beranda, pasang DRF | `accounts`, `config` | `lib/core/`, `lib/features/auth/`, `lib/features/home/` |
| A. Manajemen Lahan | Rania Fauziah Nur Wahyudi | Daftar, tambah, ubah, arsip, dan hapus lahan | `lands` | `lib/features/lahan/` |
| B. Pemesanan Pemeriksaan | Muhammad Osman Fardin | Pesan pemeriksaan, batal, jadwal ulang, tugas petugas | `inspections` | `lib/features/pemeriksaan/` |
| C. Hasil Pemeriksaan Tanah | Nadya Sekar Kayrana | Lihat hasil, hasil mandiri, petugas isi dan finalin hasil | `soil_results` | `lib/features/hasil/` |
| D. Katalog Tanaman | Yosua Peitho Purba | Cari dan filter tanaman, detail, admin kelola katalog | `core` | `lib/features/katalog/` |
| E. Rekomendasi dan Rencana | Piedra Ridwan Azra Pulungan | Hitung rekomendasi per lahan, simpan dan kelola rencana tanam | `recommendations` | `lib/features/rekomendasi/` |

## Peran di Aplikasi HP

| Peran | Bisa ngapain di HP |
|---|---|
| Pengunjung (belum login) | Liat katalog tanaman, daftar akun, masuk |
| Pemilik Lahan | Semua modul: lahan, pesan pemeriksaan, hasil, katalog, rekomendasi, rencana tanam |
| Petugas Pemeriksa | Liat tugas, majuin status pemeriksaan, isi dan finalin hasil, liat katalog |
| Admin (akun staf) | Kelola katalog tanaman |

Urusan admin yang lain (konfirmasi pesanan, nugasin petugas, jadwal final, bikin akun petugas, kelola jenis pemeriksaan) **tetap di web**. Biar scope HP nggak kegedean.

---

## Aturan Bareng

### API DRF (repo `wiji`)

- Semua endpoint baru ada di bawah **`/api/v1/`**, akhiran `/` wajib.
- Tiap app bikin file sendiri, polanya kayak Tutorial 07:
  - `serializers.py`: bentuk JSON dan validasi input
  - `api_views.py`: view DRF pakai `@api_view`
  - `api_urls.py`: rute modulmu (file-nya udah disiapin kosong dari kerangka, tinggal diisi)
  - `test_api_v1.py`: test API (di `inspections` taruh di `inspections/tests/test_api_v1.py`)
- Autentikasi dan permission bareng ada di `accounts/permissions.py` (`IsPemilik`, `IsPetugas`, `IsAdminWiji`) plus daftar autentikasi `API_AUTH`. **Pakai yang itu**, jangan bikin sendiri-sendiri, biar kalau cara login berubah cukup diganti di satu tempat.
- **Aturan bisnis jangan ditulis ulang.** Panggil fungsi yang udah ada di web (misalnya `inspections/pemesanan.py`, `inspections/services.py`), biar HP sama web hasilnya sama persis.
- **Endpoint JSON lama jangan dihapus.** Web masih bisa pakai. Yang DRF jalan bareng.
- Data punya orang lain dibalas **404**, bukan 403, biar nggak bocor kalau datanya ada.
- Field yang nggak boleh diisi dari luar (id, status, pemilik, tanggal dibuat) dibikin `read_only`.
- Pemilik data selalu diambil dari `request.user`, jangan dari isi request.
- Pesan error pakai bahasa Indonesia. Format error ikut bawaan DRF: `{"nama_field": ["pesan"]}` atau `{"detail": "pesan"}`.
- Tanggal pakai format `YYYY-MM-DD`, waktu pakai ISO 8601. ID lahan itu UUID (string), sisanya angka.
- Tiap endpoint minimal dites: belum login, peran salah, data orang lain, input salah, sama method yang nggak boleh.

### Flutter (repo `wiji-mobile`)

Struktur folder:

```
lib/
├── main.dart
├── core/                 # bareng, jangan diubah tanpa ngabarin
│   ├── api/              # ApiClient: alamat server, header login, baca JSON
│   ├── theme/            # warna dan gaya teks Wiji
│   └── widgets/          # widget umum: kartu, badge status, keadaan kosong/error
└── features/
    ├── auth/             # bareng: masuk, daftar
    ├── home/             # bareng: beranda dan navigasi
    ├── lahan/            # A
    ├── pemeriksaan/      # B
    ├── hasil/            # C
    ├── katalog/          # D
    └── rekomendasi/      # E
```

Isi tiap folder modul:

```
features/<modul>/
├── models/      # class data + fromJson/toJson, contoh lahan.dart
├── services/    # fungsi panggil API modul ini, contoh lahan_service.dart
├── screens/     # halaman, contoh daftar_lahan_screen.dart
└── widgets/     # widget yang cuma dipakai modul ini
```

Aturannya:

- Pakai paket `material_ui` kayak Tutorial 09 (`import 'package:material_ui/material_ui.dart';`).
- **Semua request lewat `ApiClient` di `lib/core/api/`.** Jangan nulis alamat server sendiri di halaman.
- Data dari API diubah jadi class model pakai `fromJson`. Jangan baca `Map` mentah di widget.
- Tiap halaman yang ngambil data wajib punya 3 keadaan: **lagi loading**, **gagal** (ada tombol coba lagi), dan **kosong**.
- Warna, ukuran teks, dan jarak ambil dari tema (`lib/core/theme/`). Jangan nulis kode warna langsung di halaman. Kalau butuh widget yang sama di dua tempat, taruh di `core/widgets/`.
- Form wajib ada validasi, tombol kirim dimatiin pas lagi ngirim (biar nggak dobel), dan habis berhasil muncul `SnackBar`.
- Nama file `snake_case`, nama class `UpperCamelCase`. Istilah ikut Django (`Lahan`, `Pesanan`, `Hasil`, `Tanaman`, `Rencana`) biar gampang dicocokin.
- Komentar secukupnya, di bagian yang butuh penjelasan aja.

### Pintu masuk antarmodul

Modul saling buka halaman. Biar nggak bentrok, ini kesepakatan parameternya:

| Dari | Ke | Cara |
|---|---|---|
| Detail lahan (A) | Form pesan pemeriksaan (B) | `FormPesananScreen(lahanId: ...)` |
| Detail lahan (A) | Daftar hasil (C) | `DaftarHasilScreen(lahanId: ...)` |
| Detail lahan (A) | Rekomendasi (E) | `RekomendasiScreen(lahanId: ...)` |
| Detail tugas (B, petugas) | Isi hasil (C) | `IsiHasilScreen(pesananId: ...)` |
| Rekomendasi (E) | Detail tanaman (D) | `DetailTanamanScreen(tanamanId: ...)` |

Model `Lahan` dipakai B, C, dan E juga. Yang bikin A (`features/lahan/models/lahan.dart`), yang lain tinggal import.

---

## Detail per Modul

Kolom **CP1** di tabel endpoint: ✅ artinya harus udah jalan di PWS pas Checkpoint 1 (Jumat 20 Nov). Sisanya dikerjain setelah CP1.

### Bersama: Kerangka, Login, dan Beranda

**Penanggung jawab:** Muhammad Osman Fardin

**Yang dibikin:**

- Pasang DRF di Django, rute `/api/v1/`, `api_urls.py` kosong di tiap app, permission dan autentikasi bareng.
- Project Flutter, tema warna Wiji (diambil dari `wiji.css`), `ApiClient`, widget umum, navigasi per peran.
- Halaman masuk, daftar, dan beranda (ringkasan sesuai peran).
- Logo aplikasi, build APK, rilis di GitHub dan Bitrise.

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| POST | `/api/v1/auth/login/` | Semua | Masuk pakai username dan password, balikin data akun | |
| POST | `/api/v1/auth/register/` | Semua | Daftar akun pemilik lahan | |
| POST | `/api/v1/auth/logout/` | Login | Keluar | |
| GET | `/api/v1/auth/me/` | Login | Data akun yang lagi login (nama, peran) | |

**Selesai kalau:**

- [ ] Semua anggota bisa jalanin aplikasi dari instruksi README.
- [ ] Navigasi ke tiap modul jalan, menu sesuai peran.
- [ ] Login, daftar, dan logout jalan dari HP ke PWS.
- [ ] APK ada di GitHub Release dan Bitrise, pakai logo Wiji.

### Modul A: Manajemen Lahan

**Penanggung jawab:** Rania Fauziah Nur Wahyudi

**Ngapain:** pemilik ngatur data lahannya dari HP. Lahan ini jadi dasar buat modul lain (pesanan, hasil, rekomendasi).

**Halaman:**

- **Daftar lahan:** tab aktif dan arsip, kotak cari nama, tombol tambah.
- **Detail lahan:** nama, alamat, koordinat, luas, penggunaan, kondisi, tujuan. Tombol ke modul lain: pesan pemeriksaan (B), lihat hasil (C), rekomendasi (E).
- **Form lahan:** tambah dan ubah. Cari alamat lewat server (Nominatim), pilih penggunaan, pilih tujuan pengelolaan.
- Konfirmasi arsip, pulihkan, dan hapus (hapus cuma kalau lahannya belum punya riwayat).

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| GET | `/api/v1/lahan/` | Pemilik | Lahan sendiri. `?arsip=1` buat yang diarsipkan, `?q=` cari nama | ✅ |
| POST | `/api/v1/lahan/` | Pemilik | Tambah lahan | |
| GET | `/api/v1/lahan/<uuid>/` | Pemilik | Detail lahan | ✅ |
| PATCH | `/api/v1/lahan/<uuid>/` | Pemilik | Ubah lahan | |
| DELETE | `/api/v1/lahan/<uuid>/` | Pemilik | Hapus (ditolak kalau udah punya riwayat: pesanan, hasil, rekomendasi, atau rencana) | |
| POST | `/api/v1/lahan/<uuid>/arsip/` | Pemilik | Arsipkan (ditolak kalau ada pesanan aktif) | |
| POST | `/api/v1/lahan/<uuid>/pulihkan/` | Pemilik | Pulihin dari arsip | |
| GET | `/api/v1/tujuan-pengelolaan/` | Login | Pilihan tujuan buat form (dipakai E juga) | ✅ |
| GET | `/api/v1/lokasi/cari/?q=` | Login | Cari alamat, balikin daftar nama tempat dan koordinat | |

**Selesai kalau:**

- [ ] Pemilik bisa tambah, liat, ubah, arsip, pulihin, dan hapus lahan dari HP.
- [ ] Lahan yang ditambah di HP langsung muncul di web, dan sebaliknya.
- [ ] Pemilik lain nggak bisa liat lahanmu (404).
- [ ] Aturan arsip dan hapus sama kayak di web.

**Ide fitur tambahan (opsional):** ambil koordinat dari GPS HP, cuaca dan iklim lahan dari endpoint yang udah ada di web.

### Modul B: Pemesanan Pemeriksaan

**Penanggung jawab:** Muhammad Osman Fardin

**Ngapain:** pemilik mesen pemeriksaan tanah buat lahannya dan mantau statusnya. Petugas liat tugasnya dan majuin status sampai siap diisi hasil.

**Halaman:**

- **Daftar pesanan (pemilik):** filter status, kode pesanan, lahan, jenis, tanggal.
- **Detail pesanan (pemilik):** status, jadwal, petugas, riwayat perubahan. Tombol batal dan minta jadwal ulang (dialog).
- **Form pesan pemeriksaan:** pilih lahan, jenis pemeriksaan, tanggal usulan, sesi (pagi atau siang), catatan. Bisa dibuka dari detail lahan.
- **Daftar tugas (petugas):** pesanan yang ditugasin ke dia.
- **Detail tugas (petugas):** info lahan dan jadwal, tombol "Tandai sampel diambil" lalu "Mulai proses", tombol ke isi hasil (C).

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| GET | `/api/v1/jenis-pemeriksaan/` | Login | Pilihan jenis pemeriksaan buat form | ✅ |
| GET | `/api/v1/pesanan/` | Pemilik | Pesanan sendiri, `?status=` | ✅ |
| POST | `/api/v1/pesanan/` | Pemilik | Pesan pemeriksaan | ✅ |
| GET | `/api/v1/pesanan/<id>/` | Pemilik | Detail plus riwayat | ✅ |
| PATCH | `/api/v1/pesanan/<id>/` | Pemilik | Ubah usulan (cuma pas masih Diajukan) | |
| POST | `/api/v1/pesanan/<id>/batalkan/` | Pemilik | Batalin pesanan plus alasan | |
| POST | `/api/v1/pesanan/<id>/jadwal-ulang/` | Pemilik | Minta jadwal ulang | |
| GET | `/api/v1/tugas/` | Petugas | Tugas yang ditugasin ke petugas itu | |
| GET | `/api/v1/tugas/<id>/` | Petugas | Detail tugas | |
| POST | `/api/v1/tugas/<id>/lanjut/` | Petugas | Majuin status: Dijadwalkan → Sampel diambil → Diproses | |

**Selesai kalau:**

- [ ] Pemilik bisa pesan, liat, ubah usulan, batal, dan minta jadwal ulang dari HP.
- [ ] Petugas bisa liat tugas dan majuin status dari HP.
- [ ] Aturan sama kayak web: satu lahan cuma boleh satu pesanan aktif, status cuma maju satu arah, tiap perubahan masuk riwayat.
- [ ] Pesanan dari HP langsung muncul di halaman admin web.

**Ide fitur tambahan (opsional):** riwayat status dalam bentuk timeline, tarik ke bawah buat refresh.

### Modul C: Hasil Pemeriksaan Tanah

**Penanggung jawab:** Nadya Sekar Kayrana

**Ngapain:** pemilik liat hasil pemeriksaan lahannya dan bisa masukin hasil mandiri (dari lab luar). Petugas ngisi hasil buat pesanan yang lagi diproses, terus finalin.

**Halaman:**

- **Daftar hasil:** filter per lahan dan asal (Hasil Mandiri atau Hasil Wiji), status draf atau final.
- **Detail hasil:** pH, kelembapan, tekstur, bahan organik, unsur hara, temuan kontaminan, catatan, asal data.
- **Form hasil mandiri:** tambah dan ubah, plus tambah atau hapus unsur hara dan kontaminan.
- **Isi hasil (petugas):** isi draf buat pesanan yang statusnya Diproses, terus tombol finalin. Pas difinalin, pesanannya otomatis jadi Selesai.

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| GET | `/api/v1/hasil/` | Pemilik, petugas | Hasil yang boleh diliat, `?lahan=<uuid>`, `?asal=mandiri` atau `wiji` | ✅ |
| POST | `/api/v1/hasil/` | Pemilik | Tambah hasil mandiri | |
| GET | `/api/v1/hasil/<id>/` | Pemilik lahan, petugas yang nanganin, admin | Detail lengkap plus unsur hara dan kontaminan | ✅ |
| PATCH | `/api/v1/hasil/<id>/` | Pemilik (mandiri), petugas (draf) | Ubah hasil | |
| DELETE | `/api/v1/hasil/<id>/` | Pemilik | Hapus hasil mandiri | |
| POST | `/api/v1/hasil/<id>/unsur-hara/` | Sama kayak ubah | Tambah unsur hara | |
| PATCH, DELETE | `/api/v1/unsur-hara/<id>/` | Sama kayak ubah | Ubah atau hapus unsur hara | |
| POST | `/api/v1/hasil/<id>/kontaminan/` | Sama kayak ubah | Tambah temuan kontaminan | |
| PATCH, DELETE | `/api/v1/kontaminan/<id>/` | Sama kayak ubah | Ubah atau hapus temuan | |
| POST | `/api/v1/tugas/<pesanan_id>/hasil/` | Petugas | Bikin atau lanjutin draf hasil buat pesanan | |
| POST | `/api/v1/hasil/<id>/finalisasi/` | Petugas | Finalin hasil, pesanan jadi Selesai | |

Dokumen laboratorium tetap diunggah dan diunduh lewat web.

**Selesai kalau:**

- [ ] Pemilik bisa liat semua hasil lahannya, dan tambah, ubah, hapus hasil mandiri dari HP.
- [ ] Petugas bisa isi draf dan finalin hasil dari HP, dan pesanannya jadi Selesai.
- [ ] Hasil final nggak bisa diubah dari HP (koreksi tetap lewat web).
- [ ] Kontaminan kosong tetap dianggap "belum diketahui", sama kayak aturan web.

**Ide fitur tambahan (opsional):** indikator warna buat pH (asam, netral, basa), bandingin dua hasil di lahan yang sama.

### Modul D: Katalog Tanaman

**Penanggung jawab:** Yosua Peitho Purba

**Ngapain:** semua orang (termasuk yang belum login) bisa cari dan liat info tanaman. Admin bisa kelola katalog dari HP.

**Halaman:**

- **Katalog:** kotak cari (nama, nama ilmiah, fungsi), filter tujuan, jenis (umum atau fitoremediasi), dan "tersedia di Indonesia".
- **Detail tanaman:** fungsi, deskripsi, kondisi tumbuh, kontaminan yang bisa ditangani, risiko, ketersediaan, referensi.
- **Form tanaman (admin):** tambah dan ubah, plus arsip, pulihkan, dan hapus.

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| GET | `/api/v1/tanaman/` | Publik | Daftar tanaman, `?q=`, `?tujuan=<slug>`, `?jenis=umum` atau `fitoremediasi`, `?lokal=1`. Admin bisa `?arsip=1` | ✅ |
| GET | `/api/v1/tanaman/<id>/` | Publik | Detail plus kemampuan kontaminan dan referensi | ✅ |
| POST | `/api/v1/tanaman/` | Admin | Tambah tanaman | |
| PATCH | `/api/v1/tanaman/<id>/` | Admin | Ubah tanaman | |
| DELETE | `/api/v1/tanaman/<id>/` | Admin | Hapus (ditolak kalau udah dipakai rekomendasi) | |
| POST | `/api/v1/tanaman/<id>/arsip/` | Admin | Arsipkan | |
| POST | `/api/v1/tanaman/<id>/pulihkan/` | Admin | Pulihin dari arsip | |
| GET | `/api/v1/jenis-kontaminan/` | Publik | Daftar kontaminan (dipakai form hasil di C juga) | |

**Selesai kalau:**

- [ ] Katalog bisa dibuka tanpa login, pencarian dan filter jalan.
- [ ] Admin bisa tambah, ubah, arsip, pulihin, dan hapus tanaman dari HP.
- [ ] Tanaman yang diarsipkan nggak muncul buat pengunjung.
- [ ] Minimal 50 tanaman dari web muncul di HP.

**Ide fitur tambahan (opsional):** pencarian langsung jalan pas ngetik (debounce), tandai tanaman favorit di HP.

### Modul E: Rekomendasi dan Rencana Pengelolaan

**Penanggung jawab:** Piedra Ridwan Azra Pulungan

**Ngapain:** pemilik milih lahan, hasil pemeriksaan final, dan tujuan, terus dapet rekomendasi tanaman. Tanaman yang cocok bisa disimpen jadi rencana tanam.

**Halaman:**

- **Rekomendasi:** pilih lahan, hasil final, dan tujuan. Daftar tanaman plus skor dan alasannya, daftar yang diblokir plus alasannya, dan peringatan kalau hasilnya berisiko tinggi (kontaminan).
- **Daftar rencana:** filter status (direncanakan, sedang berjalan, selesai).
- **Detail rencana:** tanaman, lahan, skor, alasan, jumlah bibit, tanggal tanam, catatan.
- **Form rencana:** simpan dari rekomendasi, ubah bibit, tanggal, catatan, dan status. Hapus rencana.

**Endpoint:**

| Method | Endpoint | Akses | Fungsi | CP1 |
|---|---|---|---|---|
| GET | `/api/v1/lahan/<uuid>/hasil-final/` | Pemilik | Hasil final lahan buat dipilih | |
| GET | `/api/v1/lahan/<uuid>/rekomendasi/?hasil=<id>&tujuan=<id>` | Pemilik | Hitung rekomendasi (nggak nyimpen apa-apa) | ✅ |
| GET | `/api/v1/rencana/` | Pemilik | Rencana sendiri, `?status=` | ✅ |
| POST | `/api/v1/rencana/` | Pemilik | Simpan rekomendasi jadi rencana | |
| GET | `/api/v1/rencana/<id>/` | Pemilik | Detail rencana | ✅ |
| PATCH | `/api/v1/rencana/<id>/` | Pemilik | Ubah bibit, tanggal, catatan, status | |
| DELETE | `/api/v1/rencana/<id>/` | Pemilik | Hapus rencana | |

**Selesai kalau:**

- [ ] Pemilik bisa dapet rekomendasi dari HP, hasilnya sama kayak di web.
- [ ] Kontaminan terdeteksi bikin rekomendasi otomatis berhenti dan muncul peringatan, sama kayak web.
- [ ] Pemilik bisa simpan, liat, ubah, dan hapus rencana dari HP.
- [ ] Rencana dari HP langsung muncul di web.

**Ide fitur tambahan (opsional):** bar skor kecocokan berwarna, pengingat tanggal tanam.

---

## Checklist Checkpoint 1 per Orang

Deadline internal: **Jumat 20 Nov jam 18.00**, biar sisa waktunya buat gabungin.

| Siapa | Repo `wiji` (PR ke `main`) | Repo `wiji-mobile` (PR ke `dev`) |
|---|---|---|
| Osman (Bersama) | Pasang DRF, `/api/v1/`, permission bareng | Kerangka Flutter, tema, navigasi, README |
| Osman (B) | Endpoint B yang ✅ plus test | Halaman daftar pesanan (boleh isi contoh dulu) |
| Rania (A) | Endpoint A yang ✅ plus test | Halaman daftar lahan (boleh isi contoh dulu) |
| Nadya (C) | Endpoint C yang ✅ plus test | Halaman daftar hasil (boleh isi contoh dulu) |
| Yosua (D) | Endpoint D yang ✅ plus test | Halaman katalog. Endpoint-nya publik, jadi bisa langsung pakai data asli |
| Piedra (E) | Endpoint E yang ✅ plus test | Halaman daftar rencana (boleh isi contoh dulu) |

Cara ngecek endpoint udah jalan: login di web PWS, terus buka alamat endpoint-nya di browser. Harusnya muncul halaman Browsable API dari DRF, bukan 404.

## Yang Masih Perlu Disepakati

1. **Cara login dari HP.** Cara Tutorial 07 (session plus CSRF) bakal nolak POST dari HP di PWS, soalnya Flutter nggak ngirim header `Referer`. Usulan: tambah `TokenAuthentication` bawaan DRF di `API_AUTH`. Kalau nanti tutorial Flutter ngajarin cara lain, kita ikut tutorial. Endpoint tetap sama, cuma isi `API_AUTH` sama `ApiClient` yang diganti.
2. **Navigasi.** Usulan: drawer dengan menu sesuai peran, plus kartu menu di beranda (kayak Tutorial 09). Kalau desain Figma milih bar bawah, ikut Figma.
3. **Admin di HP cuma kelola katalog.** Sisanya tetap di web.
