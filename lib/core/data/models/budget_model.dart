import 'package:hive/hive.dart';
import 'package:fintrack_app/core/shared/constants.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 3) // Assign unique Hive Type ID for Budget
class Budget extends HiveObject {
  @HiveField(0)
  final Category category;
  @HiveField(1)
  final double limit;

  Budget({required this.category, required this.limit});
}
