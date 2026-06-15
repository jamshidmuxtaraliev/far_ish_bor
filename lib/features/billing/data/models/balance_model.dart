/// Groups thousands with spaces and appends the UZS unit, e.g. 100000 -> "100 000 so'm".
String formatSom(int amount) {
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(' ');
    buf.write(digits[i]);
  }
  return "${amount < 0 ? '-' : ''}$buf so'm";
}

int parseAmount(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse('${v ?? 0}') ?? 0;
}

class BalanceModel {
  final int balance;
  final int totalTopup;
  final int totalSpent;

  // Seeker-only blacklist fields (spec §6). Empty/false for employers.
  final bool isBlacklisted;
  final String? blacklistReason;
  final String? blacklistedAt;
  final int blacklistFee;

  const BalanceModel({
    this.balance = 0,
    this.totalTopup = 0,
    this.totalSpent = 0,
    this.isBlacklisted = false,
    this.blacklistReason,
    this.blacklistedAt,
    this.blacklistFee = 0,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      balance: parseAmount(json['balance']),
      totalTopup: parseAmount(json['total_topup']),
      totalSpent: parseAmount(json['total_spent']),
      isBlacklisted: json['is_blacklisted'] as bool? ?? false,
      blacklistReason: json['blacklist_reason'] as String?,
      blacklistedAt: json['blacklisted_at'] as String?,
      blacklistFee: parseAmount(json['blacklist_fee']),
    );
  }

  String get balanceDisplay => formatSom(balance);
  String get totalTopupDisplay => formatSom(totalTopup);
  String get totalSpentDisplay => formatSom(totalSpent);
  String get blacklistFeeDisplay => formatSom(blacklistFee);
}
