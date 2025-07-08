import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/account/widgets/promotion_card.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/widgets/common/section_subheader.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final TextEditingController _promoCodeController = TextEditingController();

  // Promotion data
  static const List<Map<String, dynamic>> availablePromotions = [
    {
      'title': '10% off your next ride',
      'code': 'RIDE10',
      'description': 'Expires in 2 days',
      'color': Color(0xFFFFE5B4), // Light orange/beige
      'icon': '🚗',
    },
    {
      'title': 'Free upgrade',
      'code': 'UPGRADE',
      'description': 'Expires in 1 week',
      'color': Color(0xFFE5F3FF), // Light blue
      'icon': '⬆️',
    },
  ];

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Promotions',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.pageVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionSubheader(title: 'Available promotions'),
              const SizedBox(height: AppDimensions.widgetSpacing),
              
              // Available promotions list
              ...availablePromotions.map((promo) => Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.pageHorizontalPadding,
                  right: AppDimensions.pageHorizontalPadding,
                  bottom: AppDimensions.widgetSpacing,
                ),
                child: PromotionCard(
                  title: promo['title'],
                  code: promo['code'],
                  description: promo['description'],
                  backgroundColor: promo['color'],
                  icon: promo['icon'],
                  onTap: () => _applyPromotionCode(promo['code']),
                ),
              )),
              
              const SizedBox(height: AppDimensions.subSectionSpacing),
              const SectionSubheader(title: 'Apply promo code'),
              const SizedBox(height: AppDimensions.widgetSpacing),
              
              // Promo code input section
              _buildPromoCodeSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.subtleGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _promoCodeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  _applyPromoCode();
                },
                style: AppButtonStyles.primaryButton.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                child: Text(
                  'Apply',
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  void _applyPromoCode() {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) {
      SnackbarHelper.showErrorSnackBar(context, 'Please enter a promo code');
      return;
    }

    _applyPromotionCode(code);
  }

  void _applyPromotionCode(String code) {
    // Check if the code matches any available promotions
    final matchingPromo = availablePromotions.firstWhere(
      (promo) => promo['code'].toString().toLowerCase() == code.toLowerCase(),
      orElse: () => {},
    );

    if (matchingPromo.isNotEmpty) {
      SnackbarHelper.showSuccessSnackBar(
        context, 
        'Promo code "${matchingPromo['code']}" applied successfully!'
      );
      _promoCodeController.clear();
    } else {
      SnackbarHelper.showErrorSnackBar(
        context, 
        'Invalid promo code. Please try again.'
      );
    }
  }
}