import 'package:flutter/material.dart';

class BillsInput extends StatefulWidget {
  final TextEditingController billNameController;
  final TextEditingController accountController;
  final TextEditingController amountController;
  final TextEditingController dueDateController;
  final Function(String?) onCycleChanged;

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

  /// DATE PICKER
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      widget.dueDateController.text =
      picked.toIso8601String().split("T")[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 20),

          /// TITLE
          const Text(
            'Bills Details',
            style: TextStyle(
              color: Color(0xFF694EDA),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 20),

          /// BILL NAME
          _buildField(
            label: "Bill Name",
            hint: "e.g., BCA, GoPay, Cash",
            controller: widget.billNameController,
          ),

          /// ACCOUNT
          _buildField(
            label: "Account Number",
            hint: "0",
            controller: widget.accountController,
            isNumber: true,
          ),

          /// AMOUNT
          _buildField(
            label: "Amount",
            hint: "e.g., 100000",
            controller: widget.amountController,
            isNumber: true,
          ),

          /// DUE DATE
          _buildField(
            label: "Due Date",
            hint: "Select date",
            controller: widget.dueDateController,
            onTap: _pickDate,
            suffix: const Icon(Icons.calendar_today, size: 18),
          ),

          /// BILLING CYCLE
          const SizedBox(height: 15),

          const Text(
            "Billing Cycle",
            style: TextStyle(
              color: Color(0xFF675B5B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String>(
              value: selectedCycle,
              hint: const Text("Select cycle"),
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: "Bulanan", child: Text("Bulanan")),
                DropdownMenuItem(value: "Tahunan", child: Text("Tahunan")),
                DropdownMenuItem(value: "Sekali Bayar", child: Text("Sekali Bayar")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCycle = value;
                });
                widget.onCycleChanged(value);
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// FIELD STYLE FIGMA
  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isNumber = false,
    VoidCallback? onTap,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 15),

        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF675B5B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7FB),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: onTap != null,
            onTap: onTap,
            keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              suffixIcon: suffix,
            ),
          ),
        ),
      ],
    );
  }
}