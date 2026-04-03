import 'package:flutter/material.dart';

class SplashScreen7 extends StatelessWidget {
  const SplashScreen7({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFF1F1F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Stack(
            children: [
              const Positioned(
                left: 110,
                top: 398,
                child: Text(
                  'Monefy.',
                  style: TextStyle(
                    color: Color(0xFF694EDA),
                    fontSize: 42.58,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Positioned(
                left: 328,
                top: 426,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8F79ED), Color(0xFF694EDA)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Positioned(
                left: 98,
                top: 247,
                child: SizedBox(
                  width: 195,
                  height: 195,
                  child: Image(
                    image: NetworkImage("https://picsum.photos/195/195"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}