import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
// The 'add_payment_method_screen.dart' is no longer needed for this flow.
// import 'package.thirikkale_rider/features/account/screens/payment_methods/add_payment_method_screen.dart';
import 'package:thirikkale_rider/features/account/widgets/cash_payment_bottomsheet.dart';
import 'package:thirikkale_rider/features/account/widgets/payment_method_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/card_details_bottom_sheet.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

// --- ADD THESE IMPORTS ---
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:thirikkale_rider/core/config/api_config.dart';
// -------------------------

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _defaultMethod = 'Cash';
  bool _isAddingCard = false; // State for the button's loading indicator

  // This function now contains the full logic for adding a new card
  Future<void> _handleAddNewCard() async {
    // Prevent multiple taps while processing
    if (_isAddingCard) return;

    // Show loading indicator on the button
    setState(() {
      _isAddingCard = true;
    });

    try {
      // --- HARDCODED TEST DATA ---
      // In a real app, this would come from your AuthProvider.
      // Use a NEW, unused riderId for each clean test.
      const String testRiderId = "a_unique_string_id_123";
      // This token must be valid if your backend endpoint is protected.
      // For testing, you might temporarily disable security on the setup-intent endpoint.
      const String testAuthToken = "your_valid_jwt_or_placeholder_token";
      // ---------------------------

      // 1. Call your backend to get a clientSecret for the SetupIntent
      final uri = Uri.parse(ApiConfig.setupPaymentIntent);
      final headers = ApiConfig.getAuthHeaders(testAuthToken);
      final body = jsonEncode({'riderId': testRiderId});

      // Diagnostic logs
      // ignore: avoid_print
      print('Requesting client secret for rider: $testRiderId');
      // ignore: avoid_print
      print('POST $uri');
      // ignore: avoid_print
      print('Headers: $headers');
      // ignore: avoid_print
      print('Body: $body');

      http.Response? response;
      try {
        response = await http
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 100));

        // ignore: avoid_print
        print('Backend response status: ${response.statusCode}');
        // ignore: avoid_print
        print('Backend response body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception('Server error: ${response.body}');
        }
      } on SocketException catch (se) {
        // ignore: avoid_print
        print('Network (Socket) error while contacting $uri : $se');
        rethrow;
      } on TimeoutException catch (te) {
        // ignore: avoid_print
        print('Request to $uri timed out: $te');
        rethrow;
      }

      final clientSecret = jsonDecode(response.body)['clientSecret'];

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Client secret was not received from the server.');
      }

      // 2. Initialize and present Stripe's secure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Thirikkale',
          setupIntentClientSecret: clientSecret,
          style: ThemeMode.system, // Or .dark / .light
        ),
      );

      if (!mounted) return;

      await Stripe.instance.presentPaymentSheet();

      // 3. On success, show a confirmation.
      SnackbarHelper.showSuccessSnackBar(context, "Card saved successfully!");
      // In a real app, you would now re-fetch the list of saved cards.

    } on StripeException catch (e) {
      // Handle errors from the Stripe SDK (e.g., user cancels)
      if (e.error.code != FailureCode.Canceled && mounted) {
        SnackbarHelper.showErrorSnackBar(context, e.error.message ?? "An unknown Stripe error occurred.");
      }
    } catch (e) {
      // Handle other errors (network, server, etc.)
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, "An error occurred: $e");
      }
    } finally {
      // Hide loading indicator on the button
      if (mounted) {
        setState(() {
          _isAddingCard = false;
        });
      }
    }
  }

  // --- The rest of your UI methods can remain for display purposes ---
  void _showCardDetailsBottomSheet(BuildContext context) {
    // ... (This function is unchanged)
    CardDetailsBottomSheet.show(
      context,
      cardNumber: '**** **** **** 4890',
      expiryDate: '12/24',
      cardHolderName: 'Olivia Bennett',
      isDefault: false,
      onSetAsDefault: () {
        setState(() => _defaultMethod = 'Card');
        SnackbarHelper.showSuccessSnackBar(context, 'Card set as default!');
      },
      onEdit: () {},
      onDelete: () {
        SnackbarHelper.showSuccessSnackBar(context, 'Payment method deleted.');
      },
    );
  }

  void _showCashPaymentDialog(BuildContext context) {
    // ... (This function is unchanged)
    CashPaymentBottomSheet.show(
      context,
      onConfirm: (isSetAsDefault) {
        if (isSetAsDefault) {
          setState(() => _defaultMethod = 'Cash');
          SnackbarHelper.showSuccessSnackBar(context, 'Cash set as default!');
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(AppDimensions.pageHorizontalPadding),
              child: Text('Payment methods', style: AppTextStyles.heading3),
            ),
            Expanded(
              child: Column(
                children: [
                  // --- HARDCODED UI TILES ---
                  PaymentMethodTile(
                    icon: Icons.credit_card,
                    title: 'Card',
                    subtitle: 'Visa •••• •••• •••• 4567',
                    isDefault: _defaultMethod == 'Card',
                    onTap: () => _showCardDetailsBottomSheet(context),
                  ),
                  PaymentMethodTile(
                    icon: Icons.money,
                    title: 'Cash',
                    isDefault: _defaultMethod == 'Cash',
                    isCash: true,
                    onTap: () => _showCashPaymentDialog(context),
                  ),
                  // -------------------------
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalPadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
                        // --- UPDATED onPressed ---
                        onPressed: _isAddingCard ? null : _handleAddNewCard,
                        child: _isAddingCard
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Card',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}