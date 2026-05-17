import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/transaction_ui_helpers.dart';
import '../../data/models/transaction_model.dart';

/// Widget animasi sukses transaksi — berjalan sekali (non-looping).
///
/// Urutan animasi (total 1200ms):
///  1. Ring expand ripple (0–400ms)
///  2. Lingkaran utama scale bounce (100–600ms)
///  3. Confetti jatuh (400–1200ms)
///  4. Bintang pop (600–1100ms)
///  5. Centang draw (550–900ms)
///  6. Teks judul slide up (900–1200ms)
///  7. Nominal uang slide up (1000–1200ms)
///  8. Teks keterangan slide up (1100–1200ms)
///
/// Setelah animasi selesai, [onComplete] dipanggil.
class TransactionSuccessWidget extends StatefulWidget {
  final String amount;
  final String title;
  final String subtitle;
  final TransactionType transactionType;
  final VoidCallback? onComplete;
  final double size;

  const TransactionSuccessWidget({
    super.key,
    required this.amount,
    this.title = 'Transaksi Berhasil!',
    this.subtitle = 'Dana telah dikirim ke tujuan',
    this.transactionType = TransactionType.income,
    this.onComplete,
    this.size = 200,
  });

  @override
  State<TransactionSuccessWidget> createState() =>
      _TransactionSuccessWidgetState();
}

class _TransactionSuccessWidgetState extends State<TransactionSuccessWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // ── Ring ripple ──
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _ring2Scale;
  late final Animation<double> _ring2Opacity;

  // ── Lingkaran utama ──
  late final Animation<double> _circleScale;

  // ── Centang draw ──
  late final Animation<double> _checkProgress;

  // ── Bintang pop ──
  late final Animation<double> _starScale;
  late final Animation<double> _starOpacity;

  // ── Teks ──
  late final Animation<double> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _amountSlide;
  late final Animation<double> _amountOpacity;
  late final Animation<double> _subtitleSlide;
  late final Animation<double> _subtitleOpacity;

  // ── Confetti data (6 partikel) ──
  late final List<_ConfettiData> _confettiList;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // ── Ring 1 expand (0.0 → 0.33) ──
    _ringScale = Tween<double>(begin: 0.4, end: 1.2).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );
    _ringOpacity = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );

    // ── Ring 2 expand, sedikit delay (0.05 → 0.40) ──
    _ring2Scale = Tween<double>(begin: 0.3, end: 1.4).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
      ),
    );
    _ring2Opacity = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.40, curve: Curves.easeOut),
      ),
    );

    // ── Lingkaran utama bounce (0.08 → 0.50) ──
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.08, 0.50, curve: Curves.elasticOut),
      ),
    );

    // ── Centang draw (0.46 → 0.75) ──
    _checkProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.46, 0.75, curve: Curves.easeOut),
      ),
    );

    // ── Bintang pop (0.50 → 0.92) ──
    _starScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.50, 0.92, curve: Curves.easeOut),
      ),
    );
    _starOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.50, 0.92, curve: Curves.easeOut),
      ),
    );

    // ── Teks judul (0.75 → 1.0) ──
    _titleSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Nominal (0.83 → 1.0) ──
    _amountSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.83, 1.0, curve: Curves.easeOut),
      ),
    );
    _amountOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.83, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Keterangan (0.92 → 1.0) ──
    _subtitleSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.92, 1.0, curve: Curves.easeOut),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.92, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── Inisialisasi confetti (6 partikel, acak posisi & warna) ──
    final random = math.Random(42); // seed tetap agar konsisten
    final confettiColors = [
      AppColors.confettiYellow,
      AppColors.incomeRingColor,
      AppColors.confettiRed,
      AppColors.confettiBlue,
      AppColors.confettiYellow,
      AppColors.confettiRed,
    ];
    _confettiList = List.generate(6, (i) {
      final angle = (i * 60.0 + random.nextDouble() * 30 - 15) * math.pi / 180;
      final dist = 55.0 + random.nextDouble() * 20;
      return _ConfettiData(
        color: confettiColors[i % confettiColors.length],
        dx: math.cos(angle) * dist,
        dy: math.sin(angle) * dist + 20,
        rotation: (random.nextDouble() - 0.5) * math.pi * 2,
        size: 7.0 + random.nextDouble() * 5,
      );
    });

    // ── Mulai animasi + panggil onComplete ──
    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final circleR = s * 0.48;
    final gradient = getTransactionGradient(widget.transactionType);
    final ringColor = getTransactionRingColor(widget.transactionType);
    final amountColor = getTransactionAmountColor(widget.transactionType);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Zona animasi lingkaran + partikel ──
            SizedBox(
              width: s,
              height: s,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring ripple 2 (luar)
                  Opacity(
                    opacity: _ring2Opacity.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _ring2Scale.value,
                      child: Container(
                        width: circleR * 2,
                        height: circleR * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: ringColor, width: 2),
                        ),
                      ),
                    ),
                  ),

                  // Ring ripple 1 (dalam)
                  Opacity(
                    opacity: _ringOpacity.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _ringScale.value,
                      child: Container(
                        width: circleR * 1.6,
                        height: circleR * 1.6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ringColor.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),

                  // Confetti partikel (6 kotak kecil)
                  ..._confettiList.map((c) {
                    final progress = _ctrl.value;
                    // Confetti mulai interval 0.33 → 1.0
                    final t = ((progress - 0.33) / 0.67).clamp(0.0, 1.0);
                    final opacity = (1.0 - math.pow(t, 1.5)).clamp(0.0, 1.0).toDouble();
                    final dy = c.dy * Curves.easeIn.transform(t);
                    final dx = c.dx * t;
                    return Opacity(
                      opacity: t > 0 ? opacity : 0.0,
                      child: Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          angle: c.rotation * t,
                          child: Container(
                            width: c.size,
                            height: c.size,
                            decoration: BoxDecoration(
                              color: c.color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Bintang ✦ (3 bintang mengelilingi lingkaran)
                  ...[
                    Offset(-circleR * 0.85, -circleR * 0.5),
                    Offset(circleR * 0.85, -circleR * 0.5),
                    Offset(0, -circleR * 1.05),
                  ].map((pos) => Transform.translate(
                        offset: pos,
                        child: Opacity(
                          opacity: _starOpacity.value.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: _starScale.value,
                            child: Text(
                              '✦',
                              style: TextStyle(
                                fontSize: s * 0.08,
                                color: AppColors.coinGold,
                              ),
                            ),
                          ),
                        ),
                      )),

                  // Lingkaran utama (gradient + centang)
                  Transform.scale(
                    scale: _circleScale.value,
                    child: RepaintBoundary(
                      child: CustomPaint(
                        size: Size(circleR * 2, circleR * 2),
                        painter: _SuccessCirclePainter(
                          gradient: gradient,
                          checkProgress: _checkProgress.value,
                          radius: circleR,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Teks judul ──
            Opacity(
              opacity: _titleOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _titleSlide.value),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Nominal uang ──
            Opacity(
              opacity: _amountOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _amountSlide.value),
                child: Text(
                  widget.amount,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Teks keterangan ──
            Opacity(
              opacity: _subtitleOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _subtitleSlide.value),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ──────────────────────────────────────────
// Data model confetti partikel
// ──────────────────────────────────────────
class _ConfettiData {
  final Color color;
  final double dx;
  final double dy;
  final double rotation;
  final double size;

  const _ConfettiData({
    required this.color,
    required this.dx,
    required this.dy,
    required this.rotation,
    required this.size,
  });
}

// ──────────────────────────────────────────
// CustomPainter: Lingkaran gradient + centang
// ──────────────────────────────────────────
class _SuccessCirclePainter extends CustomPainter {
  final LinearGradient gradient;
  final double checkProgress;
  final double radius;

  const _SuccessCirclePainter({
    required this.gradient,
    required this.checkProgress,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── Lingkaran gradient ──
    final circlePaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    // ── Bayangan halus ──
    final shadowPaint = Paint()
      ..color = gradient.colors.first.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center + const Offset(0, 6), radius * 0.85, shadowPaint);
    // Gambar ulang lingkaran di atas shadow
    canvas.drawCircle(center, radius, circlePaint);

    // ── Centang putih (path draw) ──
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // Titik centang: kiri-bawah → tengah-bawah → kanan-atas
      final p1 = Offset(center.dx - radius * 0.32, center.dy + radius * 0.02);
      final p2 = Offset(center.dx - radius * 0.05, center.dy + radius * 0.28);
      final p3 = Offset(center.dx + radius * 0.38, center.dy - radius * 0.22);

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy);

      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        final extractPath = metric.extractPath(
          0,
          metric.length * checkProgress,
        );
        canvas.drawPath(extractPath, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SuccessCirclePainter old) =>
      old.checkProgress != checkProgress || old.gradient != gradient;
}
