class ContactAccessModel {
  final bool freeContacts;
  final int fee;

  const ContactAccessModel({required this.freeContacts, required this.fee});

  factory ContactAccessModel.fromJson(Map<String, dynamic> json) =>
      ContactAccessModel(
        freeContacts: json['free_contacts'] as bool? ?? false,
        fee: json['fee'] as int? ?? 30000,
      );
}

class ContactUnlockResultModel {
  final bool charged;
  final bool free;
  final int fee;
  final int? balance;
  final String phone;
  final String? additionalContact;

  const ContactUnlockResultModel({
    required this.charged,
    required this.free,
    required this.fee,
    this.balance,
    required this.phone,
    this.additionalContact,
  });

  factory ContactUnlockResultModel.fromJson(Map<String, dynamic> json) =>
      ContactUnlockResultModel(
        charged: json['charged'] as bool? ?? false,
        free: json['free'] as bool? ?? false,
        fee: json['fee'] as int? ?? 0,
        balance: json['balance'] as int?,
        phone: json['phone'] as String? ?? '',
        additionalContact: json['additional_contact'] as String?,
      );
}

class ContactUnlockHistoryModel {
  final int id;
  final int anketaId;
  final int? vacancyId;
  final String trigger;
  final int amount;
  final String unlockedAt;

  const ContactUnlockHistoryModel({
    required this.id,
    required this.anketaId,
    this.vacancyId,
    required this.trigger,
    required this.amount,
    required this.unlockedAt,
  });

  factory ContactUnlockHistoryModel.fromJson(Map<String, dynamic> json) =>
      ContactUnlockHistoryModel(
        id: json['id'] as int,
        anketaId: json['anketa_id'] as int,
        vacancyId: json['vacancy_id'] as int?,
        trigger: json['trigger'] as String? ?? 'phone_view',
        amount: json['amount'] as int? ?? 0,
        unlockedAt: json['unlocked_at'] as String? ?? '',
      );

  bool get isFree => amount == 0;
}
