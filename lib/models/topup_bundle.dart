import 'package:hive/hive.dart';

part 'topup_bundle.g.dart';

@HiveType(typeId: 2)
class TopUpBundle {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int credits;

  @HiveField(2)
  final double usdPrice;

  TopUpBundle({
    required this.id,
    required this.credits,
    required this.usdPrice,
  });
}
