import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_form.dart';
import 'login_page.dart';
import '../../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    /// CEGAH DOUBLE CLICK
    if (authProvider.isLoading) return;

    /// VALIDASI FORM
    if (!_formKey.currentState!.validate()) return;

    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    ///  VALIDASI CONFIRM PASSWORD
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak sama")),
      );
      return;
    }

    /// VALIDASI EMAIL FORMAT (OPSIONAL TAPI BAGUS)
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Format email tidak valid")),
      );
      return;
    }

    try {
      /// DEBUG
      debugPrint('SignUp attempt: $username');

      /// CALL API
      await authProvider.signUp(username, email, password);

      debugPrint('SignUp success');

      /// PINDAH KE LOGIN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      /// NOTIF
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sign up berhasil")),
      );

    } catch (e) {
      debugPrint('SignUp error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
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

                    /// CONTROLLERS
                    usernameController: usernameController,
                    emailController: emailController,
                    passwordController: passwordController,
                    confirmPasswordController: confirmPasswordController,

                    /// ACTIONS
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