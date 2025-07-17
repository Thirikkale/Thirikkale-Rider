import 'package:flutter/material.dart';
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
  TimeOfDay selectedTime = TimeOfDay.now();
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
      body: Padding(
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
            
            const Spacer(),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmPickupTime,
                child: Text(
                  'Confirm',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
          ],
        ),
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
          const SizedBox(height: AppDimensions.subSectionSpacingDown),

          // Calendar days
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          // Hour selection
          Expanded(
            child: Column(
              children: [
                Text(
                  selectedTime.hour.toString().padLeft(2, '0'),
                  style: AppTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Hour',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ':',
            style: AppTextStyles.heading1.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 32,
            ),
          ),
          // Minute selection
          Expanded(
            child: Column(
              children: [
                Text(
                  selectedTime.minute.toString().padLeft(2, '0'),
                  style: AppTextStyles.heading1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Minute',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.widgetSpacing),
          // AM/PM
          Column(
            children: [
              GestureDetector(
                onTap: () => _selectTime(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedTime.period == DayPeriod.am ? 'AM' : 'PM',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _confirmPickupTime() {
    final scheduledDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
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
