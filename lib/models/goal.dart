import 'package:flutter/foundation.dart';

class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final String? notes;
  final String iconName;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
    this.targetDate,
    this.notes,
    required this.iconName,
  });

  double get progress => currentAmount / targetAmount;
  bool get isCompleted => currentAmount >= targetAmount;
  
  Duration? get remainingTime {
    if (targetDate == null) return null;
    return targetDate!.difference(DateTime.now());
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'notes': notes,
      'iconName': iconName,
    };
  }

  factory FinancialGoal.fromMap(Map<String, dynamic> map) {
    return FinancialGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      createdAt: DateTime.parse(map['createdAt']),
      targetDate: map['targetDate'] != null 
          ? DateTime.parse(map['targetDate'])
          : null,
      notes: map['notes'],
      iconName: map['iconName'],
    );
  }

  FinancialGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    String? notes,
    String? iconName,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      iconName: iconName ?? this.iconName,
    );
  }

  FinancialGoal addContribution(double amount) {
    return copyWith(
      currentAmount: currentAmount + amount,
    );
  }

  @override
  String toString() {
    return 'FinancialGoal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, progress: $progress, isCompleted: $isCompleted)';
  }
}
