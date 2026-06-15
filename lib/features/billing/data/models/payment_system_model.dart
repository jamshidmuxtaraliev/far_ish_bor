class PaymentSystemModel {
  final int id;
  final String code; // payme | click | paynet
  final String name;
  final bool isTest;

  const PaymentSystemModel({
    required this.id,
    required this.code,
    required this.name,
    this.isTest = false,
  });

  factory PaymentSystemModel.fromJson(Map<String, dynamic> json) {
    return PaymentSystemModel(
      id: json['id'] as int? ?? 0,
      code: (json['code'] as String? ?? '').toLowerCase(),
      name: json['name'] as String? ?? '',
      isTest: json['is_test'] as bool? ?? false,
    );
  }
}
