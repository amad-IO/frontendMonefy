import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monefy/ui/pages/sign_up_page.dart';
import '../widgets/auth_form.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// 🔥 FORM KEY
  final _formKey = GlobalKey<FormState>();

  void handleLogin() {

    /// 🔥 CEK VALIDASI DARI AuthForm
    if (!_formKey.currentState!.validate()) {
      return;
    }

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

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

                  /// 🔥 FORM
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
                          formKey: _formKey, // 🔥 TAMBAH INI
                          title: "Login",
                          buttonText: "Login",
                          usernameController: usernameController,
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