import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_input_card.dart';
import 'package:thirikkale_rider/features/booking/widgets/plan_ride_btn_header.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class PlanYourRideScreen extends StatefulWidget {
  const PlanYourRideScreen({super.key});

  @override
  State<PlanYourRideScreen> createState() => _PlanYourRideScreenState();
}

class _PlanYourRideScreenState extends State<PlanYourRideScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pickupController.text = "Current Location";
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Plan your ride",
        showBackButton: true,
      ),
      body: Column(
        children: [
          PlanRideBtnHeader(
            onScheduleChanged: (schedule) {
              print('Schedule changed to: $schedule');
            },
            onRideTypeChanged: (rideType) {
              print('Ride type changed to: $rideType');
            },
          ),

          LocationInputCard(
            pickupController: _pickupController,
            destinationController: _destinationController,
            onDestinationChanged: (value) {
              print('Destination changed: $value');
            },
            onPickupChanged: (value) {
              print('Pickup changed: $value');
            },
          ),

          const Divider(height: 1, color: AppColors.lightGrey,),

          // Future content area
          const Expanded(
            child: Center(
              child: Text('Location suggestions will appear here'),
            ),
          ),
        ],
      ),
    );
  }
}
