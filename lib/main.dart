import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:monefy/providers/bill_provider.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/pages/login_page.dart';
import 'ui/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  runApp(const MonefyApp());
}

class MonefyApp extends StatelessWidget {
  const MonefyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => SavingProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Monefy',
        theme: AppTheme.lightTheme,
        home: const _RootPage(),
      ),
    );
  }
}

/// Root page: cek auto-login.
/// Jika token tersimpan → langsung ke MainPage.
/// Jika tidak → ke LoginPage.
class _RootPage extends StatefulWidget {
  const _RootPage();

  @override
  State<_RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<_RootPage> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final auth = context.read<AuthProvider>();
    await auth.tryAutoLogin();

    if (auth.isLoggedIn) {
      // Token ditemukan → load data lalu ke MainPage
      final token = auth.token!;
      final txProvider = context.read<TransactionProvider>();
      final walletProvider = context.read<WalletProvider>();

      await txProvider.loadAll(token);
      // Setelah transaksi loaded, build wallet list dari relasi transaksi
      walletProvider.loadWalletsFromTransactions(txProvider.transactions);
    }

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        backgroundColor: Color(0xFFEDE9FE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainPage() : LoginPage();
  }
}