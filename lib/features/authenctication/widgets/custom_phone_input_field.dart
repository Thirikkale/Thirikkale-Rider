import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:flutter/material.dart';

class CustomPhoneInputField extends StatefulWidget {
  final String label;
  final String countryCode;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomPhoneInputField({
    super.key,
    this.label = 'Phone Number',
    this.countryCode = '+94',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomPhoneInputField> createState() => _CustomPhoneInputFieldState();
}

class _CustomPhoneInputFieldState extends State<CustomPhoneInputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: TextInputType.phone,
      cursorColor: AppColors.primaryBlue,
      style: const TextStyle(fontWeight: FontWeight.w600),
      onChanged: (value) {
        // Extract clean number and pass it to parent
        if (widget.onChanged != null) {
          final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
          widget.onChanged!(cleanNumber);
        }
      },
      inputFormatters: [
        PhoneInputFormatter(defaultCountryCode: 'LK', allowEndlessPhone: false),
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.phone),
        prefixText: '${widget.countryCode} ',
        prefixStyle: const TextStyle(
          color: AppColors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelText: widget.label,
        labelStyle: const TextStyle(
          color: AppColors.grey,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.primaryBlue),
        hintText: 'Enter your phone number',
        hintStyle: const TextStyle(
          color: AppColors.grey,
          fontWeight: FontWeight.w500,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.grey, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
