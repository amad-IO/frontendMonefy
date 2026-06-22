import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../components/currency_formatter.dart';
import '../bills/bills_input.dart';

void showCreateSavingModal(
  BuildContext context,
  Function(String name, int amount, String date) onCreate,
) {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  bool isLoading = false;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> chooseDate() async {
            final now = DateTime.now();
            final minimumDate = DateTime(now.year, now.month, now.day);
            final picked = await showHorizontalDatePicker(
              context: context,
              initialDate: selectedDate ?? minimumDate,
              minimumDate: minimumDate,
              maximumDate: DateTime(now.year + 20, 12, 31),
            );

            if (picked != null) {
              setModalState(() => selectedDate = picked);
            }
          }

          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;

            final rawAmount = amountController.text
                .replaceAll('.', '')
                .replaceAll('Rp', '')
                .replaceAll(' ', '');
            final amount = int.tryParse(rawAmount) ?? 0;

            if (amount <= 0 || selectedDate == null) {
              ScaffoldMessenger.of(sheetContext).showSnackBar(
                SnackBar(
                  content: Text(
                    selectedDate == null
                        ? 'Please choose a target date.'
                        : 'Please enter a valid target amount.',
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }

            setModalState(() => isLoading = true);
            onCreate(
              nameController.text.trim(),
              amount,
              DateFormat('yyyy-MM-dd').format(selectedDate!),
            );

            if (context.mounted) Navigator.pop(context);
          }

          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 18,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primaryPurple,
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34),
                    ),
                  ),
                  child: Column(
                    children: [
                      _GoalModalHeader(
                        onClose: isLoading
                            ? null
                            : () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.panelShadow,
                                blurRadius: 18,
                                offset: Offset(0, -4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Opacity(
                                    opacity: 0.14,
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
                                Form(
                                  key: formKey,
                                  child: ListView(
                                    physics: const BouncingScrollPhysics(),
                                    padding: EdgeInsets.fromLTRB(
                                      20,
                                      24,
                                      20,
                                      MediaQuery.viewInsetsOf(context).bottom +
                                          28,
                                    ),
                                    children: [
                                      const _GoalIntroduction(),
                                      const SizedBox(height: 24),
                                      _GoalField(
                                        label: 'Goal name',
                                        hint: 'e.g. New laptop, Vacation',
                                        icon: Icons.auto_awesome_rounded,
                                        controller: nameController,
                                        textInputAction: TextInputAction.next,
                                        validator: (value) {
                                          if (value == null ||
                                              value.trim().isEmpty) {
                                            return 'Please enter a goal name.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      _GoalField(
                                        label: 'Target amount',
                                        hint: 'Enter your saving target',
                                        icon: Icons.savings_outlined,
                                        prefixText: 'Rp ',
                                        controller: amountController,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          ThousandsSeparatorInputFormatter(),
                                        ],
                                        validator: (value) {
                                          final amount =
                                              int.tryParse(
                                                (value ?? '').replaceAll(
                                                  '.',
                                                  '',
                                                ),
                                              ) ??
                                              0;
                                          if (amount <= 0) {
                                            return 'Please enter a valid amount.';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),
                                      _TargetDateSelector(
                                        date: selectedDate,
                                        onTap: chooseDate,
                                      ),
                                      const SizedBox(height: 28),
                                      SizedBox(
                                        height: 56,
                                        child: FilledButton(
                                          onPressed: isLoading ? null : submit,
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryPurple,
                                            disabledBackgroundColor: AppColors
                                                .primaryPurple
                                                .withValues(alpha: 0.55),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.flag_rounded,
                                                color: AppColors.panelWhite,
                                                size: 20,
                                              ),
                                              SizedBox(width: 9),
                                              Text(
                                                'Create Goal',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.panelWhite,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.panelWhite.withValues(alpha: 0.78),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        'assets/icon/loading.svg',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  ).whenComplete(() {
    nameController.dispose();
    amountController.dispose();
  });
}

class _GoalModalHeader extends StatelessWidget {
  final VoidCallback? onClose;

  const _GoalModalHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.panelWhite.withValues(alpha: 0.48),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.close_rounded,
                      color: AppColors.panelWhite,
                      size: 23,
                    ),
                  ),
                ),
              ),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'Add Goal',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.panelWhite,
                      ),
                    ),
                    Text(
                      'Turn a wish into a plan',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.panelWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 43),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalIntroduction extends StatelessWidget {
  const _GoalIntroduction();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withValues(alpha: 0.24),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: AppColors.panelWhite,
            size: 25,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Goal details',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryPurple,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Set a target and give your dream a deadline.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _GoalField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.prefixText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.disabled,
            ),
            prefixIcon: Icon(icon, color: AppColors.primaryPurple, size: 21),
            prefixText: prefixText,
            prefixStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            filled: true,
            fillColor: AppColors.white2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 17,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _TargetDateSelector extends StatelessWidget {
  final DateTime? date;
  final VoidCallback onTap;

  const _TargetDateSelector({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target date',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.dashboardPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: date == null
                        ? const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No date selected',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Choose when you want to reach it',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE', 'en_US').format(date!),
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryPurple,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat(
                                  'd MMMM yyyy',
                                  'en_US',
                                ).format(date!),
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Text(
                      date == null ? 'Choose' : 'Change',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}
