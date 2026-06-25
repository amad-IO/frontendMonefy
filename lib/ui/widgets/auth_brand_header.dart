import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class AuthBrandHeader extends StatefulWidget {
  const AuthBrandHeader({super.key});

  @override
  State<AuthBrandHeader> createState() => _AuthBrandHeaderState();
}

class _AuthBrandHeaderState extends State<AuthBrandHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final wave = math.sin(_controller.value * math.pi * 2);
        final brandOffset = wave * 4;
        final brandScale = 1 + (wave * 0.018);

        return Transform.translate(
          offset: Offset(0, brandOffset),
          child: Transform.scale(
            scale: brandScale,
            child: Column(
              children: [
                SvgPicture.asset(
                  'assets/images/moneyfy.svg',
                  width: 102,
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: ShaderMask(
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
