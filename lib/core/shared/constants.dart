import 'package:hive/hive.dart';

part 'constants.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
enum Category {
  @HiveField(0)
  food,
  @HiveField(1)
  travel,
  @HiveField(2)
  bills,
  @HiveField(3)
  shopping,
  @HiveField(4)
  entertainment,
  @HiveField(5)
  health,
  @HiveField(6)
  other,
}
