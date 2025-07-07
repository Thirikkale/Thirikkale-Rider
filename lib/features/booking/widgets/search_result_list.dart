import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_list_tile.dart';

class SearchResultList extends StatelessWidget {
  final List<Map<String, dynamic>> predictions;
  final Function(Map<String, dynamic>) onLocationSelected;

  const SearchResultList({
    super.key,
    required this.predictions,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final prediction = predictions[index];
        final mainText = prediction['structured_formatting']?['main_text'] ?? '';
        final secondaryText = prediction['structured_formatting']?['secondary_text'] ?? '';

        // Extract distance information
        final distanceInfo = prediction['distance_info'] as Map<String, dynamic>?;
        final distanceText = distanceInfo?['distance_text'] as String?;
        
        return LocationListTile(
          icon: Icons.location_on,
          title: mainText,
          subtitle: secondaryText.isNotEmpty ? secondaryText : null,
          distance: distanceText,
          onTap: () => onLocationSelected(prediction),
        );
      },
    );
  }
}
