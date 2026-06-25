import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

class AuthForm extends StatefulWidget {
  final String title;
  final String buttonText;
  final bool isRegister;

  final GlobalKey<FormState> formKey;

  final TextEditingController? usernameController; // ✅ OPTIONAL
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? confirmPasswordController;

  final VoidCallback onSubmit;
  final VoidCallback onSwitch;

  const AuthForm({
    super.key,
    required this.title,
    required this.buttonText,
    required this.formKey,
    this.usernameController, // ✅ TIDAK WAJIB
    required this.emailController,
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

  InputDecoration _inputDecoration({
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.white2,
      prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: AppColors.dashboardPurple.withValues(alpha: 0.55),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.32,
              child: SvgPicture.asset(
                'assets/images/kontur.svg',
                fit: BoxFit.cover,
                colorFilter: const ColorFilter.mode(
                  AppColors.decorativePurple,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 28,
                right: 28,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: widget.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                /// TITLE
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isRegister
                      ? 'Create your account and start organizing money.'
                      : 'Welcome back, let us continue your money plan.',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 22),

                /// USERNAME (REGISTER ONLY)
                if (widget.isRegister) ...[
                  const _FieldLabel("Username"),
                  const SizedBox(height: 5),

                  TextFormField(
                    controller: widget.usernameController!,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Username wajib diisi";
                      }
                      return null;
                    },
                    decoration: _inputDecoration(icon: Icons.person_rounded),
                  ),

                  const SizedBox(height: 20),
                ],

                /// EMAIL
                const _FieldLabel("Email"),
                const SizedBox(height: 5),

                TextFormField(
                  controller: widget.emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email wajib diisi";
                    }
                    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                      return "Format email tidak valid";
                    }
                    return null;
                  },
                  decoration: _inputDecoration(icon: Icons.email_rounded),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                const _FieldLabel("Password"),
                const SizedBox(height: 5),

                TextFormField(
                  controller: widget.passwordController,
                  obscureText: isPasswordHidden,
                  autovalidateMode:
                  AutovalidateMode.onUserInteraction,
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
                  decoration: _inputDecoration(
                    icon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordHidden = !isPasswordHidden;
                        });
                      },
                    ),
                  ),
                ),

                /// CONFIRM PASSWORD (REGISTER ONLY)
                if (widget.isRegister) ...[
                  const SizedBox(height: 20),

                  const _FieldLabel("Confirm Password"),
                  const SizedBox(height: 5),

                  TextFormField(
                    controller: widget.confirmPasswordController!,
                    obscureText: isConfirmPasswordHidden,
                    autovalidateMode:
                    AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Konfirmasi password wajib diisi";
                      }
                      if (value != widget.passwordController.text) {
                        return "Password tidak sama";
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      icon: Icons.verified_user_rounded,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.textSecondary,
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

                // Jarak proporsional antara field terakhir dan button
                // Tidak pakai Spacer() agar tidak mendorong button ke pojok bawah
                if (!widget.isRegister)
                  const SizedBox(height: 28)
                else
                  const SizedBox(height: 24),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: AppColors.panelWhite,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: widget.onSubmit,
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
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
                        fontFamily: 'Nunito',
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryPurple,
      ),
    );
  }
}
