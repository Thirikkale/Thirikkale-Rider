class Ride {
  final String id;
  final String userId;
  final String? driverId;
  final String pickupLocation;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffLocation;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final String rideType;
  final String status;
  final String requestTime;
  final String? scheduledTime;
  final String? pickupTime;
  final String? dropoffTime;
  final double estimatedFare;
  final double? actualFare;
  final String paymentStatus;
  final int passengerCount;
  final String? specialRequests;
  final bool isSharedRide;
  final double estimatedDistance;
  final String? driverName;
  final String? driverPhone;
  final String? vehicleDetails;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? rating;
  final String? feedback;

  Ride({
    required this.id,
    required this.userId,
    this.driverId,
    required this.pickupLocation,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffLocation,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.rideType,
    required this.status,
    required this.requestTime,
    this.scheduledTime,
    this.pickupTime,
    this.dropoffTime,
    required this.estimatedFare,
    this.actualFare,
    required this.paymentStatus,
    required this.passengerCount,
    this.specialRequests,
    required this.isSharedRide,
    required this.estimatedDistance,
    this.driverName,
    this.driverPhone,
    this.vehicleDetails,
    this.currentLatitude,
    this.currentLongitude,
    this.rating,
    this.feedback,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      userId: json['userId'],
      driverId: json['driverId'],
      pickupLocation: json['pickupLocation'],
      pickupLatitude: json['pickupLatitude'],
      pickupLongitude: json['pickupLongitude'],
      dropoffLocation: json['dropoffLocation'],
      dropoffLatitude: json['dropoffLatitude'],
      dropoffLongitude: json['dropoffLongitude'],
      rideType: json['rideType'],
      status: json['status'],
      requestTime: json['requestTime'],
      scheduledTime: json['scheduledTime'],
      pickupTime: json['pickupTime'],
      dropoffTime: json['dropoffTime'],
      estimatedFare: json['estimatedFare'],
      actualFare: json['actualFare'],
      paymentStatus: json['paymentStatus'],
      passengerCount: json['passengerCount'],
      specialRequests: json['specialRequests'],
      isSharedRide: json['isSharedRide'] ?? false,
      estimatedDistance: (json['estimatedDistance'] as num).toDouble(),
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      vehicleDetails: json['vehicleDetails'],
      currentLatitude: json['currentLatitude'],
      currentLongitude: json['currentLongitude'],
      rating: json['rating'],
      feedback: json['feedback'],
    );
  }
}
