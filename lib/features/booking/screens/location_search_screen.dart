import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class LocationSearchScreen extends StatefulWidget {
  final String title;
  final String initialText;
  final String hintText;
  final bool isPickup;

  const LocationSearchScreen({
    super.key,
    required this.title,
    this.initialText = '',
    this.hintText = 'Search for a location',
    this.isPickup = false,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialText;
    
    // Auto focus and show keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted && query.isNotEmpty) {
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );
        locationProvider.searchPlaces(query);
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    Navigator.pop(context, location);
  }

  void _selectCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    
    if (locationProvider.currentLocation != null) {
      final currentLocationData = {
        'description': locationProvider.currentLocationAddress,
        'place_id': 'current_location',
        'geometry': {
          'location': {
            'lat': locationProvider.currentLatitude,
            'lng': locationProvider.currentLongitude,
          }
        }
      };
      _selectLocation(currentLocationData);
    }
  }

  void _navigateToMapSelection() {
    Navigator.pop(context, {'use_map': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(
        title: widget.title,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search Input
          Container(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.lightGrey,
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.widgetSpacing,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
              ),
            ),
          ),

          // Content
          Expanded(
            child: Consumer<LocationProvider>(
              builder: (context, locationProvider, child) {
                if (_searchController.text.isEmpty) {
                  return _buildDefaultOptions();
                } else if (_isSearching && locationProvider.isSearchingPlaces) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (locationProvider.placePredictions.isNotEmpty) {
                  return _buildSearchResults(locationProvider.placePredictions);
                } else if (_searchController.text.isNotEmpty) {
                  return _buildNoResults();
                } else {
                  return _buildDefaultOptions();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultOptions() {
    final options = <Widget>[
      // Current Location (only for pickup)
      if (widget.isPickup)
        _buildLocationOption(
          icon: Icons.my_location,
          title: 'Current Location',
          subtitle: 'Use my current location',
          onTap: _selectCurrentLocation,
        ),

      // Nearby Places
      _buildLocationOption(
        icon: Icons.place,
        title: 'Maharagama',
        subtitle: '2.2 mi',
        onTap: () => _selectLocation({
          'description': 'Maharagama',
          'place_id': 'maharagama_default',
        }),
      ),

      _buildLocationOption(
        icon: Icons.shopping_bag,
        title: 'One Galle Face Mall',
        subtitle: '11 mi • 1A, Centre Rd, Colombo',
        onTap: () => _selectLocation({
          'description': 'One Galle Face Mall, 1A, Centre Rd, Colombo',
          'place_id': 'one_galle_face_mall',
        }),
      ),

      // Set location on map
      _buildLocationOption(
        icon: Icons.map,
        title: 'Set Location on map',
        subtitle: null,
        onTap: _navigateToMapSelection,
      ),

      // Saved places
      _buildLocationOption(
        icon: Icons.bookmark_outline,
        title: 'Saved places',
        subtitle: null,
        onTap: () {
          // TODO: Navigate to saved places
        },
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: options.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.lightGrey,
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (context, index) => options[index],
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.lightGrey,
        thickness: 1,
        height: 1,
      ),
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildLocationOption(
          icon: Icons.place,
          title: result['structured_formatting']?['main_text'] ?? 
                 result['description'] ?? 
                 'Unknown Location',
          subtitle: result['structured_formatting']?['secondary_text'] ?? 
                   result['description'] ?? 
                   '',
          onTap: () => _selectLocation(result),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppDimensions.widgetSpacing),
          Text(
            'No results found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.widgetSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
