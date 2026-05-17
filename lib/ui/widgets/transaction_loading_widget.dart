import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/transaction_ui_helpers.dart';
import '../../data/models/transaction_model.dart';

/// Widget animasi loading transaksi — loop tanpa henti.
/// Ilustrasi flat: uang/bills + koin melayang + panah bergerak + dots.
class TransactionLoadingWidget extends StatefulWidget {
  final TransactionType transactionType;
  final double size;
  final String label;
  final String subtitle;

  const TransactionLoadingWidget({
    super.key,
    this.transactionType = TransactionType.income,
    this.size = 210,
    this.label = 'Memproses transaksi...',
    this.subtitle = '',
  });

  @override
  State<TransactionLoadingWidget> createState() =>
      _TransactionLoadingWidgetState();
}

class _TransactionLoadingWidgetState extends State<TransactionLoadingWidget>
    with TickerProviderStateMixin {
  // Controllers
  late final AnimationController _bobCtrl;    // bill bob naik-turun
  late final AnimationController _coinCtrl;   // koin melayang
  late final AnimationController _arrowCtrl;  // panah gerak kanan
  late final AnimationController _dotCtrl;    // dots berkedip

  // Bill bob
  late final Animation<double> _bobOffset;

  // Koin
  late final Animation<double> _coin1Y;
  late final Animation<double> _coin1Opacity;
  late final Animation<double> _coin2Y;
  late final Animation<double> _coin2Opacity;

  // Panah
  late final Animation<double> _arrowOffset;

  // Dots
  late final Animation<double> _dot1;
  late final Animation<double> _dot2;
  late final Animation<double> _dot3;

  // ── Resolusi warna dari transactionType (via transaction_ui_helpers.dart) ──
  LinearGradient get _gradient     => getTransactionGradient(widget.transactionType);
  Color          get _primaryColor => getTransactionRingColor(widget.transactionType);
  Color          get _darkColor    => getTransactionDarkColor(widget.transactionType);

  @override
  void initState() {
    super.initState();

    // Bill bob (2000ms, repeat reverse)
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _bobOffset = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut),
    );

    // Koin melayang (1800ms, repeat)
    _coinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _coin1Y = Tween<double>(begin: 0, end: -48).animate(
      CurvedAnimation(
        parent: _coinCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeIn),
      ),
    );
    _coin1Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 35),
    ]).animate(_coinCtrl);

    _coin2Y = Tween<double>(begin: 0, end: -48).animate(
      CurvedAnimation(
        parent: _coinCtrl,
        curve: const Interval(0.22, 0.88, curve: Curves.easeIn),
      ),
    );
    _coin2Opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 22),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 8),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 15),
    ]).animate(_coinCtrl);

    // Panah bergerak kanan (1200ms, repeat reverse)
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _arrowOffset = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );

    // Dots (1200ms)
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _dot1 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 60),
    ]).animate(_dotCtrl);
    _dot2 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 40),
    ]).animate(_dotCtrl);
    _dot3 = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 20),
    ]).animate(_dotCtrl);
  }

  @override
  void dispose() {
    _bobCtrl.dispose();
    _coinCtrl.dispose();
    _arrowCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final primaryColor = _primaryColor;
    final darkColor = _darkColor;
    final gradient = _gradient;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Zona ilustrasi ──
        SizedBox(
          width: s,
          height: s * 0.9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle pale
              Container(
                width: s * 0.62,
                height: s * 0.62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.13),
                ),
              ),

              // Bills illustration + bob animation
              AnimatedBuilder(
                animation: _bobCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(0, _bobOffset.value),
                  child: _BillsIllustration(
                    gradient: gradient,
                    darkColor: darkColor,
                    width: s * 0.58,
                    height: s * 0.36,
                  ),
                ),
              ),

              // Koin 1 (kiri atas)
              AnimatedBuilder(
                animation: _coinCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(-s * 0.2, -s * 0.12 + _coin1Y.value),
                  child: Opacity(
                    opacity: _coin1Opacity.value.clamp(0.0, 1.0),
                    child: _CoinWidget(size: s * 0.17),
                  ),
                ),
              ),

              // Panah → (kanan atas)
              AnimatedBuilder(
                animation: _arrowCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(s * 0.09 + _arrowOffset.value, -s * 0.24),
                  child: ShaderMask(
                    shaderCallback: (b) => gradient.createShader(b),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: s * 0.17,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Koin 2 (kanan atas)
              AnimatedBuilder(
                animation: _coinCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(s * 0.2, -s * 0.09 + _coin2Y.value),
                  child: Opacity(
                    opacity: _coin2Opacity.value.clamp(0.0, 1.0),
                    child: _CoinWidget(size: s * 0.145),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // ── Dots ──
        AnimatedBuilder(
          animation: _dotCtrl,
          builder: (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(opacity: _dot1.value, color: primaryColor),
              const SizedBox(width: 7),
              _Dot(opacity: _dot2.value, color: primaryColor),
              const SizedBox(width: 7),
              _Dot(opacity: _dot3.value, color: primaryColor),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // ── Label ──
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),

        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

// ──────────────────────────────────────────
// Bills flat illustration widget
// ──────────────────────────────────────────
class _BillsIllustration extends StatelessWidget {
  final LinearGradient gradient;
  final Color darkColor;
  final double width;
  final double height;

  const _BillsIllustration({
    required this.gradient,
    required this.darkColor,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer belakang (sedikit offset & rotasi)
          Positioned(
            bottom: 0,
            child: Transform.rotate(
              angle: -0.08,
              child: _SingleBill(
                width: width,
                height: height,
                gradient: gradient,
                darkColor: darkColor,
                showCheckmark: false,
                opacity: 0.65,
              ),
            ),
          ),

          // Layer depan (utama)
          Positioned(
            bottom: 0,
            child: _SingleBill(
              width: width,
              height: height,
              gradient: gradient,
              darkColor: darkColor,
              showCheckmark: true,
              opacity: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleBill extends StatelessWidget {
  final double width;
  final double height;
  final LinearGradient gradient;
  final Color darkColor;
  final bool showCheckmark;
  final double opacity;

  const _SingleBill({
    required this.width,
    required this.height,
    required this.gradient,
    required this.darkColor,
    required this.showCheckmark,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Stripe bawah dekorasi
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Garis dekoratif kiri
            Positioned(
              left: 10,
              top: height * 0.2,
              child: Container(
                width: width * 0.18,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: height * 0.2 + 9,
              child: Container(
                width: width * 0.12,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Centang lingkaran di tengah
            if (showCheckmark)
              Center(
                child: Container(
                  width: height * 0.52,
                  height: height * 0.52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: darkColor,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Koin emas
// ──────────────────────────────────────────
class _CoinWidget extends StatelessWidget {
  final double size;
  const _CoinWidget({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.coinGold, Color(0xFFD4A017)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.coinGold.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '\$',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// Dot berkedip
// ──────────────────────────────────────────
class _Dot extends StatelessWidget {
  final double opacity;
  final Color color;
  const _Dot({required this.opacity, required this.color});

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      );
}

