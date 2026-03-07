class PricingService {
  static double calculateTotal({
    required double ritualDakshina,
    required double samagriTotal,
    double deliveryFee = 0,
    double platformFee = 0,
  }) {
    return ritualDakshina + samagriTotal + deliveryFee + platformFee;
  }
}
