import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/account/screens/payment_methods/add_payment_method_screen.dart';
import 'package:thirikkale_rider/features/account/widgets/cash_payment_bottomsheet.dart';
import 'package:thirikkale_rider/features/account/widgets/payment_method_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/card_details_bottom_sheet.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _defaultMethod = 'Card';

  void _showCardDetailsBottomSheet(BuildContext context) {
    CardDetailsBottomSheet.show(
      context,
      cardNumber: '**** **** **** 4890',
      expiryDate: '12/24',
      cardHolderName: 'Olivia Bennett',
      isDefault: false, // Change this based on actual card status
      onSetAsDefault: () {
        // Handle set as default logic
        setState(() {
          _defaultMethod = 'Card';
        });
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Card set as default payment method!',
        );
      },
      onEdit: () {
        // Handle edit logic
      },
      onDelete: () {
        // Handle delete logic and show snackbar
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Payment method deleted successfully',
        );
      },
    );
  }

  void _showCashPaymentDialog(BuildContext context) {
    CashPaymentBottomSheet.show(
      context,
      onConfirm: (isSetAsDefault) {
        // The new bottom sheet only calls this when 'Set as default' is pressed
        if (isSetAsDefault) {
          setState(() {
            _defaultMethod = 'Cash';
          });
          SnackbarHelper.showSuccessSnackBar(
            context,
            'Cash set as default payment method!',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Payment methods',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: Text('Payment methods', style: AppTextStyles.heading3),
          ),
          Expanded(
            child: Column(
              children: [
                PaymentMethodTile(
                  icon: Icons.credit_card,
                  title: 'Card',
                  subtitle: 'Visa •••• •••• •••• 4567',
                  isDefault: _defaultMethod == 'Card',
                  onTap: () {
                    _showCardDetailsBottomSheet(context);
                  },
                ),
                PaymentMethodTile(
                  icon: Icons.money,
                  title: 'Cash',
                  isDefault: _defaultMethod == 'Cash',
                  isCash: true,
                  onTap: () {
                    _showCashPaymentDialog(context);
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(
                    AppDimensions.pageHorizontalPadding,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const AddPaymentMethodScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Add Card',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.pageVerticalPadding),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
