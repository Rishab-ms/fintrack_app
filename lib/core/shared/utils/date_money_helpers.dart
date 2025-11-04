import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintrack_app/core/shared/constants.dart';

// Helper function to format currency
String formatCurrency(double amount) {
  final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  return format.format(amount);
}

// Helper function to format date
String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

// Extension on Category enum for display names and icons
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
        return Icons.local_hospital;
      case Category.other:
        return Icons.category;
    }
  }
}
