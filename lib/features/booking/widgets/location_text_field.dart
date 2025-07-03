import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class LocationTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool autoFocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const LocationTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.autoFocus = false,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<LocationTextField> createState() => _LocationTextFieldState();
}

class _LocationTextFieldState extends State<LocationTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();

    // Set initial value if provided
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
    
    // Listen to focus changes
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
    
    // Listen to text changes to rebuild widget
    _controller.addListener(() {
      setState(() {});
    });
  }


  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  bool get _shouldShowClearButton {
    return _hasFocus && _controller.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      autofocus: widget.autoFocus,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon:
            widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
        suffixIcon: _shouldShowClearButton ? IconButton(onPressed: _clearText, icon: const Icon(Icons.clear_rounded, color: AppColors.textPrimary, size: 20,), splashRadius: 20,) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)
        ),
        filled: true,
        fillColor: AppColors.subtleGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
