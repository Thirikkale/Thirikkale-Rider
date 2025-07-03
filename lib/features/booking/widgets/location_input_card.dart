import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_connector.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_text_field.dart';

class LocationInputCard extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final ValueChanged<String> onDestinationChanged;
  final ValueChanged<String> onPickupChanged;
  final VoidCallback? onPickupTap;
  final bool autoFocus;

  const LocationInputCard({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.onDestinationChanged,
    required this.onPickupChanged,
    this.onPickupTap,
    this.autoFocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const LocationConnector(),
            
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                children: [
                  LocationTextField(
                    controller: pickupController,
                    hintText: 'Current Location',
                    prefixIcon: Icons.my_location,
                    onTap: onPickupTap,
                    onChanged: onPickupChanged,
                  ),

                  const SizedBox(height: 12),

                  LocationTextField(
                    controller: destinationController,
                    hintText: 'Where to?',
                    prefixIcon: Icons.location_on,
                    autoFocus: autoFocus,
                    onChanged: onDestinationChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
