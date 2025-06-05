import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
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

  User({
    required this.id,
    required this.username,
    required this.password,
    this.credit = 30000,
    this.collection = const [],
  });
}
