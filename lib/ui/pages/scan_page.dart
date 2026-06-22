import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../data/services/scan_service.dart';

// ══════════════════════════════════════════════════════════════════════════════
/// ScanPage — bottom-sheet receipt scanner (75 % tinggi, light theme).
///
/// Flow:
///   live    → live camera preview di viewfinder
///   preview → tampil preview foto + Retake / Confirm
///   loading → kirim ke backend AI → tunggu total
///
/// Return via: Navigator.pop(context, double total)
// ══════════════════════════════════════════════════════════════════════════════
enum _ScanState { live, preview, loading }

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  _ScanState _state = _ScanState.live;
  File? _imageFile;

  // ── Camera ──
  CameraController? _camCtrl;
  bool _isCameraReady = false;
  bool _isFlashOn = false;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Ambil kamera belakang
      final backCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _camCtrl = CameraController(
        backCam,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _camCtrl!.initialize();

      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _camCtrl?.dispose();
    super.dispose();
  }

  // ── Take photo ─────────────────────────────────────────────────────────────
  Future<void> _takePhoto() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    if (_camCtrl!.value.isTakingPicture) return;

    try {
      final XFile file = await _camCtrl!.takePicture();
      if (mounted) {
        setState(() {
          _imageFile = File(file.path);
          _state = _ScanState.preview;
        });
      }
    } catch (e) {
      debugPrint('Take photo error: $e');
    }
  }

  // ── Toggle flash ───────────────────────────────────────────────────────────
  Future<void> _toggleFlash() async {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    try {
      _isFlashOn = !_isFlashOn;
      await _camCtrl!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  // ── Pick from gallery ──────────────────────────────────────────────────────
  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked != null && mounted) {
      setState(() {
        _imageFile = File(picked.path);
        _state = _ScanState.preview;
      });
    }
  }

  void _retake() {
    setState(() {
      _imageFile = null;
      _state = _ScanState.live;
    });
  }

  Future<void> _confirm() async {
    if (_imageFile == null) return;
    setState(() => _state = _ScanState.loading);

    final result = await ScanService.scanReceipt(_imageFile!);

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pop(result);
    } else {
      setState(() => _state = _ScanState.preview);
      _showError('Could not read the receipt. Try better lighting or a clearer photo.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.75,
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.scanBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildHeader(),
            Expanded(child: _buildScanArea()),
            _buildBottomControls(),
            if (_state == _ScanState.preview || _state == _ScanState.loading)
              _buildActionButtons(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  // ── Drag Handle ────────────────────────────────────────────────────────────
  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.disabled,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // ── Header — Search bar style ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          // "Scan" title
          const Text(
            'Scan',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryPurple,
              letterSpacing: 0.2,
            ),
          ),

          const Spacer(),

          // Mic button
          GestureDetector(
            onTap: () {
              // TODO: implementasi voice input
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mic_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Camera icon kecil — shortcut take photo
          GestureDetector(
            onTap: _takePhoto,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Scan area (viewfinder frame) ───────────────────────────────────────────
  Widget _buildScanArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Center(
        child: AspectRatio(
          aspectRatio: 3 / 3.8,
          child: AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              return CustomPaint(
                painter: _ReceiptFramePainter(
                  glowIntensity: _state == _ScanState.live
                      ? _glowAnim.value
                      : 1.0,
                  isConfirmed: _state == _ScanState.loading,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: child,
                ),
              );
            },
            child: _buildFrameContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildFrameContent() {
    switch (_state) {
      case _ScanState.live:
        return _buildLiveCameraContent();
      case _ScanState.preview:
        return _buildPreviewContent();
      case _ScanState.loading:
        return _buildLoadingContent();
    }
  }

  // Live camera preview
  Widget _buildLiveCameraContent() {
    if (!_isCameraReady || _camCtrl == null) {
      // Fallback saat kamera belum siap
      return Container(
        color: AppColors.scanViewfinderBg,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.scanMintGreen,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Container(
      color: AppColors.scanViewfinderBg,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: _camCtrl!.value.previewSize?.height ?? 1,
            height: _camCtrl!.value.previewSize?.width ?? 1,
            child: CameraPreview(_camCtrl!),
          ),
        ),
      ),
    );
  }

  // Preview: tampilkan foto yang sudah diambil
  Widget _buildPreviewContent() {
    return Image.file(
      _imageFile!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  // Loading: foto + overlay spinner
  Widget _buildLoadingContent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(_imageFile!, fit: BoxFit.cover),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.75),
              ],
            ),
          ),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.scanMintGreen,
                    strokeWidth: 2.5,
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scanMintGreen.withValues(alpha: 0.15),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.scanMintGreen,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Analyzing receipt...',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'AI is reading your transaction',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Bottom Controls: Flash | Camera | Gallery ──────────────────────────────
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flash (fungsional)
          _LightIconBtn(
            icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            isActive: _isFlashOn,
            onTap: _toggleFlash,
          ),

          const SizedBox(width: 32),

          // Camera — tombol utama (hijau besar)
          GestureDetector(
            onTap: _state == _ScanState.live ? _takePhoto : null,
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.scanMintGreen.withValues(alpha: 0.35),
              ),
              child: Center(
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.scanMintGreen,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 32),

          // Gallery
          _LightIconBtn(
            icon: Icons.photo_library_rounded,
            onTap: _pickFromGallery,
          ),
        ],
      ),
    );
  }

  // ── Action Buttons: Retake + Confirm ───────────────────────────────────────
  Widget _buildActionButtons() {
    final bool isLoading = _state == _ScanState.loading;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: [
          // Retake
          Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : _retake,
              child: AnimatedOpacity(
                opacity: isLoading ? 0.5 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.scanRetakeBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Retake',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.scanRetakeText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Confirm
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isLoading ? null : _confirm,
              child: AnimatedOpacity(
                opacity: isLoading ? 0.7 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Confirm',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Helper Widgets
// ══════════════════════════════════════════════════════════════════════════════

/// Light-themed icon button untuk bottom controls (Flash / Gallery).
class _LightIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _LightIconBtn({
    required this.icon,
    required this.onTap,
    this.isActive = false,
  });

  @override
  State<_LightIconBtn> createState() => _LightIconBtnState();
}

class _LightIconBtnState extends State<_LightIconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primaryPurple.withValues(alpha: 0.15)
                : AppColors.scanIconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: widget.isActive
                ? AppColors.primaryPurple
                : AppColors.primaryPurple.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ── Receipt frame corner painter ──────────────────────────────────────────────
class _ReceiptFramePainter extends CustomPainter {
  final double glowIntensity;
  final bool isConfirmed;

  const _ReceiptFramePainter({
    required this.glowIntensity,
    required this.isConfirmed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final color = isConfirmed
        ? AppColors.primaryPurple
        : Color.lerp(
            AppColors.scanMintGreen.withValues(alpha: 0.5),
            AppColors.scanMintGreen,
            glowIntensity,
          )!;

    const cornerLen = 30.0;
    const r = 14.0;
    final w = size.width;
    final h = size.height;

    // Glow layer
    final glowPaint = Paint()
      ..color = color.withValues(alpha: glowIntensity * 0.35)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    _drawCorners(canvas, glowPaint, w, h, cornerLen, r);

    // Sharp corners
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    _drawCorners(canvas, linePaint, w, h, cornerLen, r);
  }

  void _drawCorners(
    Canvas canvas, Paint paint, double w, double h, double len, double r) {
    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(r, len + r)
        ..lineTo(r, r)
        ..lineTo(len + r, r),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - r - len, r)
        ..lineTo(w - r, r)
        ..lineTo(w - r, r + len),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r, h - r - len)
        ..lineTo(r, h - r)
        ..lineTo(r + len, h - r),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w - r - len, h - r)
        ..lineTo(w - r, h - r)
        ..lineTo(w - r, h - r - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ReceiptFramePainter old) =>
      old.glowIntensity != glowIntensity || old.isConfirmed != isConfirmed;
}
