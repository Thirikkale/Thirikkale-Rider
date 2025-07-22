import 'package:thirikkale_rider/models/user_enums.dart';

class UserModel {
  // Main user fields
  final String? userId;
  final String phoneNumber;
  final String firstName;
  final String? lastName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? profilePhotoUrl;
  final bool isActive;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Rider-specific fields (flattened into the main model)
  final Gender? gender;
  final bool genderVerified;
  final DateTime? lastRideDate;
  final PaymentMethod? preferredPaymentMethod;
  final double? rating;
  final String? selfieUrl;
  final int totalRides;
  final bool womenOnlyAccess;

  UserModel({
    this.userId,
    required this.phoneNumber,
    required this.firstName,
    this.lastName,
    this.email,
    this.dateOfBirth,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.profilePhotoUrl,
    this.isActive = true,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    // Rider fields
    this.gender,
    this.genderVerified = false,
    this.lastRideDate,
    this.preferredPaymentMethod,
    this.rating,
    this.selfieUrl,
    this.totalRides = 0,
    this.womenOnlyAccess = false,
  });

  // From JSON (handles both user and rider data in single response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // User fields
      userId: json['userId'] ?? json['user_id'],
      phoneNumber: json['phoneNumber'] ?? json['phone_number'] ?? '',
      firstName: json['firstName'] ?? json['first_name'] ?? '',
      lastName: json['lastName'] ?? json['last_name'],
      email: json['email'],
      dateOfBirth: json['dateOfBirth'] != null || json['date_of_birth'] != null
          ? DateTime.parse(json['dateOfBirth'] ?? json['date_of_birth'])
          : null,
      emergencyContactName: json['emergencyContactName'] ?? json['emergency_contact_name'],
      emergencyContactPhone: json['emergencyContactPhone'] ?? json['emergency_contact_phone'],
      profilePhotoUrl: json['profilePhotoUrl'] ?? json['profile_photo_url'],
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      isEmailVerified: json['isEmailVerified'] ?? json['is_email_verified'] ?? false,
      isPhoneVerified: json['isPhoneVerified'] ?? json['is_phone_verified'] ?? false,
      lastLoginAt: json['lastLoginAt'] != null || json['last_login_at'] != null
          ? DateTime.parse(json['lastLoginAt'] ?? json['last_login_at'])
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : null,
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
      
      // Rider fields
      gender: _parseGender(json['gender']),
      genderVerified: json['genderVerified'] ?? json['gender_verified'] ?? false,
      lastRideDate: json['lastRideDate'] != null || json['last_ride_date'] != null
          ? DateTime.parse(json['lastRideDate'] ?? json['last_ride_date'])
          : null,
      preferredPaymentMethod: _parsePaymentMethod(json['preferredPaymentMethod'] ?? json['preferred_payment_method']),
      rating: (json['rating'] as num?)?.toDouble(),
      selfieUrl: json['selfieUrl'] ?? json['selfie_url'],
      totalRides: json['totalRides'] ?? json['total_rides'] ?? 0,
      womenOnlyAccess: json['womenOnlyAccess'] ?? json['women_only_access'] ?? false,
    );
  }

  // To JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      // User fields
      'userId': userId,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'profilePhotoUrl': profilePhotoUrl,
      'isActive': isActive,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      
      // Rider fields
      'gender': gender?.name,
      'genderVerified': genderVerified,
      'lastRideDate': lastRideDate?.toIso8601String(),
      'preferredPaymentMethod': preferredPaymentMethod?.name,
      'rating': rating,
      'selfieUrl': selfieUrl,
      'totalRides': totalRides,
      'womenOnlyAccess': womenOnlyAccess,
    };
  }

  // For registration API call (only essential fields)
  Map<String, dynamic> toRegistrationJson() {
    return {
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'gender': gender?.name,
      'womenOnlyAccess': womenOnlyAccess,
    };
  }

  // Business logic methods
  String get fullName {
    if (firstName.isNotEmpty && lastName != null && lastName!.isNotEmpty) {
      return '$firstName $lastName';
    }
    return firstName;
  }

  String get displayName => fullName.isNotEmpty ? fullName : phoneNumber;

  bool get isProfileComplete =>
      firstName.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty &&
      email != null &&
      email!.isNotEmpty;

  bool get isGenderVerificationRequired => 
      womenOnlyAccess && !genderVerified;

  String get ratingDisplay => rating != null ? rating!.toStringAsFixed(1) : 'No rating';

  bool get isNewRider => totalRides == 0;

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    final age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      return age - 1;
    }
    return age;
  }

  // Copy with method
  UserModel copyWith({
    String? userId,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? profilePhotoUrl,
    bool? isActive,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Gender? gender,
    bool? genderVerified,
    DateTime? lastRideDate,
    PaymentMethod? preferredPaymentMethod,
    double? rating,
    String? selfieUrl,
    int? totalRides,
    bool? womenOnlyAccess,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      isActive: isActive ?? this.isActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      gender: gender ?? this.gender,
      genderVerified: genderVerified ?? this.genderVerified,
      lastRideDate: lastRideDate ?? this.lastRideDate,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      rating: rating ?? this.rating,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      totalRides: totalRides ?? this.totalRides,
      womenOnlyAccess: womenOnlyAccess ?? this.womenOnlyAccess,
    );
  }

  // Helper methods for parsing
  static Gender? _parseGender(String? genderString) {
    switch (genderString?.toUpperCase()) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      case 'OTHER':
        return Gender.other;
      case 'NOT_SPECIFIED':
        return Gender.notSpecified;
      default:
        return null;
    }
  }

  static PaymentMethod? _parsePaymentMethod(String? paymentString) {
    switch (paymentString?.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      case 'digital_wallet':
        return PaymentMethod.digitalWallet;
      default:
        return null;
    }
  }
}