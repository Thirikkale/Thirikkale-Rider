import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_reservation_screen.dart';

class PickupTimeScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final String? initialRideType;

  const PickupTimeScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.initialRideType,
  });

  @override
  State<PickupTimeScreen> createState() => _PickupTimeScreenState();
}

class _PickupTimeScreenState extends State<PickupTimeScreen> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppbarName(
        title: 'Pickup time',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Selection Header
                    Text(
                      'Select a pickup date',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),

                    // Month/Year Navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (selectedMonth == 1) {
                                selectedMonth = 12;
                                selectedYear--;
                              } else {
                                selectedMonth--;
                              }
                            });
                          },
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          _getMonthYearString(),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (selectedMonth == 12) {
                                selectedMonth = 1;
                                selectedYear++;
                              } else {
                                selectedMonth++;
                              }
                            });
                          },
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.widgetSpacing),

                    // Calendar Grid
                    _buildCalendarGrid(),
                    const SizedBox(height: AppDimensions.sectionSpacing),

                    // Time Selection Header
                    Text(
                      'Select a pickup time',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.widgetSpacing),

                    // Time Selection
                    _buildTimeSelection(),
                    
                    const SizedBox(height: AppDimensions.sectionSpacing),
                  ],
                ),
              ),
            ),
          ),
          
          // Fixed bottom button
          Container(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: _confirmPickupTime,
                  child: const Text('Confirm'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(selectedYear, selectedMonth, 1);
    final lastDayOfMonth = DateTime(selectedYear, selectedMonth + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => Text(
                      day,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar days
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 32, height: 32);
                  }

                  final isSelected = selectedDate.day == dayNumber &&
                      selectedDate.month == selectedMonth &&
                      selectedDate.year == selectedYear;

                  final isToday = DateTime.now().day == dayNumber &&
                      DateTime.now().month == selectedMonth &&
                      DateTime.now().year == selectedYear;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = DateTime(selectedYear, selectedMonth, dayNumber);
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primaryBlue 
                            : isToday 
                                ? AppColors.primaryBlue.withOpacity(0.2)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          dayNumber.toString(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected 
                                ? AppColors.white 
                                : isToday 
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                            fontWeight: isSelected || isToday 
                                ? FontWeight.w600 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeSelection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Time display section
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Selected Time',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedHour.toString().padLeft(2, '0'),
                      style: AppTextStyles.heading1.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      ':',
                      style: AppTextStyles.heading1.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      selectedMinute.toString().padLeft(2, '0'),
                      style: AppTextStyles.heading1.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppDimensions.widgetSpacing),
          
          // Wheel pickers section
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 120,
              child: Row(
                children: [
                  // Hour picker
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Hour',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedHour,
                            ),
                            itemExtent: 28,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                selectedHour = index;
                              });
                            },
                            children: List.generate(24, (index) {
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Minute picker
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'Minute',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMinute,
                            ),
                            itemExtent: 28,
                            onSelectedItemChanged: (int index) {
                              setState(() {
                                selectedMinute = index;
                              });
                            },
                            children: List.generate(60, (index) {
                              return Center(
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthYearString() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[selectedMonth - 1]} $selectedYear';
  }

  void _confirmPickupTime() {
    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedHour,
      selectedMinute,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideReservationScreen(
          pickupAddress: widget.pickupAddress,
          destinationAddress: widget.destinationAddress,
          pickupLat: widget.pickupLat,
          pickupLng: widget.pickupLng,
          destLat: widget.destLat,
          destLng: widget.destLng,
          scheduledDateTime: scheduledDateTime,
          rideType: widget.initialRideType,
        ),
      ),
    );
  }
}
