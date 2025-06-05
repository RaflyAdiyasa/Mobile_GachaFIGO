import 'package:hive/hive.dart';

part 'currency_rate.g.dart';

@HiveType(typeId: 3)
class CurrencyRate {
  @HiveField(0)
  final String code; // USD, EUR, JPY

  @HiveField(1)
  final double marketRate;

  @HiveField(2)
  final double buyRate;

  @HiveField(3)
  final double sellRate;

  CurrencyRate({
    required this.code,
    required this.marketRate,
    required this.buyRate,
    required this.sellRate,
  });
}
