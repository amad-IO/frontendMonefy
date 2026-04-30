import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/login_form.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogin() {
    String username = usernameController.text;
    String password = passwordController.text;

    print("Login: $username - $password");

    /// 🔥 PINDAH KE DASHBOARD
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD5CEF5),
      body: SafeArea(
        child: Column(
          children: [

            /// 🔵 HEADER
            SizedBox(height: 40),

            SvgPicture.asset(
              'assets/images/moneyfy.svg',
              width: 120,
            ),

            SizedBox(height: 10),

            Text(
              "Monefy.",
              style: TextStyle(
                fontSize: 28,
                color: Color(0xFF694EDA),
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 30),

            /// ⚪ CONTAINER FORM
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Stack(
                  children: [

                    ///  PANGGIL FORM
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: LoginForm(
                        usernameController: usernameController,
                        passwordController: passwordController,
                        onLogin: handleLogin,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}