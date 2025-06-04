import 'package:flutter/foundation.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:myfinance/models/goal.dart';
import 'package:myfinance/services/database_service.dart';

class FinanceProvider with ChangeNotifier {
  final DatabaseService _db;
  List<Transaction> _transactions = [];
  List<FinancialGoal> _goals = [];
  
  // Cached calculations
  double _totalBalance = 0;
  Map<ExpenseCategory, double> _expensesByCategory = {};
  
  FinanceProvider(String userId) : _db = DatabaseService(userId: userId) {
    _initializeData();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  List<FinancialGoal> get goals => _goals;
  double get totalBalance => _totalBalance;
  Map<ExpenseCategory, double> get expensesByCategory => _expensesByCategory;

  // Get expenses for each category (50/25/25 rule)
  double get needsExpenses => _expensesByCategory[ExpenseCategory.needs] ?? 0;
  double get wantsExpenses => _expensesByCategory[ExpenseCategory.wants] ?? 0;
  double get savingsAmount => _expensesByCategory[ExpenseCategory.savings] ?? 0;

  // Calculate percentages for the 50/25/25 rule
  double get needsPercentage => _calculatePercentage(needsExpenses);
  double get wantsPercentage => _calculatePercentage(wantsExpenses);
  double get savingsPercentage => _calculatePercentage(savingsAmount);

  // Initialize data
  Future<void> _initializeData() async {
    await Future.wait([
      _loadTransactions(),
      _loadGoals(),
    ]);
    _updateCalculations();
  }

  // Load transactions from database
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _db.getTransactions();
      notifyListeners();
    } catch (e) {
      print('Error loading transactions: $e');
    }
  }

  // Load goals from database
  Future<void> _loadGoals() async {
    try {
      _goals = await _db.getGoals();
      notifyListeners();
    } catch (e) {
      print('Error loading goals: $e');
    }
  }

  // Update cached calculations
  void _updateCalculations() {
    _calculateTotalBalance();
    _calculateExpensesByCategory();
    notifyListeners();
  }

  // Calculate total balance
  void _calculateTotalBalance() {
    _totalBalance = _transactions.fold(0, (sum, transaction) {
      if (transaction.type == TransactionType.income) {
        return sum + transaction.amount;
      } else {
        return sum - transaction.amount;
      }
    });
  }

  // Calculate expenses by category
  void _calculateExpensesByCategory() {
    final Map<ExpenseCategory, double> expenses = {};
    
    for (var category in ExpenseCategory.values) {
      expenses[category] = _transactions
          .where((t) => 
              t.type == TransactionType.expense && 
              t.category == category)
          .fold(0, (sum, t) => sum + t.amount);
    }
    
    _expensesByCategory = expenses;
  }

  // Calculate percentage of total income
  double _calculatePercentage(double amount) {
    final totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    if (totalIncome == 0) return 0;
    return (amount / totalIncome) * 100;
  }

  // Add new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final id = await _db.addTransaction(transaction);
      _transactions.add(transaction.copyWith(id: id));
      _updateCalculations();
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }

  // Update existing transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _db.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _updateCalculations();
      }
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }

  // Delete transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _db.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      _updateCalculations();
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }

  // Add new goal
  Future<void> addGoal(FinancialGoal goal) async {
    try {
      final id = await _db.addGoal(goal);
      _goals.add(goal.copyWith(id: id));
      notifyListeners();
    } catch (e) {
      print('Error adding goal: $e');
      rethrow;
    }
  }

  // Update existing goal
  Future<void> updateGoal(FinancialGoal goal) async {
    try {
      await _db.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating goal: $e');
      rethrow;
    }
  }

  // Delete goal
  Future<void> deleteGoal(String goalId) async {
    try {
      await _db.deleteGoal(goalId);
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
    } catch (e) {
      print('Error deleting goal: $e');
      rethrow;
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await _initializeData();
  }
}
