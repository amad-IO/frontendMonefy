import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class BillsInput extends StatefulWidget {
  final String label;
  final String hint;
  final bool isNumber;
  final bool isTextOnly;

  final bool isDate; // ✅ BARU
  final bool isDropdown; // ✅ BARU
  final List<String>? dropdownItems; // ✅ BARU

  const BillsInput({
    super.key,
    required this.label,
    required this.hint,
    this.isNumber = false,
    this.isTextOnly = false,
    this.isDate = false,
    this.isDropdown = false,
    this.dropdownItems,
  });

  @override
  State<BillsInput> createState() => _BillsInputState();
}

class _BillsInputState extends State<BillsInput> {

  final TextEditingController _controller = TextEditingController();
  String? selectedValue;

  /// DATE PICKER
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _controller.text =
        "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(widget.label, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),

          /// 📅 DATE INPUT
          if (widget.isDate)
            TextFormField(
              controller: _controller,
              readOnly: true,
              onTap: _pickDate,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${widget.label} tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: AppColors.white2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            )

          /// 🔁 DROPDOWN INPUT
          else if (widget.isDropdown)
            DropdownButtonFormField<String>(
              value: selectedValue,
              items: widget.dropdownItems!
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedValue = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${widget.label} tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: AppColors.white2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            )

          /// ✍️ DEFAULT INPUT
          else
            TextFormField(
              controller: _controller,
              keyboardType:
              widget.isNumber ? TextInputType.number : TextInputType.text,
              inputFormatters: [
                if (widget.isNumber)
                  FilteringTextInputFormatter.digitsOnly,
                if (widget.isTextOnly)
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z\s,]'),
                  ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '${widget.label} tidak boleh kosong';
                }

                if (widget.isTextOnly &&
                    RegExp(r'[0-9]').hasMatch(value)) {
                  return 'Tidak boleh mengandung angka';
                }

                if (widget.isNumber &&
                    !RegExp(r'^[0-9]+$').hasMatch(value)) {
                  return 'Harus berupa angka';
                }

                return null;
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                filled: true,
                fillColor: AppColors.white2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
        ],
      ),
    );
  }
}