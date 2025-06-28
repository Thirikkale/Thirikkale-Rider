import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class CustomInputFieldLabel extends StatefulWidget {
  final String label;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool isDateField;
  final bool isTimeField;
  final TextEditingController? controller;
  final String? initialValue;
  final Function(String?)? onChanged;
  final Function(DateTime?)? onDateSelected;
  final Function(TimeOfDay?)? onTimeSelected;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomInputFieldLabel({
    super.key,
    required this.label,
    this.prefixIcon,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.isDateField = false,
    this.isTimeField = false,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onDateSelected,
    this.onTimeSelected,
    this.initialDate,
    this.initialTime,
    this.validator,
    this.focusNode,
  });

  @override
  State<CustomInputFieldLabel> createState() => _CustomInputFieldLabelState();
}

class _CustomInputFieldLabelState extends State<CustomInputFieldLabel> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _focusNode = widget.focusNode ?? FocusNode();

    // Initialize date/time field if applicable
    if (widget.isDateField && widget.initialDate != null) {
      final date = widget.initialDate!;
      _controller.text = "${date.day}/${date.month}/${date.year}";
    }
    if (widget.isTimeField && widget.initialTime != null) {
      final time = widget.initialTime!;
      _controller.text =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
      if (widget.onTimeSelected != null) {
        widget.onTimeSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if this is a multiline field
    bool isMultiline = widget.keyboardType == TextInputType.multiline;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      cursorColor: AppColors.primaryBlue,
      minLines: isMultiline ? (widget.minLines ?? 3) : null,
      maxLines:
          isMultiline ? (widget.maxLines ?? 6) : (widget.maxLines ?? 1),
      readOnly: widget.isDateField || widget.isTimeField,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onTap:
          widget.isDateField
              ? _selectDate
              : widget.isTimeField
              ? _selectTime
              : null,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: widget.label,
        labelStyle: const TextStyle(color: AppColors.grey),
        floatingLabelStyle: const TextStyle(color: AppColors.primaryBlue),
        prefixIcon:
            widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon:
            widget.isDateField
                ? Icon(Icons.calendar_today, color: AppColors.primaryBlue)
                : widget.isTimeField
                ? Icon(Icons.access_time, color: AppColors.primaryBlue)
                : null,
        hintText:
            widget.isDateField
                ? 'Select date'
                : widget.isTimeField
                ? 'Select time'
                : 'Enter ${widget.label.toLowerCase()}',
        hintStyle: const TextStyle(color: AppColors.grey),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
