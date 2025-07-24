import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/booking/widgets/custom_header_button.dart';
import 'package:thirikkale_rider/features/booking/widgets/ride_type_popup.dart';
import 'package:thirikkale_rider/features/booking/widgets/schedule_popup.dart';

class PlanRideBtnHeader extends StatefulWidget {
  final Function(String)? onScheduleChanged;
  final Function(String)? onRideTypeChanged;
  final String? initialSchedule;
  final String? initialRideType;

  const PlanRideBtnHeader({
    super.key,
    this.onScheduleChanged,
    this.onRideTypeChanged,
    this.initialSchedule,
    this.initialRideType,
  });

  @override
  State<PlanRideBtnHeader> createState() => _PlanRideBtnHeaderState();
}

class _PlanRideBtnHeaderState extends State<PlanRideBtnHeader> {
  late String selectedSchedule;
  late String selectedRideType;

  @override
  void initState() {
    super.initState();
    selectedSchedule = widget.initialRideType ?? 'Now';
    selectedRideType = widget.initialRideType ?? 'Solo';
  }

  void _showSchedulePopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SchedulePopup(
        currentSelection: selectedSchedule,
        onSelectionChanged: (selection) {
          setState(() {
            selectedSchedule = selection;
          });
          widget.onScheduleChanged?.call(selection);
        },
      ),
    );
  }

  void _showRideTypePopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RideTypePopup(
        currentSelection: selectedRideType,
        onSelectionChanged: (selection) {
          setState(() {
            selectedRideType = selection;
          });
          widget.onRideTypeChanged?.call(selection);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppDimensions.pageHorizontalPadding,
        right: AppDimensions.pageHorizontalPadding,
        top: 12,
      ),
      child: Row(
        children: [
          CustomHeaderButton(
            icon: _getScheduleIcon(),
            text: selectedSchedule,
            onTap: _showSchedulePopup,
          ),
          const SizedBox(width: 12),
          CustomHeaderButton(
            icon: _getRideTypeIcon(),
            text: selectedRideType,
            onTap: _showRideTypePopup,
          ),
          const Spacer(),
          // You can add more buttons here in the future
        ],
      ),
    );
  }


  IconData _getScheduleIcon() {
    switch (selectedSchedule) {
      case 'Pickup Now':
      case 'Now':
        return Icons.access_time;
      case 'Schedule Later':
        return Icons.schedule;
      default:
        return Icons.access_time;
    }
  }

  IconData _getRideTypeIcon() {
    switch (selectedRideType) {
      case 'Solo':
        return Icons.person;
      case 'Shared':
        return Icons.people;
      default:
        return Icons.person;
    }
  }
}
