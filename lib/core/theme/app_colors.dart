import 'package:flutter/material.dart';

class AppColors {
  static const primaryPurple = Color(0xFF694EDA);
  static const primary = primaryPurple; //alias
  static const backgroundWhite = Color(0xFFF1F1F1);
  static const dashboardPurple = Color(0xFFD5CEF5);
  static const white2 = Color(0xFFF6F7FB); 
  static const surface = Color(0xFFF2F2F2);
  static const panelWhite = Color(0xFFFFFFFF);
  static const panelShadow = Color(0x14000000);
  static const background = backgroundWhite; //alias
  static const textPrimary = Color(0xFF1C1C1E); 
  static const textSecondary = Color(0xFF6D6D6D); 
  static const textTertiary = Color(0xFF525252);
  static const success = Color(0xFF2DCC70);
  static const error = Color(0xFFFF2452); 
  static const disabled = Color(0xFFB2B2B2);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF9079ED), 
      Color(0xFF694EDA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Income / Expense
  static const incomeGreen = Color(0xFF4CAF50);
  static const expenseRed = Color(0xFFE53935);
  static const incomeGreenBg = Color(0xFFE8F5E9);
  static const expenseRedBg = Color(0xFFFDE8EC);

  // Sentiment
  static const sentimentGreen = Color(0xFF2E7D32);
  static const sentimentRed = Color(0xFFE53935);

  // Info / Neutral
  static const infoBg = Color(0xFFE3F2FD);
  static const infoText = Color(0xFF1565C0);
  static const neutralBg = Color(0xFFF5F5F5);
  static const neutralText = Color(0xFF757575);

  // Chart
  static const divider = Color(0xFFEEEEEE);
  static const gridLine = Color(0xFFF0F0F0);
  static const chartEmpty = Color(0xFFE0E0E0);

  // UI Elements
  static const cardMuted = Color(0xFFD2D4D6);
  static const menuItemBg = Color(0xFFEEF6FD);
  static const badgeDark = Color(0xFF111111);
  static const decorativePurple = Color(0xFFA68EF0);

  // Numpad
  static const numpadButton = Color(0xFFF7F7FD);
  static const numpadDeleteBg = Color(0xFFF7D9E0);
  static const numpadDeleteIcon = Color(0xFFFF335A);
  static const numpadConfirmBg = Color(0xB9CDEFD5);
  static const numpadConfirmIcon = Color(0xFF2ECC71);
  static const numpadText = Color(0xFF1A1A1A);

  // Shadows
  static const lightShadow = Color(0x0C000000);
  static const subtleShadow = Color(0x0F000000);

  // Decorative
  static const decorativeCircle = Color(0x0CF6F7FB);
}

// ══════════════════════════════════════════════════════════════
/// WalletTheme — pasangan gradasi untuk card wallet.
///
/// [cardGradient]  → gradasi utama latar belakang kartu.
/// [logoGradient]  → gradasi untuk elemen logo / chip di kartu.
///
/// Cara pakai:
/// ```dart
/// final theme = WalletTheme.midnight;
/// BoxDecoration(gradient: theme.cardLinearGradient)
/// ```
// ══════════════════════════════════════════════════════════════
class WalletTheme {
  final List<Color> cardGradient;
  final List<Color> logoGradient;

  const WalletTheme(this.cardGradient, this.logoGradient);

  /// Gradient siap pakai untuk [BoxDecoration].
  LinearGradient get cardLinearGradient => LinearGradient(
        colors: cardGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get logoLinearGradient => LinearGradient(
        colors: logoGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // ── Named themes ──────────────────────────────────────────

  /// Merah-oranye — cocok untuk ShopeePay
  static const volcano = WalletTheme(
    [Color(0xFFFF6B35), Color(0xFFFF2200)],
    [Color(0xFFEB001B), Color(0xFFF79E1B)],
  );

  /// Tosca-biru — cocok untuk GoPay
  static const ocean = WalletTheme(
    [Color(0xFF00C4B4), Color(0xFF0066FF)],
    [Color(0xFF0066FF), Color(0xFF00C4B4)],
  );

  /// Ungu-gelap — cocok untuk OVO
  static const nebula = WalletTheme(
    [Color(0xFF9B59F5), Color(0xFF4C1D95)],
    [Color(0xFF9B59F5), Color(0xFFC084FC)],
  );

  /// Biru langit — cocok untuk DANA
  static const sky = WalletTheme(
    [Color(0xFF38BDF8), Color(0xFF0369A1)],
    [Color(0xFF0369A1), Color(0xFF38BDF8)],
  );

  /// Oranye-merah tua — cocok untuk LinkAja
  static const ember = WalletTheme(
    [Color(0xFFF97316), Color(0xFF9F1239)],
    [Color(0xFF9F1239), Color(0xFFF97316)],
  );

  /// Biru gelap navy — cocok untuk BCA
  static const midnight = WalletTheme(
    [Color(0xFF1E3A5F), Color(0xFF0F172A)],
    [Color(0xFF1D4ED8), Color(0xFF60A5FA)],
  );

  /// Cyan-indigo — cocok untuk BRI
  static const aurora = WalletTheme(
    [Color(0xFF06B6D4), Color(0xFF6366F1)],
    [Color(0xFF6366F1), Color(0xFF06B6D4)],
  );

  /// Kuning-emas — cocok untuk Mandiri
  static const citrus = WalletTheme(
    [Color(0xFFFCD34D), Color(0xFFF59E0B)],
    [Color(0xFFF59E0B), Color(0xFFFCD34D)],
  );

  /// Oranye-merah bata — #EB8431 → #E63E34
  static const sunset = WalletTheme(
    [Color(0xFFEB8431), Color(0xFFE63E34)],
    [Color(0xFFE63E34), Color(0xFFEB8431)],
  );

  /// Abu gelap-hitam — #504E4F → #1A1819
  static const carbon = WalletTheme(
    [Color(0xFF504E4F), Color(0xFF1A1819)],
    [Color(0xFF1A1819), Color(0xFF504E4F)],
  );

  /// Biru baja — #708FA4 → #115199
  static const steel = WalletTheme(
    [Color(0xFF708FA4), Color(0xFF115199)],
    [Color(0xFF115199), Color(0xFF708FA4)],
  );

  /// Biru-hitam gelap — #20212A → #292E3E
  static const cosmos = WalletTheme(
    [Color(0xFF20212A), Color(0xFF292E3E)],
    [Color(0xFF292E3E), Color(0xFF20212A)],
  );

  /// Semua tema dalam urutan daftar (berguna untuk picker).
  static const List<WalletTheme> all = [
    volcano,
    ocean,
    nebula,
    sky,
    ember,
    midnight,
    aurora,
    citrus,
    sunset,
    carbon,
    steel,
    cosmos,
  ];
}