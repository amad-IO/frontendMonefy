import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final bool isRegister;

  final GlobalKey<FormState> formKey;

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;

  final VoidCallback onSubmit;
  final VoidCallback onSwitch;

  const AuthForm({
    required this.title,
    required this.buttonText,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    this.confirmPasswordController,
    required this.onSubmit,
    required this.onSwitch,
    this.isRegister = false,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        /// BACKGROUND
        Positioned.fill(
          child: Opacity(
            opacity: 0.9,
            child: SvgPicture.asset(
              'assets/images/kontur.svg',
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// FORM
        Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: widget.formKey, // 🔥 FIX PENTING
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// TITLE
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF694EDA),
                  ),
                ),

                const SizedBox(height: 20),

                /// USERNAME
                const Text("Username",
                    style: TextStyle(color: Color(0xFF694EDA))),
                const SizedBox(height: 5),

                TextFormField(
                  controller: widget.usernameController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Username wajib diisi";
                    }
                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return "Username tidak boleh mengandung angka";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF6F7FB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                const Text("Password",
                    style: TextStyle(color: Color(0xFF694EDA))),
                const SizedBox(height: 5),

                TextFormField(
                  controller: widget.passwordController,
                  obscureText: isPasswordHidden,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password wajib diisi";
                    }
                    if (!RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).+$',
                    ).hasMatch(value)) {
                      return "Harus ada huruf besar, kecil, angka & simbol";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),

                    /// 👁️ ICON MATA
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),

                /// CONFIRM PASSWORD
                if (widget.isRegister) ...[
                  const SizedBox(height: 20),

                  const Text("Confirm Password",
                      style: TextStyle(color: Color(0xFF694EDA))),
                  const SizedBox(height: 5),

                  TextFormField(
                    controller: widget.confirmPasswordController,
                    obscureText: isConfirmPasswordHidden,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Konfirmasi password wajib diisi";
                      }
                      if (value != widget.passwordController.text) {
                        return "Password tidak sama";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),

                      /// 👁️ ICON MATA
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordHidden =
                            !isConfirmPasswordHidden;
                          });
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF694EDA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: widget.onSubmit,
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                /// SWITCH
                Center(
                  child: GestureDetector(
                    onTap: widget.onSwitch,
                    child: Text(
                      widget.isRegister
                          ? "Already have an account? Login"
                          : "Don't have an account? Sign Up",
                      style: const TextStyle(
                        color: Color(0xFF694EDA),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}