import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';

class SavedLocationScreen extends StatefulWidget {
  final String type; // 'home' or 'work'
  const SavedLocationScreen({super.key, required this.type});

  @override
  State<SavedLocationScreen> createState() => _SavedLocationScreenState();
}

class _SavedLocationScreenState extends State<SavedLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  bool _saving = false;
  List<Map<String, dynamic>> _recentSearches = [];


  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  Future<void> _loadRecentSearches() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final searches = await locationProvider.getRecentSearchesWithFallback();
    if (mounted) {
      setState(() {
        _recentSearches = searches;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    if (query.isNotEmpty) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.searchPlaces(query);
    }
  }

  Future<void> _saveLocation(Map<String, dynamic> location) async {
    setState(() { _saving = true; });
    final prefs = await SharedPreferences.getInstance();
    final key = widget.type == 'work' ? 'work_location' : 'home_location';
    await prefs.setString(key, location['description'] ?? location['formatted_address'] ?? '');
    setState(() { _saving = false; });
    if (mounted) {
      SnackbarHelper.showSuccessSnackBar(
        context,
        '${widget.type[0].toUpperCase()}${widget.type.substring(1)} location set successfully!'
      );
      Navigator.pop(context, location);
    }
  }

  void _selectLocation(Map<String, dynamic> location) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.addToSearchHistory(location);
    await _saveLocation(location);
  }

  void _selectCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    if (locationProvider.currentLocation == null) {
      try {
        await locationProvider.getCurrentLocation();
      } catch (e) {
        if (!mounted) return;
        SnackbarHelper.showErrorSnackBar(
          context,
          'Unable to get current location. Please check permissions.'
        );
        return;
      }
    }
    if (locationProvider.currentLocation != null) {
      final currentLocationData = {
        'description': locationProvider.currentLocationAddress,
        'place_id': 'current_location',
        'geometry': {
          'location': {
            'lat': locationProvider.currentLocation?['latitude'],
            'lng': locationProvider.currentLocation?['longitude'],
          }
        }
      };
      _selectLocation(currentLocationData);
    } else {
      if (!mounted) return;
      SnackbarHelper.showErrorSnackBar(
        context,
        'Unable to get current location.'
      );
    }
  }

  Future<void> _selectOnMap() async {
    final LatLng? picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(type: widget.type),
      ),
    );
    if (picked != null) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final address = await locationProvider.reverseGeocode(picked.latitude, picked.longitude);
      final mapLocation = {
        'description': address,
        'place_id': 'map_selected',
        'geometry': {
          'location': {
            'lat': picked.latitude,
            'lng': picked.longitude,
          }
        }
      };
      _selectLocation(mapLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'work' ? 'Set work location' : 'Set home location';
    return Scaffold(
      appBar: CustomAppbarName(title: title, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSubheader(title: 'Search'),
            TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for your ${widget.type} address',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.subtleGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  if (_searchController.text.isEmpty) {
                    return _buildDefaultOptions();
                  } else if (_isSearching && locationProvider.isSearchingPlaces) {
                    return const Center(child: CircularProgressIndicator());
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
            if (_saving) const LinearProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultOptions() {
    final options = <Widget>[
      _buildLocationOption(
        icon: Icons.my_location,
        title: 'Current Location',
        subtitle: 'Use my current location',
        onTap: _selectCurrentLocation,
      ),
      if (_recentSearches.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.history, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text('Recent searches', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
            ],
          ),
        ),
        ..._recentSearches.map((search) => _buildLocationOption(
          icon: Icons.history,
          title: search['structured_formatting']?['main_text'] ?? search['description'] ?? 'Unknown Location',
          subtitle: search['structured_formatting']?['secondary_text'] ?? 'Recent search',
          onTap: () => _selectLocation(search),
        )),
      ],
      _buildLocationOption(
        icon: Icons.map,
        title: 'Set Location on map',
        subtitle: null,
        onTap: _selectOnMap,
      ),
    ];
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.lightGrey, thickness: 1, height: 1),
      itemBuilder: (context, index) => options[index],
    );
  }

  Widget _buildSearchResults(List<Map<String, dynamic>> results) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(color: AppColors.lightGrey, thickness: 1, height: 1),
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildLocationOption(
          icon: Icons.place,
          title: result['structured_formatting']?['main_text'] ?? result['description'] ?? 'Unknown Location',
          subtitle: result['structured_formatting']?['secondary_text'] ?? result['description'] ?? '',
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
          Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppDimensions.widgetSpacing),
          Text('No results found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          SizedBox(height: 8),
          Text('Try a different search term', style: TextStyle(color: AppColors.textSecondary)),
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
              child: Icon(icon, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(width: AppDimensions.widgetSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
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

class MapPickerScreen extends StatefulWidget {
  final String type;
  const MapPickerScreen({super.key, required this.type});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _pickedLatLng;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Pick on Map', showBackButton: true),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(9.9312, 76.2673), // Default to Kochi
              zoom: 15,
            ),
            onMapCreated: (controller) {},
            onTap: (latLng) {
              setState(() {
                _pickedLatLng = latLng;
              });
            },
            markers: _pickedLatLng != null
                ? {
                    Marker(
                      markerId: const MarkerId('picked'),
                      position: _pickedLatLng!,
                    ),
                  }
                : {},
          ),
          if (_pickedLatLng != null)
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(milliseconds: 500));
                        if (mounted) {
                          Navigator.pop(context, _pickedLatLng);
                        }
                        setState(() => _loading = false);
                      },
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Set this location'),
              ),
            ),
        ],
      ),
    );
  }
}
