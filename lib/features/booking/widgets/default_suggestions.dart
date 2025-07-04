import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_error_card.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_list_tile.dart';

class DefaultSuggestions extends StatelessWidget {
  final LocationProvider locationProvider;
  final VoidCallback onRetryLocation;

  const DefaultSuggestions({
    super.key,
    required this.locationProvider,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const SuggestionsHeader(),

        // Show location error if any
        LocationErrorCard(
          locationProvider: locationProvider,
          onRetryLocation: onRetryLocation,
        ),

        // Default suggestions
        const SuggestionsList(),
      ],
    );
  }
}

class SuggestionsHeader extends StatelessWidget {
  const SuggestionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Suggestions',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class SuggestionsList extends StatelessWidget {
  const SuggestionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationListTile(
          icon: Icons.home_outlined,
          title: 'Home',
          subtitle: 'Add Home',
          onTap: () {
            // TODO: Handle home selection
            print('Home tapped');
          },
        ),
        LocationListTile(
          icon: Icons.work_outline,
          title: 'Work',
          subtitle: 'Add Work',
          onTap: () {
            // TODO: Handle work selection
            print('Work tapped');
          },
        ),
        LocationListTile(
          icon: Icons.map_outlined,
          title: 'Set Location on map',
          onTap: () {
            // TODO: Handle map selection
            print('Set location on map tapped');
          },
        ),
        LocationListTile(
          icon: Icons.history,
          title: 'Recent searches',
          onTap: () {
            // TODO: Handle recent searches
            print('Recent searches tapped');
          },
        ),
      ],
    );
  }
}
