import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class RideOptionDetailScreen extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String description;
  final String buttonText;
  final VoidCallback? onChooseOption;

  const RideOptionDetailScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.buttonText,
    this.onChooseOption,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(
        title: '',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Hero image section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Content section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: AppTextStyles.heading1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  
                  // Choose button
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onChooseOption,
                          style: AppButtonStyles.primaryButton.copyWith(
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.pageVerticalPadding),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
