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
