# MONEFY — App Summary 

> **Tujuan file ini:**  memahami keseluruhan aplikasi tanpa perlu membaca setiap file.  
> **Last updated:** 2026-05-16

---

## 1. OVERVIEW APLIKASI

**Monefy** adalah aplikasi mobile pencatatan keuangan harian & tabungan berbasis Flutter (frontend) + Laravel (backend).

### Fitur Utama
| Fitur | Deskripsi |
|---|---|
| **Wallet** | Kelola dompet (Cash, Bank Account, E-Wallet) dengan saldo real-time |
| **Transaksi** | Catat Income / Expense / Transfer antar wallet |
| **History** | Riwayat semua transaksi dengan filter (hari/minggu/bulan/tahun) |
| **Analytics** | Grafik pengeluaran & pemasukan per periode |
| **Saving (Wishlist)** | Target tabungan berbasis wishlist dengan progress |
| **Bills** | Catat tagihan bulanan & tandai sudah/belum dibayar |
| **Scan Receipt** | OCR via Gemini AI untuk pre-fill nominal transaksi dari foto struk |

---

## 2. TECH STACK

| Layer | Tech |
|---|---|
| Frontend | Flutter (Dart), Provider (state management) |
| Backend | Laravel 10, Sanctum (auth token) |
| Database | MySQL |
| HTTP Client | `package:http` |
| AI OCR | Google Gemini API (via `AiScanController.php`) |
| Storage | SharedPreferences (token persistence) |

**Base URL:** `http://dapat berubah setiap ganti wifi:8000/api` (defined in `lib/config/app_config.dart`)

---

## 3. STRUKTUR FOLDER FRONTEND

```
frontendMonefy/
├── lib/
│   ├── config/
│   │   └── app_config.dart          # Base URL API
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart      # Color palette + WalletTheme + gradients
│   │   │   └── app_text_styles.dart # Typography
│   │   └── utils/
│   │       └── add_page_helper.dart # Helper: formatAmount, resolveCategory, validate
│   │
│   ├── data/
│   │   ├── api_services.dart        # Generic HTTP helper (unused, legacy)
│   │   ├── models/
│   │   │   ├── transaction_model.dart   # TransactionModel + TransactionType enum
│   │   │   ├── wallet_model.dart        # WalletModel + WalletCategory enum + WalletTheme
│   │   │   ├── saving_model.dart        # SavingModel (wishlist/target tabungan)
│   │   │   ├── summary_model.dart       # SummaryModel (total balance, income, expense)
│   │   │   ├── user_model.dart          # UserModel
│   │   │   ├── auth_response.dart       # AuthResponse (login/register)
│   │   │   ├── login_request.dart       # LoginRequest
│   │   │   ├── sign_up_request.dart     # SignUpRequest
│   │   │   └── analytic/
│   │   │       └── analytic_models.dart # AnalyticSummary untuk chart
│   │   └── services/
│   │       ├── auth_service.dart        # POST /login, POST /register
│   │       ├── transaction_service.dart # CRUD transaksi via API
│   │       ├── dashboard_service.dart   # GET /dashboard/summary
│   │       ├── saving_service.dart      # CRUD wishlist via API
│   │       ├── scan_service.dart        # POST /ai/scan-receipt (Gemini OCR)
│   │       └── analytics_calculator.dart# Hitung analitik lokal dari list transaksi
│   │
│   ├── providers/
│   │   ├── auth_provider.dart       # Login/logout state + token management
│   │   ├── transaction_provider.dart# CRUD transaksi + summary + analytics + enrich
│   │   ├── wallet_provider.dart     # CRUD wallet + balance update
│   │   └── saving_provider.dart     # CRUD saving (wishlist target)
│   │
│   ├── ui/
│   │   ├── pages/
│   │   │   ├── login_page.dart          # Halaman login
│   │   │   ├── sign_up_page.dart        # Halaman register
│   │   │   ├── home_page.dart           # Dashboard utama (summary card + history)
│   │   │   ├── main_page.dart           # Shell navigasi bottom navbar
│   │   │   ├── add_page.dart            # Tambah/edit transaksi (Income/Expense/Transfer)
│   │   │   ├── history_page.dart        # Riwayat transaksi + filter + search
│   │   │   ├── analytic_page.dart       # Grafik analitik pengeluaran/pemasukan
│   │   │   ├── your_wallet_page.dart    # List semua wallet + total balance
│   │   │   ├── wallet_category_page.dart# Detail per kategori wallet (Cash/Bank/E-Wallet)
│   │   │   ├── create_wallet_page.dart  # Form buat wallet baru
│   │   │   ├── saving_page.dart         # Halaman target tabungan (wishlist)
│   │   │   ├── bills_page.dart          # Halaman tagihan bulanan
│   │   │   ├── profile_page.dart        # Profil user + logout
│   │   │   └── scan_page.dart           # OCR scan struk (bottom sheet 75% height)
│   │   │
│   │   ├── widgets/
│   │   │   ├── card_history.dart            # Card satu transaksi di list history
│   │   │   ├── transaction_detail_sheet.dart# Bottom sheet detail transaksi
│   │   │   ├── wallet_card.dart             # Kartu wallet style ATM card
│   │   │   ├── summary_card.dart            # Kartu ringkasan balance/income/expense
│   │   │   ├── history_section.dart         # Section list transaksi + filter tab
│   │   │   ├── quick_access.dart            # Shortcut button di home
│   │   │   ├── confirm_dialog.dart          # Dialog konfirmasi universal (reusable)
│   │   │   ├── auth_form.dart               # Form login/register reusable
│   │   │   ├── saving_card.dart             # Card satu saving target
│   │   │   ├── saving_list.dart             # List semua saving targets
│   │   │   ├── saving_detail_dialog.dart    # Dialog detail saving target
│   │   │   ├── create_saving_modal.dart     # Modal buat saving target baru
│   │   │   ├── bills_input.dart             # Form input tagihan baru
│   │   │   ├── input_add_wallet.dart        # Input field untuk form wallet
│   │   │   ├── transaction_type_selector.dart# Selector tipe transaksi
│   │   │   ├── add_page/                    # Sub-widget AddPage
│   │   │   │   ├── sliding_pill.dart        # Tab switcher Income/Expense/Transfer
│   │   │   │   ├── category_area.dart       # Area pilih kategori (FilterIncome/Expense/Transfer)
│   │   │   │   └── input_row.dart           # Row input title + wallet selector
│   │   │   ├── analytic/                    # Sub-widget AnalyticPage
│   │   │   └── navbar/                      # Bottom navigation bar
│   │   │
│   │   └── components/
│   │       ├── filter_income.dart       # Bubble kategori Income (Salary, Freelance, dll)
│   │       ├── filter_expense.dart      # Bubble kategori Expense (Food, Transport, dll)
│   │       ├── filter_transfer.dart     # Bubble pilih To Wallet saat Transfer
│   │       ├── numpad.dart              # Custom numpad input nominal
│   │       └── wallet_selector_popup.dart # Bottom sheet pilih From Wallet
│   │
│   └── main.dart                    # Entry point: setup Providers + auto-login
```

---

## 4. STRUKTUR FOLDER BACKEND

```
Backend-Monefy/
├── app/
│   ├── Http/Controllers/Api/
│   │   ├── AuthController.php       # POST /register, POST /login
│   │   ├── WalletController.php     # GET/POST /wallets
│   │   ├── TransactionController.php# GET/POST/PUT/DELETE /transactions
│   │   ├── DashboardController.php  # GET /dashboard/summary
│   │   ├── WishlistController.php   # GET/POST/PUT /wishlists
│   │   ├── BillController.php       # GET/POST /bills + mark paid/unpaid
│   │   └── AiScanController.php     # POST /ai/scan-receipt (Gemini OCR)
│   │
│   └── Models/
│       ├── User.php                 # Relasi: hasMany wallets, transactions
│       ├── Wallet.php               # fillable: user_id, name_wallet, balance, category
│       ├── Transaction.php          # fillable: user_id, wallet_id, to_wallet_id, ...
│       ├── Wishlist.php             # fillable: user_id, name, target_amount, ...
│       └── bill.php                 # fillable: user_id, name, amount, due_date, ...
│
├── routes/
│   └── api.php                      # Semua route API (lihat section 5)
│
└── database/migrations/             # Schema tabel
```

---

## 5. API ROUTES (Backend)

```
# Public (tanpa auth)
POST   /api/register                 AuthController@register
POST   /api/login                    AuthController@login
POST   /api/ai/scan-receipt          AiScanController@scan

# Protected (Bearer token Sanctum)
GET    /api/wallets                  WalletController@index
POST   /api/wallets                  WalletController@store
# ⚠️ Tidak ada DELETE /wallets/{id} — hapus wallet belum diimplementasi di backend

GET    /api/transactions             TransactionController@index
POST   /api/transactions             TransactionController@store
PUT    /api/transactions/{id}        TransactionController@update
DELETE /api/transactions/{id}        TransactionController@destroy

GET    /api/dashboard/summary        DashboardController@getSummary

GET    /api/wishlists                WishlistController@index
POST   /api/wishlists                WishlistController@store
PUT    /api/wishlists/{id}           WishlistController@update

GET    /api/bills                    BillController@index
POST   /api/bills                    BillController@store
PUT    /api/bills/{id}/pay           BillController@markAsPaid
PUT    /api/bills/{id}/unpay         BillController@markAsUnpaid
```

---

## 6. DATABASE SCHEMA (Key Tables)

### `wallets`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint PK | |
| user_id | FK → users | |
| name_wallet | string | Nama wallet (misal: "BCA", "ShopeePay") |
| balance | decimal | Saldo saat ini |
| category | string | "Cash" / "Bank Account" / "E-Wallet" |
| theme_index | int | Index ke `WalletTheme.all[]` untuk warna card |
| created_at / updated_at | timestamp | |

### `transactions`
| Kolom | Tipe | Keterangan |
|---|---|---|
| id | bigint PK | |
| user_id | FK → users | |
| wallet_id | FK → wallets | Wallet asal |
| to_wallet_id | FK → wallets (nullable) | Wallet tujuan (hanya transfer) |
| wishlist_id | FK → wishlists (nullable) | Relasi ke target tabungan |
| title | string | Judul (hanya jika category == "More") |
| amount | decimal | Nominal |
| type | enum | `income` / `expense` / `transfer` |
| category | string | Kategori (Salary, Food, Transfer, dll) |
| note | string (nullable) | Catatan opsional |
| transaction_date | date | Tanggal transaksi (YYYY-MM-DD) |
| created_at | timestamp | ← dipakai frontend untuk tampil **jam** transaksi |

---

## 7. DATA FLOW — AUTH

```
User buka app
  └── main.dart: cek SharedPreferences['token']
        ├── Ada token → AuthProvider.restoreSession()
        │     └── langsung ke HomePage + loadAll() + loadWalletsFromApi()
        └── Tidak ada → LoginPage

LoginPage → AuthService.login() → POST /api/login
  └── Response: { token, user }
        └── Simpan token ke SharedPreferences
        └── Navigate ke HomePage
```

---

## 8. DATA FLOW — TAMBAH TRANSAKSI (AddPage)

```
User buka AddPage (floating action button)
  └── Tab Income / Expense / Transfer

[Income / Expense]
  1. Pilih kategori (FilterIncome / FilterExpense bubble)
     - "More" → aktifkan Add Title input field
  2. Input nominal (NumPad)
  3. Pilih From Wallet (WalletSelectorPopup)
  4. Tekan confirm (✅ di numpad)

[Transfer]
  1. Pilih To Wallet (FilterTransfer bubble)
     - To Wallet otomatis exclude From Wallet
  2. Input nominal (NumPad)
  3. Pilih From Wallet (WalletSelectorPopup)
     - From Wallet exclude To Wallet yang sudah dipilih
  4. Tekan confirm

[Confirm Flow]
  AddPageHelper.validate() → error jika amount=0 / wallet null / toWallet null (transfer)
  AddPageHelper.resolveCategory() → 'Transfer' / kategori pilihan
  AddPageHelper.resolveTitle() → title hanya jika category=='More'

  TransactionProvider.addTransactionWithApi(transaction, token, walletId, toWalletId?)
    └── TransactionService.addTransaction() → POST /api/transactions
          Request body:
          {
            wallet_id: int,
            to_wallet_id: int (optional, transfer only),
            title: string,
            amount: double,
            type: 'income'|'expense'|'transfer',
            category: string,
            transaction_date: 'YYYY-MM-DD'
          }
    └── loadAll(token) → refresh transaksi & summary
    └── WalletProvider.loadWalletsFromApi(token) → refresh saldo wallet
    └── TransactionProvider.enrichToWalletNames(wallets) → isi toWalletName
```

---

## 9. DATA FLOW — TRANSFER (Logic Backend)

```
POST /api/transactions { type: 'transfer', wallet_id: 7, to_wallet_id: 8, amount: 500000 }

Backend TransactionController.store():
  1. Validasi wallet_id + to_wallet_id milik user
  2. Cek saldo wallet_id >= amount
  3. DB::transaction {
       wallet_id.balance  -= amount   (BCA berkurang)
       to_wallet_id.balance += amount (BSI bertambah)
       Transaction::create(...)
     }
  4. Return 201

Frontend setelah berhasil:
  - loadAll() → refresh transaksi list
  - loadWalletsFromApi() → saldo BCA & BSI langsung update di UI
  - enrichToWalletNames() → isi nama BSI di card history
```

---

## 10. DATA FLOW — DELETE TRANSAKSI

```
TransactionDetailSheet → delete icon → ConfirmDialog
  └── onConfirm → TransactionProvider.deleteTransactionWithApi(id, token)
        └── DELETE /api/transactions/{id}

Backend destroy():
  - Reverse balance wallet (income → decrement, expense → increment)
  - Jika transfer: juga reverse to_wallet balance
  - transaction.delete()
```

---

## 11. WALLET PROVIDER — FLOW

```
WalletProvider._wallets = List<WalletModel>

loadWalletsFromApi(token):
  GET /api/wallets → List<WalletModel>
  WalletModel.fromJson():
    - name_wallet → name
    - category: 'Cash'|'Bank Account'|'E-Wallet' → WalletCategory enum
    - theme_index → WalletTheme.all[index] → card gradient

Kategorisasi di UI:
  cashWallets      = wallets where category == WalletCategory.cash
  bankWallets      = wallets where category == WalletCategory.bankAccount
  eWalletWallets   = wallets where category == WalletCategory.eWallet

Total Balance = sum(semua wallet.balance)
```

---

## 12. KNOWN ISSUES / LIMITATIONS

| Issue | Detail |
|---|---|
| **No DELETE /wallets** | Backend tidak punya endpoint hapus wallet → delete hanya lokal |
| **destinationWallet tidak eager-loaded** | `GET /transactions` hanya load `wallet`, bukan `destinationWallet` → toWalletName diisi via `enrichToWalletNames()` di frontend |
| **WalletController default 'general'** | `store()` pakai `$request->category ?? 'general'` padahal frontend kirim 'Cash'/'Bank Account'/'E-Wallet' |
| **transaction_date date-only** | Tidak menyimpan waktu → jam diambil dari `created_at` |
| **Edit transaksi lokal** | Update transaction UI masih pakai local update, bukan API update (perlu cek) |

---

## 13. STATE MANAGEMENT (Provider Pattern)

```
MultiProvider (main.dart):
  ├── AuthProvider        → token, user info, isLoggedIn
  ├── TransactionProvider → transactions[], summary, isLoading, CRUD
  ├── WalletProvider      → wallets[], isHidden, CRUD
  └── SavingProvider      → savings[] (wishlist targets)

Alur inisialisasi (main.dart / home_page.dart):
  1. AuthProvider.restoreSession()
  2. TransactionProvider.loadAll(token)        // parallel
  3. WalletProvider.loadWalletsFromApi(token)  // parallel
  4. TransactionProvider.enrichToWalletNames(wallets) // setelah keduanya selesai
```

---

## 14. WARNA & TEMA

### AppColors (lib/core/theme/app_colors.dart)
| Nama | HEX | Dipakai untuk |
|---|---|---|
| primaryPurple | #694EDA | Brand utama |
| incomeGreen | #4CAF50 | Teks income |
| expenseRed | #E53935 | Teks expense |
| transferOrange | #F97316 | Teks transfer |
| incomeGradient | #11C46E → #00E59B | Icon bubble income |
| expenseGradient | #FF2452 → #FF6B35 | Icon bubble expense |
| transferGradient | #FBBF24 → #F97316 | Icon bubble transfer |

### WalletTheme (dalam app_colors.dart)
Setiap wallet punya `WalletTheme` yang menentukan warna card ATM. Diambil dari `theme_index` (integer disimpan di DB).  
Contoh: `midnight` (navy-biru) = BCA, `volcano` (merah-oranye) = ShopeePay.

---

## 15. FITUR OCR SCAN

```
ScanPage (bottom sheet 75% height, light theme):
  - Kamera / Gallery → ambil foto struk
  - scan_service.dart → POST /api/ai/scan-receipt (multipart)
  - AiScanController.php → Gemini AI → ekstrak nominal
  - Hasil pre-fill ke AddPage sebagai amount
```

---

## 16. SAVING / WISHLIST FLOW

```
SavingPage → list target tabungan

SavingProvider.loadSavings(token):
  GET /api/wishlists → List<SavingModel>

Buat target baru: CreateSavingModal → POST /api/wishlists
Progress dihitung lokal: currentAmount / targetAmount * 100%

Saat tambah transaksi expense dengan wishlist_id:
  POST /api/transactions { ..., wishlist_id: X }
  Backend akan update wishlist.current_amount (perlu dikonfirmasi)
```

---

## 17. BILLS FLOW

```
BillsPage → list tagihan bulanan

GET /api/bills → List<BillModel>
POST /api/bills → Buat tagihan baru
PUT /api/bills/{id}/pay → Tandai lunas
PUT /api/bills/{id}/unpay → Tandai belum lunas

Status: isPaid (bool) → tampil badge "Lunas" / "Belum Lunas"
```

---

## 18. CATATAN PENTING UNTUK AGENT

1. **Jangan ubah backend** kecuali diminta eksplisit oleh user
2. **`TransactionType`** enum: `income`, `expense`, `transfer`
3. **`WalletCategory`** enum: `cash`, `bankAccount`, `eWallet`
4. **`WalletOption`** (di `wallet_selector_popup.dart`) berbeda dari `WalletModel` — dipakai khusus di UI AddPage popup
5. **`enrichToWalletNames()`** harus dipanggil setiap kali `loadAll()` + `loadWalletsFromApi()` selesai
6. **`excludeWallet`** di `WalletSelectorPopup` dan `FilterTransfer` memastikan user tidak bisa transfer ke wallet yang sama
7. **`titleEnabled`** di `InputRow` aktif HANYA saat `_selectedCategory == 'More'` (bukan Transfer)
8. **Gradient colors** sudah tersedia: `incomeGradient`, `expenseGradient`, `transferGradient` di `AppColors`
9. **Token** disimpan di `SharedPreferences['token']` — cek `auth_provider.dart`
10. **`ConfirmDialog`** adalah komponen universal untuk semua dialog konfirmasi (hapus, logout, dll)
