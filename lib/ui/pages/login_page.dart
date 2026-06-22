import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:monefy/ui/pages/sign_up_page.dart';
import '../widgets/auth_form.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    try {
      debugPrint('Login attempt: $email');

      await authProvider.login(email, password);

      // Setelah login: load transaksi + summary dari backend
      final token = authProvider.token!;
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);

      await txProvider.loadAll(token);
      // Build wallet list dari relasi transaksi yang baru di-load
      walletProvider.loadWalletsFromTransactions(txProvider.transactions);

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