import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';

class DialogHelper {
  /// Shows a confirmation dialog with custom title, content, and actions
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    Color? confirmButtonColor,
    IconData? titleIcon,
    Color? titleIconColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: titleIcon != null
              ? Row(
                  children: [
                    Icon(
                      titleIcon,
                      color: titleIconColor ?? AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.heading3,
                    ),
                  ],
                )
              : Center(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3,
                    textAlign: TextAlign.center,
                  ),
                ),
          content: Text(
            content,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                    onCancel?.call();
                  },
                  child: Text(
                    cancelText ?? 'Cancel',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    onConfirm?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmButtonColor ?? AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    confirmText ?? 'Confirm',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog with a checkbox option (like "Set as default")
  static Future<bool?> showCheckboxDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String checkboxLabel,
    bool initialCheckboxValue = false,
    String? confirmText,
    String? cancelText,
    Color? confirmButtonColor,
    IconData? titleIcon,
    Color? titleIconColor,
    Function(bool isChecked)? onConfirm,
    VoidCallback? onCancel,
  }) {
    bool checkboxValue = initialCheckboxValue;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: titleIcon != null
                  ? Row(
                      children: [
                        Icon(
                          titleIcon,
                          color: titleIconColor ?? AppColors.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: AppDimensions.widgetSpacing),
                        Center(
                          child: Text(
                            title,
                            style: AppTextStyles.heading3,
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                        title,
                        style: AppTextStyles.heading3,
                        textAlign: TextAlign.center,
                      ),
                    ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    content,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: Text(checkboxLabel),
                    value: checkboxValue,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        checkboxValue = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                        onCancel?.call();
                      },
                      child: Text(
                        cancelText ?? 'Cancel',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: checkboxValue
                          ? () {
                              Navigator.of(context).pop(true);
                              onConfirm?.call(checkboxValue);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmButtonColor ?? AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.lightGrey,
                        disabledForegroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        confirmText ?? 'Confirm',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Shows a simple info dialog with just OK button
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? buttonText,
    IconData? titleIcon,
    Color? titleIconColor,
    VoidCallback? onOk,
  }) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: titleIcon != null
              ? Row(
                  children: [
                    Icon(
                      titleIcon,
                      color: titleIconColor ?? AppColors.primaryBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppTextStyles.heading3,
                    ),
                  ],
                )
              : Text(
                  title,
                  style: AppTextStyles.heading3,
                ),
          content: Text(
            content,
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOk?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                ),
                child: Text(buttonText ?? 'OK'),
              ),
            ),
          ],
        );
      },
    );
  }
}
