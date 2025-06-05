import 'package:hive/hive.dart';

part 'card.g.dart';

@HiveType(typeId: 1)
class GachaCard {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String urlImg;

  @HiveField(2)
  final int rarity;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final String coordinates; // Format: "lat,long"

  @HiveField(5)
  final DateTime time;

  GachaCard({
    required this.id,
    required this.urlImg,
    required this.rarity,
    required this.name,
    required this.coordinates,
    required this.time,
  });
}
