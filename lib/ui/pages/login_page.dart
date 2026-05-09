import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:monefy/ui/pages/sign_up_page.dart';
import '../widgets/auth_form.dart';
import '../../providers/auth_provider.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoading) return;

    /// VALIDASI FORM
    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      /// DEBUG
      print("LOGIN BUTTON DIKLIK");
      print("EMAIL: $email");

      await authProvider.login(email, password);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5CEF5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
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

                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: AuthForm(
                          formKey: _formKey,
                          title: "Login",
                          buttonText: "Login",
                          isRegister: false,
                          // ✅ LOGIN tidak butuh username
                          usernameController: null,
                          emailController: emailController,
                          passwordController: passwordController,
                          onSubmit: handleLogin,
                          onSwitch: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}