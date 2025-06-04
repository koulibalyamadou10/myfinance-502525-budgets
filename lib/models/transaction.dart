import 'package:flutter/foundation.dart';

enum TransactionType {
  income,
  expense
}

enum ExpenseCategory {
  needs,
  wants,
  savings
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final ExpenseCategory? category; // null for income transactions
  final String? source; // for income transactions
  
  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    this.category,
    this.source,
  }) : assert(
    (type == TransactionType.income && source != null && category == null) ||
    (type == TransactionType.expense && category != null && source == null),
    'Income must have source, Expense must have category'
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'category': category?.toString(),
      'source': source,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == map['type'],
      ),
      category: map['category'] != null
          ? ExpenseCategory.values.firstWhere(
              (e) => e.toString() == map['category'],
            )
          : null,
      source: map['source'],
    );
  }

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    ExpenseCategory? category,
    String? source,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
      source: source ?? this.source,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, date: $date, type: $type, category: $category, source: $source)';
  }
}
