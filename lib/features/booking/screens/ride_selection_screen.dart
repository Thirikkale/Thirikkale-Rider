import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_styles.dart';
import '../../../widgets/common/custom_appbar_name.dart';

class RideSelectionScreen extends StatefulWidget {
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;

  const RideSelectionScreen({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<RideSelectionScreen> createState() => _RideSelectionScreenState();
}

class _RideSelectionScreenState extends State<RideSelectionScreen>
    with TickerProviderStateMixin {
  String selectedRideType = 'Solo';
  String selectedPaymentMethod = 'wallet';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> rideTypes = [
    {
      'type': 'Solo',
      'icon': Icons.person,
      'description': 'Private ride for you',
      'price': 150,
      'eta': '5-10 min',
    },
    {
      'type': 'Shared',
      'icon': Icons.group,
      'description': 'Share with others',
      'price': 75,
      'eta': '10-15 min',
    },
  ];

  final List<Map<String, dynamic>> paymentMethods = [
    {
      'id': 'wallet',
      'name': 'Wallet',
      'icon': Icons.account_balance_wallet,
      'balance': 450,
    },
    {
      'id': 'card',
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'last4': '2468',
    },
    {
      'id': 'cash',
      'name': 'Cash',
      'icon': Icons.money,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppbarName(title: 'Select Ride', showBackButton: true),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTripSummary(),
                    const SizedBox(height: 32),
                    _buildRideTypeSelection(),
                    const SizedBox(height: 32),
                    _buildPaymentMethodSelection(),
                    const SizedBox(height: 32),
                    _buildPriceBreakdown(),
                  ],
                ),
              ),
            ),
            _buildBookingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Summary',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.radio_button_checked,
                color: AppColors.primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.pickupLocation,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.dropoffLocation,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: AppColors.primaryBlue,
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                '${_formatDate(widget.selectedDate)} at ${widget.selectedTime.format(context)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Ride Type',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...rideTypes.map((rideType) => _buildRideTypeCard(rideType)),
      ],
    );
  }

  Widget _buildRideTypeCard(Map<String, dynamic> rideType) {
    final isSelected = selectedRideType == rideType['type'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              selectedRideType = rideType['type'];
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rideType['icon'],
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideType['type'],
                        style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        rideType['description'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        'ETA: ${rideType['eta']}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${rideType['price']}',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...paymentMethods.map((method) => _buildPaymentMethodCard(method)),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = selectedPaymentMethod == method['id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              selectedPaymentMethod = method['id'];
            });
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : AppColors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  method['icon'],
                  color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method['name'],
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                      if (method.containsKey('balance'))
                        Text(
                          'Balance: ₹${method['balance']}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      if (method.containsKey('last4'))
                        Text(
                          '**** **** **** ${method['last4']}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.radio_button_checked,
                    color: AppColors.primaryBlue,
                    size: 20,
                  )
                else
                  Icon(
                    Icons.radio_button_unchecked,
                    color: AppColors.grey,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final selectedRide = rideTypes.firstWhere((ride) => ride['type'] == selectedRideType);
    final basePrice = selectedRide['price'] as int;
    const platformFee = 10;
    const taxes = 15;
    final totalPrice = basePrice + platformFee + taxes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Base Fare', '₹$basePrice'),
          _buildPriceRow('Platform Fee', '₹$platformFee'),
          _buildPriceRow('Taxes & Fees', '₹$taxes'),
          Divider(color: AppColors.grey.withOpacity(0.3)),
          _buildPriceRow(
            'Total',
            '₹$totalPrice',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal 
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  )
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _bookRide,
            style: AppButtonStyles.primaryButton,
            child: const Text('Book Ride'),
          ),
        ),
      ),
    );
  }

  void _bookRide() {
    HapticFeedback.mediumImpact();
    
    // Show booking confirmation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Booking Confirmed!',
          style: AppTextStyles.heading2.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ride has been booked successfully.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: TR${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Type: $selectedRideType',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    'Time: ${_formatDate(widget.selectedDate)} at ${widget.selectedTime.format(context)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: AppButtonStyles.primaryButton,
            child: const Text('Track Ride'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate == today) {
      return 'Today';
    } else if (selectedDate == tomorrow) {
      return 'Tomorrow';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}
