import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const LoginForm({
    required this.usernameController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        /// BACKGROUND KONTUR
        Positioned.fill(
          child: Opacity(
            opacity: 0.9, // coba 0.3 kalau kurang kelihatan
            child: SvgPicture.asset(
              'assets/images/kontur.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// ISI FORM
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF694EDA),
                ),
              ),

              SizedBox(height: 20),

              Text("Username",
                  style: TextStyle(color: Color(0xFF694EDA))),
              SizedBox(height: 5),

              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF6F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 20),

              Text("Password",
                  style: TextStyle(color: Color(0xFF694EDA))),
              SizedBox(height: 5),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xFFF1F1F1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF694EDA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: onLogin,
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              SizedBox(height: 15),

              Center(
                child: Text(
                  "Dont have an account? Sign Up",
                  style: TextStyle(color: Color(0xFF694EDA)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}