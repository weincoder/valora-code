import '../../models/additional_cost/additional_cost.dart';

class CalculateProductPriceUseCase {
  double execute({
    required double hourlyRate,
    required double estimatedHours,
    required List<AdditionalCost> additionalCosts,
  }) {
    final laborCost = hourlyRate * estimatedHours;
    final extraCosts = additionalCosts.fold(0.0, (sum, c) => sum + c.amount);
    return laborCost + extraCosts;
  }
}
