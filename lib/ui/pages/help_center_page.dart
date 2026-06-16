import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/help_center/help_search_bar.dart';
import '../widgets/help_center/help_category_selector.dart';
import '../widgets/help_center/faq_card.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  String _searchQuery = "";
  String _selectedCategory = "Umum";

  final List<String> _categories = ["Umum", "Transaksi", "Dompet", "Akun"];

  final List<Map<String, String>> _faqs = [
    {
      "category": "Umum",
      "question": "Apa itu Monefy?",
      "answer": "Monefy adalah aplikasi manajemen keuangan pribadi yang membantu Anda mencatat transaksi harian, mengelola beberapa dompet, memantau grafik pengeluaran, melacak tagihan bulanan, serta membuat rencana tabungan (wishlist).",
    },
    {
      "category": "Umum",
      "question": "Apakah aplikasi ini memerlukan koneksi internet?",
      "answer": "Ya, Monefy memerlukan koneksi internet untuk melakukan sinkronisasi data dengan server database, mengautentikasi akun, dan menjalankan fitur AI Scan struk belanja.",
    },
    {
      "category": "Umum",
      "question": "Bagaimana cara kerja fitur AI Scan Struk di Monefy?",
      "answer": "Fitur ini memindai foto struk belanja Anda menggunakan Google Gemini AI. AI akan mendeteksi nominal transaksi secara otomatis dan memasukkannya ke dalam form transaksi baru, sehingga Anda tidak perlu mengetik secara manual.",
    },
    {
      "category": "Transaksi",
      "question": "Bagaimana cara mencatat transaksi baru?",
      "answer": "Tekan tombol tambah (+) di bagian bawah halaman utama, lalu pilih jenis transaksi (Pemasukan, Pengeluaran, atau Transfer). Pilih kategori, ketik nominal menggunakan Numpad, pilih dompet yang digunakan, lalu konfirmasi transaksi Anda.",
    },
    {
      "category": "Transaksi",
      "question": "Apa perbedaan transaksi Transfer dengan Pemasukan/Pengeluaran?",
      "answer": "Transaksi Transfer memindahkan saldo dari satu dompet (dompet asal) ke dompet lain (dompet tujuan). Sementara Pemasukan menambah saldo dompet dan Pengeluaran mengurangi saldo dompet terpilih.",
    },
    {
      "category": "Transaksi",
      "question": "Bagaimana cara menghapus transaksi?",
      "answer": "Masuk ke halaman Riwayat (History), ketuk transaksi yang ingin dihapus untuk membuka detail transaksi, lalu ketuk ikon tempat sampah di sudut kanan atas untuk menghapusnya. Saldo dompet Anda akan otomatis menyesuaikan kembali.",
    },
    {
      "category": "Dompet",
      "question": "Apa saja jenis kategori dompet yang didukung di Monefy?",
      "answer": "Monefy mendukung tiga kategori dompet utama: Tunai (Cash), Rekening Bank (Bank Account), dan Dompet Digital (E-Wallet).",
    },
    {
      "category": "Dompet",
      "question": "Bagaimana cara menambahkan dompet baru?",
      "answer": "Masuk ke halaman 'Dompet Saya', lalu tekan ikon tambah atau tombol 'Tambah Dompet'. Masukkan nama dompet, pilih kategori dompet, dan tentukan tema warna kartu sesuai selera Anda.",
    },
    {
      "category": "Dompet",
      "question": "Kenapa saldo dompet saya tidak berkurang setelah menghapus transaksi transfer?",
      "answer": "Saat Anda menghapus transaksi transfer, sistem backend akan otomatis membatalkan pemindahan saldo (menambahkan kembali ke dompet asal dan mengurangi dari dompet tujuan). Pastikan koneksi internet Anda stabil untuk melihat pembaruan saldo secara real-time.",
    },
    {
      "category": "Akun",
      "question": "Bagaimana cara keluar (logout) dari akun saya?",
      "answer": "Masuk ke halaman Profil Anda, lalu ketuk tombol 'Logout' di bagian bawah. Anda akan diarahkan kembali ke halaman Login dan sesi Anda akan dihapus secara aman.",
    },
    {
      "category": "Akun",
      "question": "Apakah data keuangan saya aman jika saya logout?",
      "answer": "Ya, seluruh data transaksi, dompet, dan wishlist Anda tersimpan dengan aman di server database. Anda dapat mengakses kembali data tersebut kapan saja dengan masuk menggunakan email dan password terdaftar.",
    },
    {
      "category": "Akun",
      "question": "Apakah saya bisa menggunakan satu akun di beberapa perangkat sekaligus?",
      "answer": "Ya, Anda bisa masuk ke akun Monefy Anda di perangkat lain selama menggunakan alamat email dan kata sandi yang sama saat login.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _faqs.where((faq) {
      final matchesCategory = faq["category"] == _selectedCategory;
      final matchesSearch = faq["question"]!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq["answer"]!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFB7AEEB),
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.primaryPurple),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    "Help Center",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),

            /// SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: HelpSearchBar(
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),

            /// CATEGORY SELECTOR (PILLS)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: HelpCategorySelector(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
              ),
            ),

            const SizedBox(height: 10),

            /// LIST PANEL FAQ
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pertanyaan Populer",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (filteredFaqs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              "Tidak ada pertanyaan yang sesuai.",
                              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ...filteredFaqs.map((faq) {
                          return FaqCard(
                            question: faq["question"]!,
                            answer: faq["answer"]!,
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}