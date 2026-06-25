import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_brand_header.dart';
import '../widgets/auth_form.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/wallet_provider.dart';
import 'main_page.dart';

/// Halaman auth terpadu — Login & Sign Up dalam satu screen.
/// Header (logo + "Monefy.") TIDAK bergerak saat toggle.
/// Hanya white card yang slide masuk dari atas ke bawah.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  final _loginFormKey   = GlobalKey<FormState>();
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl  = TextEditingController();

  final _signUpFormKey      = GlobalKey<FormState>();
  final _signUpUsernameCtrl = TextEditingController();
  final _signUpEmailCtrl    = TextEditingController();
  final _signUpPassCtrl     = TextEditingController();
  final _signUpConfirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _signUpUsernameCtrl.dispose();
    _signUpEmailCtrl.dispose();
    _signUpPassCtrl.dispose();
    _signUpConfirmCtrl.dispose();
    super.dispose();
  }

  void _switchToSignUp() => setState(() => _isLogin = false);
  void _switchToLogin()  => setState(() => _isLogin = true);

  void _handleLogin() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoading) return;
    if (!_loginFormKey.currentState!.validate()) return;

    try {
      debugPrint('Login attempt: ${_loginEmailCtrl.text.trim()}');
      await auth.login(
        _loginEmailCtrl.text.trim(),
        _loginPassCtrl.text.trim(),
      );

      final token      = auth.token!;
      final txProvider = Provider.of<TransactionProvider>(context, listen: false);
      final walletProv = Provider.of<WalletProvider>(context, listen: false);

      // Fetch profil di background untuk pastikan avatar sinkron
      auth.fetchProfile(token).ignore();

      await txProvider.loadAll(token);
      walletProv.loadWalletsFromTransactions(txProvider.transactions);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MainPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _handleRegister() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoading) return;
    if (!_signUpFormKey.currentState!.validate()) return;

    final pass    = _signUpPassCtrl.text.trim();
    final confirm = _signUpConfirmCtrl.text.trim();

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama')),
      );
      return;
    }

    try {
      debugPrint('SignUp attempt: ${_signUpUsernameCtrl.text.trim()}');
      await auth.signUp(
        _signUpUsernameCtrl.text.trim(),
        _signUpEmailCtrl.text.trim(),
        pass,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up berhasil! Silakan login.')),
      );
      _switchToLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD5CEF5),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header FIXED - tidak ikut animasi
            const SizedBox(height: 16),
            const AuthBrandHeader(),
            const SizedBox(height: 4),

            // Hanya white card yang beranimasi
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0), // dari bawah
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutQuart,
                    )),
                    child: child,
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: _isLogin
                    ? _WhiteCard(
                        key: const ValueKey('login'),
                        child: AuthForm(
                          formKey: _loginFormKey,
                          title: 'Login',
                          buttonText: 'Login',
                          isRegister: false,
                          usernameController: null,
                          emailController: _loginEmailCtrl,
                          passwordController: _loginPassCtrl,
                          onSubmit: _handleLogin,
                          onSwitch: _switchToSignUp,
                        ),
                      )
                    : _WhiteCard(
                        key: const ValueKey('signup'),
                        child: AuthForm(
                          formKey: _signUpFormKey,
                          title: 'Sign Up',
                          buttonText: 'Sign Up',
                          isRegister: true,
                          usernameController: _signUpUsernameCtrl,
                          emailController: _signUpEmailCtrl,
                          passwordController: _signUpPassCtrl,
                          confirmPasswordController: _signUpConfirmCtrl,
                          onSubmit: _handleRegister,
                          onSwitch: _switchToLogin,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: child,
    );
  }
}

