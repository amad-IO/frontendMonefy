# <p align="center"><br><img src="https://raw.githubusercontent.com/flutter/artwork/master/logo/flutter_logo.svg" width="120" alt="Flutter Logo"><br>Monefy Mobile Client</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-v3.11.4-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter v3.11.4"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-%5E3.11.4-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart 3"></a>
  <a href="https://pub.dev/packages/provider"><img src="https://img.shields.io/badge/Provider-v6.1.2-4CAF50?style=for-the-badge&logo=dart&logoColor=white" alt="Provider 6"></a>
  <a href="https://pub.dev/packages/skeletonizer"><img src="https://img.shields.io/badge/Skeletonizer-v2.1.3-blueviolet?style=for-the-badge" alt="Skeletonizer 2"></a>
</p>

---

**Monefy** adalah aplikasi mobile pencatatan keuangan harian, analisis pengeluaran, dan manajemen target tabungan yang dirancang dengan antarmuka modern, interaktif, dan performa tinggi. Folder ini (`frontendMonefy`) berfungsi sebagai aplikasi klien (*client-facing*) berbasis mobile yang menyediakan antarmuka premium untuk mengelola dompet (*wallet*), memantau grafik analitik, mencatat tagihan, melacak wishlist tabungan, dan mencatat transaksi harian.

Aplikasi ini dirancang menggunakan arsitektur **Provider Pattern** untuk state management yang bersih dan terstruktur, dilengkapi dengan micro-interactions, skeleton loading, dan integrasi scan struk belanja (OCR) berbasis AI.

---

## Fitur Utama

- **Multi-Wallet Management**: Pengelolaan berbagai jenis dompet (Cash, Bank Account, E-Wallet) dengan pencatatan saldo real-time dan visualisasi kartu ATM yang responsif secara dinamis.
- **Transaksi Dinamis**: Pencatatan Pemasukan (*Income*), Pengeluaran (*Expense*), dan Transfer antar dompet secara instan dengan local balance update dan validasi saldo otomatis.
- **AI Receipt OCR Scanner**: Integrasi kamera & galeri menggunakan Google Gemini API pada backend untuk memindai struk belanja fisik, mengekstraksi nominal secara otomatis, dan melakukan pre-fill jumlah transaksi.
- **Premium Transaction Feedback**: Animasi transisi khusus setinggi 47% layar saat memproses transaksi (ilustrasi flat koin melayang, ring ripple, konfeti, dan tanda centang animasi).
- **Interactive Analytics**: Visualisasi arus kas masuk dan keluar secara grafis per periode menggunakan `fl_chart`.
- **Skeleton Loader UX**: Penerapan skeleton loading berbasis `skeletonizer` pada halaman utama, riwayat, wishlist, dan detail dompet untuk mencegah pergeseran tata letak (layout shift) saat sinkronisasi API.
- **Saving Goals (Wishlist)**: Target tabungan terpadu dengan perhitungan persentase progres capaian tabungan secara visual.
- **Bills Management**: Pelacakan tagihan bulanan dengan indikator status pembayaran Lunas/Belum Lunas (*Paid/Unpaid*).
- **Secure Auth Session**: Fitur login/register otomatis berbasis token JWT yang disimpan secara persisten melalui SharedPreferences.

---

## Technology Stack

| Komponen | Teknologi | Versi |
| :--- | :--- | :--- |
| **Framework** | Flutter SDK | `^3.11.4` |
| **Language** | Dart | `^3.11.4` |
| **State Management** | Provider | `^6.1.2` |
| **UI Skeletonizer** | skeletonizer | `^2.1.3` |
| **Visual Charts** | fl_chart | `^0.70.2` |
| **HTTP Client** | http | `^1.6.0` |
| **Local Storage** | shared_preferences | `^2.5.5` |
| **Camera & Picker** | camera / image_picker | `^0.12.0+1` / `^1.1.2` |

---

## Struktur Direktori

Berikut adalah struktur file dan folder utama pada proyek frontend mobile untuk mempermudah proses pengembangan:

```bash
frontendMonefy/
├── assets/
│   ├── fonts/                # File font Nunito (Regular, Medium, SemiBold, Bold)
│   ├── icon/                 # File icon aplikasi
│   └── images/               # Ilustrasi dan gambar aset pendukung
├── lib/
│   ├── config/
│   │   └── app_config.dart   # Alamat Base URL API Backend
│   ├── core/
│   │   ├── theme/            # Skema warna utama (app_colors) & tipografi (app_text_styles)
│   │   └── utils/            # Helper formatting nominal, resolver kategori, dan UI styling
│   ├── data/
│   │   ├── models/           # Data model (Transaction, Wallet, Saving, User, Auth)
│   │   └── services/         # API Service komunikasi ke Laravel Backend (Auth, Saving, Scan, dll)
│   ├── providers/            # State management providers (Auth, Transaction, Wallet, Saving)
│   ├── ui/
│   │   ├── pages/            # Layar aplikasi (Home, Add, History, Analytics, Saving, Bills, dll)
│   │   └── widgets/          # Komponen reusable (Cards, Numpad, Loading/Success feedback panel)
│   └── main.dart             # Entry point aplikasi & inisialisasi session & multi-providers
├── pubspec.yaml              # Konfigurasi dependensi dan aset Flutter
└── README.md                 # Dokumentasi proyek
```

---

## Prasyarat Sistem

Sebelum memulai, pastikan komputer Anda telah memenuhi persyaratan berikut:
1. **Flutter SDK** `>= 3.11.4`
2. **Dart SDK** `^3.11.4`
3. **Android Studio** / **VS Code** dengan plugin Flutter & Dart
4. **Android Emulator**, **iOS Simulator**, atau perangkat HP fisik yang terhubung via USB Debugging.

*Catatan: Pastikan server **Monefy Backend API** Anda sudah berjalan (default: `http://127.0.0.1:8000`) sebelum menjalankan aplikasi Flutter ini.*

---

## Langkah Instalasi & Setup Lokal

Ikuti langkah-langkah berikut untuk menjalankan aplikasi mobile secara lokal:

### 1. Navigasi ke Folder Frontend
Buka terminal Anda, lalu masuk ke direktori proyek frontend:
```bash
cd frontendMonefy
```

### 2. Install Dependencies
Unduh semua dependensi package Flutter yang tercantum pada pubspec:
```bash
flutter pub get
```

### 3. Konfigurasi Endpoint API
Buka file `lib/config/app_config.dart` di editor kode Anda, lalu sesuaikan URL API dengan alamat IP lokal komputer/laptop Anda (jangan gunakan *localhost* jika Anda menguji di HP fisik/emulator eksternal):
```dart
class AppConfig {
  // Ganti IP_KOMPUTER_ANDA dengan IP lokal komputer Anda (misal: 192.168.1.10)
  static const String baseUrl = 'http://IP_KOMPUTER_ANDA:8000/api';
}
```

### 4. Memastikan Koneksi Jaringan
Pastikan perangkat emulator atau HP fisik yang digunakan berada pada **satu jaringan WiFi yang sama** dengan komputer server Laravel agar koneksi API dapat terjalin dengan sukses.

---

## Menjalankan Aplikasi Mobile

Jalankan perintah berikut di terminal Anda untuk membuild dan menjalankan aplikasi ke perangkat target:

```bash
# Menjalankan aplikasi dalam Debug Mode (Hot Reload aktif)
flutter run

# Menjalankan aplikasi dalam Release Mode (Performa lebih ringan & optimal)
flutter run --release
```
