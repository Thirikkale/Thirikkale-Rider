import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
// import 'package:thirikkale_rider/features/account/screens/payment_methods/add_payment_method_screen.dart'; // No longer needed
import 'package:thirikkale_rider/features/account/widgets/cash_payment_bottomsheet.dart';
import 'package:thirikkale_rider/features/account/widgets/payment_method_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/card_details_bottom_sheet.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/config/api_config.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/models/saved_payment_method.dart'; // Ensure this model exists

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // --- STATE VARIABLES ---
  String _defaultMethod = 'Cash'; // Will be updated based on fetched cards or Cash selection
  bool _isLoadingCards = true; // For loading the list of cards
  bool _isSavingCard = false; // For the 'Add Card' button loading state
  List<SavedPaymentMethod> _savedCards = []; // List to hold fetched cards
  // -------------------------

  @override
  void initState() {
    super.initState();
    // Fetch the saved cards when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSavedCards();
    });
  }

  // --- FETCH SAVED CARDS ---
  Future<void> _fetchSavedCards() async {
    if (!mounted) return; // Ensure widget is still mounted
    setState(() {
      _isLoadingCards = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getCurrentToken();
      final riderId = authProvider.userId;

      if (riderId == null || token == null) {
        throw Exception('User not logged in');
      }

      final response = await http.get(
        Uri.parse(RiderEndpoints.getSavedCards(riderId)),
        headers: ApiConfig.getAuthHeaders(token),
      );

      if (!mounted) return; // Check again after await

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final cards = jsonList
            .map((json) => SavedPaymentMethod.fromJson(json))
            .toList();

        SavedPaymentMethod? defaultCard;
        try {
          // Try to find the card explicitly marked as default
          defaultCard = cards.firstWhere((card) => card.isDefault);
        } catch (e) {
          // If no card is marked as default, firstWhere throws an error.
          // In this case, if there are cards, we can assign the first one as default conceptually,
          // but for setting the _defaultMethod string, we handle it below.
          defaultCard = null; 
        }

        setState(() {
          _savedCards = cards;
          if (defaultCard != null) {
            _defaultMethod = defaultCard.stripePaymentMethodId; // Use unique ID as identifier
          } else {
             _defaultMethod = 'Cash'; // If no cards, default back to cash
          }
        });
      } else {
        throw Exception('Failed to load cards: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, "Error fetching cards: $e");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCards = false;
        });
      }
    }
  }

  // --- HANDLE SAVING A NEW CARD ---
  Future<void> _handleSaveCard() async {
    if (_isSavingCard) return; // Prevent double taps

    setState(() {
      _isSavingCard = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = await authProvider.getCurrentToken();
      final riderId = authProvider.userId;

      if (riderId == null || token == null) {
        throw Exception('User session invalid. Please log in again.');
      }

      // 1. Call your backend to get the clientSecret
      final response = await http.post(
        Uri.parse(RiderEndpoints.saveCard),
        headers: ApiConfig.getAuthHeaders(token),
        body: jsonEncode({'riderId': int.parse(riderId)}), // Ensure riderId is sent as integer
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create setup intent: ${response.statusCode} ${response.body}');
      }

      final responseBody = jsonDecode(response.body);
      final clientSecret = responseBody['clientSecret'];

      if (clientSecret == null) {
        throw Exception('Client secret not received from server.');
      }

      // 2. Initialize and Present the Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Thirikkale',
          setupIntentClientSecret: clientSecret,
          style: ThemeMode.dark, // Or ThemeMode.light / ThemeMode.system
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 3. Handle Success: Show snackbar and refresh the list of cards
      SnackbarHelper.showSuccessSnackBar(context, "Success! Card saved.");
      await _fetchSavedCards(); // Refresh the list

    } on StripeException catch (e) {
      if (e.error.code != FailureCode.Canceled) {
        SnackbarHelper.showErrorSnackBar(
            context, "Failed to save card: ${e.error.message ?? 'Unknown Stripe error'}");
      }
      // If user cancelled, do nothing.
    } catch (e) {
      SnackbarHelper.showErrorSnackBar(context, "An error occurred: $e");
    } finally {
      if (mounted) { // Check if widget is still mounted before calling setState
        setState(() {
          _isSavingCard = false;
        });
      }
    }
  }

  // --- SHOW DETAILS FOR A SAVED CARD ---
  void _showCardDetailsBottomSheet(BuildContext context, SavedPaymentMethod card) {
    CardDetailsBottomSheet.show(
      context,
      cardNumber: '**** **** **** ${card.last4}',
      expiryDate: '••/••', // Expiry isn't typically available, keep hidden or omit
      cardHolderName: card.brand.toUpperCase(), // Display brand (e.g., VISA)
      isDefault: card.isDefault,
      onSetAsDefault: () async {
        // --- TODO: Implement Backend Call to Set Default Card ---
        // 1. Call your backend endpoint: PUT /api/payments/methods/{stripePaymentMethodId}/set-default
        // 2. Pass the riderId and the card.stripePaymentMethodId
        // 3. On success from backend:
        setState(() {
          _defaultMethod = card.stripePaymentMethodId; // Update UI immediately
        });
        await _fetchSavedCards(); // Refresh list to confirm default status change
        SnackbarHelper.showSuccessSnackBar(
          context,
          '${card.brand} card set as default!',
        );
        // 4. On failure from backend: show error snackbar
        // --- End TODO ---
      },
      onEdit: () {
        // Editing usually requires re-entering details via Stripe, similar to adding a new card.
        // You might just prompt the user to delete and re-add.
        SnackbarHelper.showInfoSnackBar(context, "Editing requires re-adding the card.");
      },
      onDelete: () async {
        // --- TODO: Implement Backend Call to Delete Card ---
        // 1. Show a confirmation dialog first.
        // 2. Call your backend endpoint: DELETE /api/payments/methods/{stripePaymentMethodId}
        // 3. Pass the riderId and the card.stripePaymentMethodId
        // 4. On success from backend:
        await _fetchSavedCards(); // Refresh the list
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Payment method deleted successfully',
        );
        // 5. On failure from backend: show error snackbar
        // --- End TODO ---
      },
    );
  }

  // --- SHOW CASH PAYMENT DIALOG ---
  void _showCashPaymentDialog(BuildContext context) {
    CashPaymentBottomSheet.show(
      context,
      onConfirm: (isSetAsDefault) {
        if (isSetAsDefault) {
          // --- TODO: If needed, tell backend Cash is now default ---
          // Although usually, the default is implicitly the last used or explicitly set card.
          // You might not need a backend call here unless you store the default preference server-side.
          setState(() {
            _defaultMethod = 'Cash';
          });
          SnackbarHelper.showSuccessSnackBar(
            context,
            'Cash set as default payment method!',
          );
          // Refresh list to potentially update card default status visually
          _fetchSavedCards();
           // --- End TODO ---
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
                  // --- DYNAMIC CARD LIST ---
                  _isLoadingCards
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          // Build a list tile for each saved card
                          children: _savedCards.map((card) {
                            return PaymentMethodTile(
                              icon: Icons.credit_card, // You could map card.brand to specific icons
                              title: card.brand.toUpperCase(),
                              subtitle: '•••• •••• •••• ${card.last4}',
                              isDefault: _defaultMethod == card.stripePaymentMethodId, // Compare with the unique ID
                              onTap: () {
                                _showCardDetailsBottomSheet(context, card);
                              },
                            );
                          }).toList(),
                        ),
                  // -------------------------

                  // --- CASH OPTION ---
                  PaymentMethodTile(
                    icon: Icons.money,
                    title: 'Cash',
                    isDefault: _defaultMethod == 'Cash',
                    isCash: true,
                    onTap: () {
                      _showCashPaymentDialog(context);
                    },
                  ),
                  // -------------------

                  const Spacer(), // Pushes the button to the bottom

                  // --- ADD CARD BUTTON ---
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalPadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: AppButtonStyles.primaryButton,
                        // Disable button while loading, call _handleSaveCard when pressed
                        onPressed: _isSavingCard ? null : _handleSaveCard,
                        child: _isSavingCard
                            ? const SizedBox( // Constrain indicator size
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
                  // ---------------------
                  const SizedBox(height: 18), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}