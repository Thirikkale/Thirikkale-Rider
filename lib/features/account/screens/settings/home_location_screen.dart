import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';

class HomeLocationScreen extends StatefulWidget {
  const HomeLocationScreen({super.key});

  @override
  State<HomeLocationScreen> createState() => _HomeLocationScreenState();
}


class _HomeLocationScreenState extends State<HomeLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;
  List<Map<String, dynamic>> _recentSearches = [];
  bool _saving = false;

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

  Future<void> _saveHomeLocation(Map<String, dynamic> location) async {
    setState(() { _saving = true; });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('home_location', location['description'] ?? location['formatted_address'] ?? '');
    setState(() { _saving = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Home location set successfully!')),
      );
      Navigator.pop(context, location);
    }
  }

  void _selectLocation(Map<String, dynamic> location) async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    await locationProvider.addToSearchHistory(location);
    await _saveHomeLocation(location);
  }

  void _selectCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
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
    }
  }

  void _navigateToMapSelection() {
    // For demo, just pop with a dummy address
    final mapLocation = {
      'description': 'Selected Address from Map: 456 Oak Avenue, Springfield, IL 62701',
      'place_id': 'map_selected',
    };
    _selectLocation(mapLocation);
  }

  // dispose already defined above for _searchController and _searchFocus

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Set home location",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSubheader(title: 'Search'),
            TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              autofocus: true,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for your home address',
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
        onTap: _navigateToMapSelection,
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
