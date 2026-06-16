class InvoiceModel {
  final int id;
  final String? tariffCode;
  final int seq;
  final String title;
  final int amount;
  final String dueStage;
  final String status;
  final String? paidAt;

  const InvoiceModel({
    required this.id,
    this.tariffCode,
    required this.seq,
    required this.title,
    required this.amount,
    required this.dueStage,
    required this.status,
    this.paidAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => InvoiceModel(
        id: json['id'] as int,
        tariffCode: json['tariff_code'] as String?,
        seq: json['seq'] as int? ?? 1,
        title: json['title'] as String? ?? '',
        amount: json['amount'] as int? ?? 0,
        dueStage: json['due_stage'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        paidAt: json['paid_at'] as String?,
      );

  bool get isPaid => status == 'paid';
}

class InvoiceListResponse {
  final List<InvoiceModel> items;
  final InvoiceModel? pending;

  const InvoiceListResponse({required this.items, this.pending});

  factory InvoiceListResponse.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => InvoiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final pendingJson = json['pending'] as Map<String, dynamic>?;
    return InvoiceListResponse(
      items: items,
      pending: pendingJson != null ? InvoiceModel.fromJson(pendingJson) : null,
    );
  }
}
