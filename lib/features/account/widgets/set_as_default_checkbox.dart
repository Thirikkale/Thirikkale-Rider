import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

/// A reusable checkbox widget for "Set as default" functionality
/// Used across payment method screens for consistent behavior
class SetAsDefaultCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;

  const SetAsDefaultCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label ?? 'Set as default payment method'),
      value: value,
      activeColor: AppColors.primaryBlue,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
