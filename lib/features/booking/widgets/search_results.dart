import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/features/booking/widgets/default_suggestions.dart';
import 'package:thirikkale_rider/features/booking/widgets/search_error.dart';
import 'package:thirikkale_rider/features/booking/widgets/search_loading.dart';
import 'package:thirikkale_rider/features/booking/widgets/search_result_list.dart';

class SearchResults extends StatelessWidget {
  final LocationProvider locationProvider;
  final Function(Map<String, dynamic>) onLocationSelected;
  final VoidCallback onRetryLocation;
  final String destinationQuery;

  const SearchResults({
    super.key,
    required this.locationProvider,
    required this.onLocationSelected,
    required this.onRetryLocation,
    required this.destinationQuery,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading indicator during search
    if (locationProvider.isSearchingPlaces) {
      return const SearchLoading();
    }

    // Show search error if any
    if (locationProvider.searchError != null) {
      return SearchError(
        error: locationProvider.searchError!,
        onRetry: () {
          if (destinationQuery.isNotEmpty) {
            locationProvider.searchPlaces(destinationQuery);
          }
        },
      );
    }

    // Show search results
    if (locationProvider.placePredictions.isNotEmpty) {
      return SearchResultList(
        predictions: locationProvider.placePredictions,
        onLocationSelected: onLocationSelected,
      );
    }

    // Show default suggestions
    return DefaultSuggestions(
      locationProvider: locationProvider,
      onRetryLocation: onRetryLocation,
    );
  }
}
