import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:monefy/providers/bill_provider.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_colors.dart';
import 'data/services/cache_service.dart';
import 'data/services/notification_service.dart';
import 'providers/analytic_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/saving_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wallet_provider.dart';
import 'core/theme/app_theme.dart';
import 'ui/pages/auth_page.dart';
import 'ui/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  Intl.defaultLocale = 'id_ID';
  await NotificationService.init();
  await CacheService.init(); // Inisialisasi Hive cache
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
        ChangeNotifierProvider(create: (_) => AnalyticProvider()),
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
      final token = auth.token!;
      final txProvider = context.read<TransactionProvider>();
      final walletProvider = context.read<WalletProvider>();

      final hasCachedTx = CacheService.hasTransactions();
      final hasCachedWallet = CacheService.hasWallets();

      if (hasCachedTx && hasCachedWallet) {
        // ── Cache-first: tampil UI instan dari cache ──────────────────
        // Load dari cache (sinkron, tidak butuh network)
        txProvider.loadFromCache();
        walletProvider.loadFromCache();
        txProvider.enrichToWalletNames(walletProvider.wallets);

        // Tampilkan MainPage segera — user tidak perlu tunggu network
        if (mounted) setState(() => _checking = false);

        // Background sync: update dengan data terbaru dari server
        // UI sudah tampil, user tidak merasakan ini
        Future.wait([
          txProvider.loadAll(token),
          walletProvider.loadWalletsFromApi(token),
        ]).then((_) => txProvider.enrichToWalletNames(walletProvider.wallets));
        return;
      }

      // ── Cache kosong (install baru / habis logout): tetap await ─────
      await Future.wait([
        txProvider.loadAll(token),
        walletProvider.loadWalletsFromApi(token),
      ]);
      txProvider.enrichToWalletNames(walletProvider.wallets);
    }

    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const _MonefySplashLoading();
    }

    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const MainPage() : const AuthPage();
  }
}

class _MonefySplashLoading extends StatefulWidget {
  const _MonefySplashLoading();

  @override
  State<_MonefySplashLoading> createState() => _MonefySplashLoadingState();
}

class _MonefySplashLoadingState extends State<_MonefySplashLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dashboardPurple,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final wave = math.sin(_controller.value * math.pi * 2);
            final logoOffset = wave * 8;
            final logoScale = 1 + (wave * 0.03);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: Transform.translate(
                    offset: Offset(0, logoOffset),
                    child: Transform.scale(
                      scale: logoScale,
                      child: SvgPicture.asset(
                        'assets/images/moneyfy.svg',
                        width: 112,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (bounds) {
                    final slide = _controller.value * 2 - 1;
                    return LinearGradient(
                      begin: Alignment(-1 + slide, 0),
                      end: Alignment(1 + slide, 0),
                      colors: const [
                        AppColors.primaryPurple,
                        AppColors.decorativePurple,
                        AppColors.primaryPurple,
                      ],
                      stops: const [0.18, 0.5, 0.82],
                    ).createShader(bounds);
                  },
                  child: const Text(
                    'Monefy.',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 30,
                      color: AppColors.panelWhite,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Preparing your dashboard',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryPurple.withValues(alpha: 0.7),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
