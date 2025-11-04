import 'package:hive/hive.dart';
import 'package:fintrack_app/core/shared/constants.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 2) // Assign unique Hive Type ID for Transaction
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final TransactionType type;
  @HiveField(4)
  final String? description;
  @HiveField(5)
  final Category? category;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
    this.category,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    DateTime? date,
    TransactionType? type,
    String? description,
    Category? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      category: category ?? this.category,
    );
  }
}
