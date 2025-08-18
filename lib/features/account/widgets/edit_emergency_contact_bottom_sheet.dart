import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';

class EditEmergencyContactBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialPhone,
    required Function(String name, String phone) onSave,
    required VoidCallback onDelete,
  }) async {
    final nameController = TextEditingController(text: initialName);
    final phoneController = TextEditingController(text: initialPhone);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              // decoration: const BoxDecoration(
              //   color: AppColors.white,
              //   borderRadius: BorderRadius.only(
              //     topLeft: Radius.circular(20),
              //     topRight: Radius.circular(20),
              //   ),
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Edit Contact', style: AppTextStyles.heading3),
                        const SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: AppButtonStyles.primaryButton,
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  final phone = phoneController.text.trim();
                                  if (name.isNotEmpty && phone.isNotEmpty) {
                                    onSave(name, phone);
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: AppButtonStyles.errorButton,
                                onPressed: () {
                                  onDelete();
                                  Navigator.pop(context);
                                },
                                child: const Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
