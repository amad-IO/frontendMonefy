import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_form.dart';
import 'login_page.dart';
import '../../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  /// FORM KEY
  final _formKey = GlobalKey<FormState>();

  void handleRegister() async {

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    /// BIAR GAK DOUBLE CLICK
    if (authProvider.isLoading) return;

    /// VALIDASI FORM
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    /// VALIDASI CONFIRM PASSWORD
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }

    try {
      await authProvider.signUp(username, password);

      /// PINDAH KE LOGIN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      /// NOTIF BERHASIL
      Future.delayed(const Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up berhasil")),
        );
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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

              /// FORM
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: AuthForm(
                    formKey: _formKey,
                    title: "Sign Up",
                    buttonText: "Sign Up",
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