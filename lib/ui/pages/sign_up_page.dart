import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/auth_form.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  /// 🔥 FORM KEY
  final _formKey = GlobalKey<FormState>();

  void handleRegister() {

    /// 🔥 CEK VALIDASI DARI AuthForm
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = usernameController.text.trim();

    print("Register: $username");

    /// 🔥 PINDAH KE LOGIN
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    /// 🔥 NOTIF BERHASIL
    Future.delayed(const Duration(milliseconds: 300), () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up berhasil")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5CEF5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              const SizedBox(height: 40),

              SvgPicture.asset(
                'assets/images/moneyfy.svg',
                width: 120,
              ),

              const SizedBox(height: 10),

              const Text(
                "Monefy.",
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFF694EDA),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              /// 🔥 FORM
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: AuthForm(
                    formKey: _formKey, // 🔥 WAJIB
                    title: "Sign Up",
                    buttonText: "Register",
                    isRegister: true,
                    usernameController: usernameController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,
                    onSubmit: handleRegister,
                    onSwitch: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}