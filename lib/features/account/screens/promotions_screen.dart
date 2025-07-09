import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/account/widgets/promotion_card.dart';
import 'package:thirikkale_rider/features/account/widgets/promo_code_input.dart';
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
      'icon': Icons.directions_car,
    },
    {
      'title': 'Free upgrade',
      'code': 'UPGRADE',
      'description': 'Expires in 1 week',
      'color': Color(0xFFE5F3FF), // Light blue
      'icon': Icons.upgrade,
    },
    {
      'title': 'Student discount',
      'code': 'STUDENT25',
      'description': 'Expires in 1 month',
      'color': Color(0xFFE8F5E8), // Light green
      'icon': Icons.school,
    },
    {
      'title': 'Weekend special',
      'code': 'WEEKEND',
      'description': 'Valid on weekends only',
      'color': Color(0xFFF0E6FF), // Light purple
      'icon': Icons.weekend,
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
              PromoCodeInput(
                controller: _promoCodeController,
                onApply: _applyPromoCode,
              ),
            ],
          ),
        ),
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