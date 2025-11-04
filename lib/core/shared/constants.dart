import 'package:flutter/material.dart';
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

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.food:
        return 'Food';
      case Category.travel:
        return 'Travel';
      case Category.bills:
        return 'Bills';
      case Category.shopping:
        return 'Shopping';
      case Category.entertainment:
        return 'Entertainment';
      case Category.health:
        return 'Health';
      case Category.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.fastfood;
      case Category.travel:
        return Icons.flight;
      case Category.bills:
        return Icons.receipt;
      case Category.shopping:
        return Icons.shopping_cart;
      case Category.entertainment:
        return Icons.movie;
      case Category.health:
        return Icons.health_and_safety;
      case Category.other:
        return Icons.category;
    }
  }
}
