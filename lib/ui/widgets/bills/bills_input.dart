import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../components/currency_formatter.dart';

/// Shared horizontal date picker used by Bills and Wishlist forms.
Future<DateTime?> showHorizontalDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
}) {
  final now = DateTime.now();
  final minDate = minimumDate ?? DateTime(now.year, now.month, now.day);
  final maxDate = maximumDate ?? DateTime(now.year + 20, 12, 31);
  final requestedDate = initialDate ?? minDate;
  final safeInitialDate = requestedDate.isBefore(minDate)
      ? minDate
      : requestedDate.isAfter(maxDate)
      ? maxDate
      : requestedDate;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _HorizontalDatePickerSheet(
      initialDate: safeInitialDate,
      minimumDate: minDate,
      maximumDate: maxDate,
    ),
  );
}

class BillsInput extends StatefulWidget {
  final TextEditingController billNameController;
  final TextEditingController accountController;
  final TextEditingController amountController;
  final TextEditingController dueDateController;
  final ValueChanged<String?> onCycleChanged;

  const BillsInput({
    super.key,
    required this.billNameController,
    required this.accountController,
    required this.amountController,
    required this.dueDateController,
    required this.onCycleChanged,
  });

  @override
  State<BillsInput> createState() => _BillsInputState();
}

class _BillsInputState extends State<BillsInput> {
  String? selectedCycle;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final minimumDate = DateTime(now.year, now.month, now.day);
    final savedDate = DateTime.tryParse(widget.dueDateController.text);
    final initialDate = savedDate != null && !savedDate.isBefore(minimumDate)
        ? savedDate
        : minimumDate;

    final picked = await showHorizontalDatePicker(
      context: context,
      initialDate: initialDate,
      minimumDate: minimumDate,
      maximumDate: DateTime(now.year + 20, 12, 31),
    );

    if (picked != null) {
      widget.dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BillField(
          label: 'Bill name',
          hint: 'e.g. Electricity, Internet, Netflix',
          icon: Icons.receipt_rounded,
          controller: widget.billNameController,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a bill name.';
            }
            return null;
          },
        ),
        const SizedBox(height: 17),
        _BillField(
          label: 'Account number',
          hint: 'Enter customer or account number',
          icon: Icons.badge_outlined,
          controller: widget.accountController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an account number.';
            }
            return null;
          },
        ),
        const SizedBox(height: 17),
        _BillField(
          label: 'Amount',
          hint: 'Enter payment amount',
          icon: Icons.payments_outlined,
          prefixText: 'Rp ',
          controller: widget.amountController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          validator: (value) {
            final amount =
                double.tryParse((value ?? '').replaceAll('.', '')) ?? 0;
            if (amount <= 0) return 'Please enter a valid amount.';
            return null;
          },
        ),
        const SizedBox(height: 17),
        _BillingCycleField(
          value: selectedCycle,
          onChanged: (value) {
            setState(() => selectedCycle = value);
            widget.onCycleChanged(value);
          },
        ),
        const SizedBox(height: 17),
        _DueDateSelector(
          controller: widget.dueDateController,
          onTap: _pickDate,
        ),
      ],
    );
  }
}

class _DueDateSelector extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onTap;

  const _DueDateSelector({required this.controller, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final selectedDate = DateTime.tryParse(controller.text);
    final hasDate = selectedDate != null;

    return FormField<String>(
      key: ValueKey(controller.text),
      initialValue: controller.text,
      validator: (_) =>
          controller.text.isEmpty ? 'Please choose a due date.' : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Due date',
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
                          Icons.calendar_month_rounded,
                          color: AppColors.primaryPurple,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: hasDate
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat(
                                      'EEEE',
                                      'en_US',
                                    ).format(selectedDate),
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
                                    ).format(selectedDate),
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : const Column(
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
                                    'Set when this bill is due',
                                    style: TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
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
                          hasDate ? 'Change' : 'Choose',
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
            if (field.hasError) ...[
              const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BillField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final String? Function(String?)? validator;

  const _BillField({
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

class _HorizontalDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime minimumDate;
  final DateTime maximumDate;

  const _HorizontalDatePickerSheet({
    required this.initialDate,
    required this.minimumDate,
    required this.maximumDate,
  });

  @override
  State<_HorizontalDatePickerSheet> createState() =>
      _HorizontalDatePickerSheetState();
}

class _HorizontalDatePickerSheetState
    extends State<_HorizontalDatePickerSheet> {
  late DateTime _selectedDate;
  late DateTime _visibleMonth;
  late PageController _monthController;
  late ScrollController _yearController;

  int get _monthCount =>
      (widget.maximumDate.year - widget.minimumDate.year) * 12 +
      widget.maximumDate.month -
      widget.minimumDate.month +
      1;

  int get _initialMonthIndex =>
      (widget.initialDate.year - widget.minimumDate.year) * 12 +
      widget.initialDate.month -
      widget.minimumDate.month;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _monthController = PageController(initialPage: _initialMonthIndex);
    _yearController = ScrollController(
      initialScrollOffset:
          ((widget.initialDate.year - widget.minimumDate.year) * 68.0).clamp(
            0,
            double.infinity,
          ),
    );
  }

  @override
  void dispose() {
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime _monthAt(int index) =>
      DateTime(widget.minimumDate.year, widget.minimumDate.month + index);

  void _changeMonth(int delta) {
    final currentIndex =
        (_visibleMonth.year - widget.minimumDate.year) * 12 +
        _visibleMonth.month -
        widget.minimumDate.month;
    final target = (currentIndex + delta).clamp(0, _monthCount - 1);
    _monthController.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _selectYear(int year) {
    final targetIndex =
        (year - widget.minimumDate.year) * 12 +
        _visibleMonth.month -
        widget.minimumDate.month;
    _monthController.animateToPage(
      targetIndex.clamp(0, _monthCount - 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onMonthChanged(int index) {
    final month = _monthAt(index);
    final maxDay = DateUtils.getDaysInMonth(month.year, month.month);
    final candidate = DateTime(
      month.year,
      month.month,
      _selectedDate.day.clamp(1, maxDay),
    );

    setState(() {
      _visibleMonth = month;
      if (!candidate.isBefore(widget.minimumDate) &&
          !candidate.isAfter(widget.maximumDate)) {
        _selectedDate = candidate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.62,
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 22 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(72, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Choose due date',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, _selectedDate),
                style: TextButton.styleFrom(
                  minimumSize: const Size(72, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEEE, d MMMM yyyy', 'en_US').format(_selectedDate),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryPurple,
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select year',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _yearController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.maximumDate.year - widget.minimumDate.year + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final year = widget.minimumDate.year + index;
                final selected = year == _visibleMonth.year;
                return GestureDetector(
                  onTap: () => _selectYear(year),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryPurple
                          : AppColors.white2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryPurple
                            : AppColors.primaryPurple.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      '$year',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.panelWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MonthArrow(
                icon: Icons.chevron_left_rounded,
                onTap: () => _changeMonth(-1),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM yyyy', 'en_US').format(_visibleMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _MonthArrow(
                icon: Icons.chevron_right_rounded,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 154,
            child: PageView.builder(
              controller: _monthController,
              itemCount: _monthCount,
              onPageChanged: _onMonthChanged,
              itemBuilder: (context, index) {
                final month = _monthAt(index);
                return _HorizontalDays(
                  month: month,
                  selectedDate: _selectedDate,
                  minimumDate: widget.minimumDate,
                  maximumDate: widget.maximumDate,
                  onSelected: (date) => setState(() => _selectedDate = date),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Swipe left or right to change month',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textSecondary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizontalDays extends StatefulWidget {
  final DateTime month;
  final DateTime selectedDate;
  final DateTime minimumDate;
  final DateTime maximumDate;
  final ValueChanged<DateTime> onSelected;

  const _HorizontalDays({
    required this.month,
    required this.selectedDate,
    required this.minimumDate,
    required this.maximumDate,
    required this.onSelected,
  });

  @override
  State<_HorizontalDays> createState() => _HorizontalDaysState();
}

class _HorizontalDaysState extends State<_HorizontalDays> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    final selectedInMonth =
        widget.selectedDate.year == widget.month.year &&
        widget.selectedDate.month == widget.month.month;
    final initialDay = selectedInMonth ? widget.selectedDate.day : 1;
    _controller = ScrollController(
      initialScrollOffset: ((initialDay - 1) * 68.0).clamp(0, double.infinity),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(
      widget.month.year,
      widget.month.month,
    );

    return ListView.separated(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      itemCount: days,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final date = DateTime(widget.month.year, widget.month.month, index + 1);
        final disabled =
            date.isBefore(widget.minimumDate) ||
            date.isAfter(widget.maximumDate);
        final selected = DateUtils.isSameDay(date, widget.selectedDate);

        return GestureDetector(
          onTap: disabled ? null : () => widget.onSelected(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 60,
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryPurple : AppColors.white2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primaryPurple
                    : AppColors.primaryPurple.withValues(alpha: 0.08),
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPurple.withValues(alpha: 0.22),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : null,
            ),
            child: Opacity(
              opacity: disabled ? 0.35 : 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'en_US').format(date),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? AppColors.panelWhite.withValues(alpha: 0.82)
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.panelWhite
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MonthArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dashboardPurple.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.primaryPurple, size: 22),
        ),
      ),
    );
  }
}

class _BillingCycleField extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _BillingCycleField({required this.value, required this.onChanged});

  String? _labelFor(String? cycle) {
    switch (cycle) {
      case 'Bulanan':
        return 'Monthly';
      case 'Tahunan':
        return 'Yearly';
      case 'Sekali Bayar':
        return 'One-time';
      default:
        return null;
    }
  }

  Future<void> _showCyclePicker(
    BuildContext context,
    FormFieldState<String> field,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BillingCycleSheet(selectedValue: field.value),
    );

    if (selected != null) {
      field.didChange(selected);
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billing cycle',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 7),
        FormField<String>(
          initialValue: value,
          validator: (selected) =>
              selected == null ? 'Please select a billing cycle.' : null,
          builder: (field) {
            final label = _labelFor(field.value);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: AppColors.white2,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _showCyclePicker(context, field),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: field.hasError
                              ? AppColors.error
                              : AppColors.primaryPurple.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.autorenew_rounded,
                            color: AppColors.primaryPurple,
                            size: 21,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label ?? 'Select a billing cycle',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: label == null ? 13 : 14,
                                fontWeight: label == null
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                                color: label == null
                                    ? AppColors.disabled
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (field.hasError) ...[
                  const SizedBox(height: 7),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BillingCycleSheet extends StatelessWidget {
  final String? selectedValue;

  const _BillingCycleSheet({required this.selectedValue});

  static const _options = [
    _CycleOption(
      value: 'Bulanan',
      label: 'Monthly',
      description: 'Repeats every month',
      icon: Icons.calendar_view_month_rounded,
      color: AppColors.primaryPurple,
    ),
    _CycleOption(
      value: 'Tahunan',
      label: 'Yearly',
      description: 'Repeats once a year',
      icon: Icons.calendar_today_rounded,
      color: AppColors.billsColor,
    ),
    _CycleOption(
      value: 'Sekali Bayar',
      label: 'One-time',
      description: 'A single payment only',
      icon: Icons.looks_one_rounded,
      color: AppColors.transferOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.panelWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Choose billing cycle',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'How often does this bill repeat?',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          ..._options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CycleOptionTile(
                option: option,
                selected: selectedValue == option.value,
                onTap: () => Navigator.pop(context, option.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleOptionTile extends StatelessWidget {
  final _CycleOption option;
  final bool selected;
  final VoidCallback onTap;

  const _CycleOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.dashboardPurple.withValues(alpha: 0.55)
          : AppColors.white2,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.primaryPurple
                  : AppColors.primaryPurple.withValues(alpha: 0.06),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(option.icon, color: option.color, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryPurple
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryPurple
                        : AppColors.disabled,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.panelWhite,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleOption {
  final String value;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const _CycleOption({
    required this.value,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });
}
