class SavedPaymentMethod {
  final String stripePaymentMethodId;
  final String brand;
  final String last4;
  final bool isDefault;

  SavedPaymentMethod({
    required this.stripePaymentMethodId,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });

  factory SavedPaymentMethod.fromJson(Map<String, dynamic> json) {
    return SavedPaymentMethod(
      stripePaymentMethodId: json['stripePaymentMethodId'] ?? '',
      brand: json['brand'] ?? 'Card',
      last4: json['last4'] ?? '••••',
      isDefault: json['isDefault'] ?? false,
    );
  }
}