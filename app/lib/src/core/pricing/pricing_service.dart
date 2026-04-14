class PricingService {
  static double calculatePlatformFee({
    required double ritualDakshina,
    required double samagriTotal,
  }) {
    final double subtotal = ritualDakshina + samagriTotal;
    final double fee = subtotal * 0.03;
    final double roundedFee = fee.round().toDouble();
    // Ensure a minimum of ₹21 to cover base costs
    return roundedFee < 21 ? 21.0 : roundedFee;
  }

  static double calculateTotal({
    required double ritualDakshina,
    required double samagriTotal,
    double deliveryFee = 0,
    double platformFee = 0,
  }) {
    return ritualDakshina + samagriTotal + deliveryFee + platformFee;
  }
}
