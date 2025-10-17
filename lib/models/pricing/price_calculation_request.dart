class PriceCalculationRequest {
  final String vehicleType;
  final double distanceKm;
  final double waitingTimeMin;

  PriceCalculationRequest({
    required this.vehicleType,
    required this.distanceKm,
    required this.waitingTimeMin,
  });

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': vehicleType,
      'distanceKm': distanceKm,
      'waitingTimeMin': waitingTimeMin,
    };
  }
}
