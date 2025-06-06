import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String password;

  @HiveField(3)
  int credit;

  @HiveField(4)
  List<String> collection;

  @HiveField(5)
  List<String> favoriteCards;

  User({
    required this.id,
    required this.username,
    required this.password,
    this.credit = 30000,
    List<String>? collection,
    List<String>? favoriteCards,
  }) : collection = collection ?? [],
       favoriteCards = favoriteCards ?? [];
}
