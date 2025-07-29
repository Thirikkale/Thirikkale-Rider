class VehicleOption {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final double defaultPricePerUnit;
  final String estimatedTime;
  final int capacity;
  final List<String> features;


  VehicleOption({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.defaultPricePerUnit,
    required this.estimatedTime,
    required this.capacity,
    this.features = const [],
  });

  static List<VehicleOption> getDefaultOptions() {
    return [
      VehicleOption(
        id: 'tuk',
        name: 'Tuk',
        description: 'Affordable rides for everyday trips',
        iconAsset: 'assets/icons/vehicles/tuk.png',
        defaultPricePerUnit: 130.0,
        estimatedTime: '16:30 - 3 min away',
        capacity: 3,
        features: ['Affordable', 'Quick'],
      ),
      VehicleOption(
        id: 'ride',
        name: 'Ride',
        description: 'Comfortable and reliable rides',
        iconAsset: 'assets/icons/vehicles/ride.png',
        defaultPricePerUnit: 150.0,
        estimatedTime: '16:00 - 10 min away',
        capacity: 4,
        features: ['Comfortable', 'AC'],
      ),
      VehicleOption(
        id: 'rush',
        name: 'Rush',
        description: 'Fast and efficient transportation',
        iconAsset: 'assets/icons/vehicles/rush.png',
        defaultPricePerUnit: 110.0,
        estimatedTime: '15:00 - 5 min away',
        capacity: 2,
        features: ['Fast', 'Beat Traffic'],
      ),
      VehicleOption(
        id: 'prime',
        name: 'Prime Ride',
        description: 'Fast and efficient transportation',
        iconAsset: 'assets/icons/vehicles/primeRide.png',
        defaultPricePerUnit: 180.0,
        estimatedTime: '15:00 - 5 min away',
        capacity: 4,
        features: ['AC', 'More comfortable'],
      ),
      VehicleOption(
        id: 'squad',
        name: 'Squad',
        description: 'Group ride for up to 6',
        iconAsset: 'assets/icons/vehicles/squad.png',
        defaultPricePerUnit: 300.0,
        estimatedTime: '16:45 - 15 min away',
        capacity: 6,
        features: ['Group', 'Spacious'],
      ),
    ];
  }
}