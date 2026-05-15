import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'glass_circle_button.dart';

/// Widget yang mengelompokkan 3 tombol di bagian atas AddPage:
/// - Back button (kiri)
/// - Mic button (kanan atas)
/// - Camera/Scan button (kanan bawah)
///
/// Semua tombol menggunakan GlassCircleButton.
class TopActionButtons extends StatelessWidget {
  final double sx;
  final double sy;
  final VoidCallback onBack;
  final VoidCallback? onMic;
  final VoidCallback onCamera;

  const TopActionButtons({
    super.key,
    required this.sx,
    required this.sy,
    required this.onBack,
    this.onMic,
    required this.onCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // BACK BUTTON
        Positioned(
          left: 16 * sx,
          top: 23 * sy,
          child: GlassCircleButton(
            size: 42,
            sx: sx,
            sy: sy,
            onTap: onBack,
            child: SvgPicture.asset(
              'assets/icon/back.svg',
              width: 22 * sx,
              height: 22 * sy,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),

        // MIC BUTTON
        Positioned(
          right: 16 * sx,
          top: 90 * sy,
          child: GlassCircleButton(
            size: 44,
            sx: sx,
            sy: sy,
            onTap: onMic,
            child: Icon(Icons.mic_rounded, color: Colors.white, size: 22 * sx),
          ),
        ),

        // CAMERA / SCAN BUTTON
        Positioned(
          right: 16 * sx,
          top: 142 * sy,
          child: GlassCircleButton(
            size: 44,
            sx: sx,
            sy: sy,
            onTap: onCamera,
            child: Icon(Icons.camera_alt_rounded,
                color: Colors.white, size: 22 * sx),
          ),
        ),
      ],
    );
  }
}
