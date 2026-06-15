import 'balance_model.dart';

class PremiumTariffModel {
  final int id;
  final String code;
  final String name;
  final int currentPrice;
  final int? durationDays;

  const PremiumTariffModel({
    required this.id,
    this.code = '',
    this.name = '',
    this.currentPrice = 0,
    this.durationDays,
  });

  factory PremiumTariffModel.fromJson(Map<String, dynamic> json) {
    return PremiumTariffModel(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      currentPrice: parseAmount(json['current_price']),
      durationDays: json['duration_days'] as int?,
    );
  }

  String get priceDisplay => formatSom(currentPrice);
  String get durationDisplay => durationDays != null ? '$durationDays kun' : '';
}
