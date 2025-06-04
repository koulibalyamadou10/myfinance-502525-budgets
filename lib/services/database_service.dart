import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:myfinance/models/goal.dart';

class DatabaseService {
  final String userId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DatabaseService({required this.userId});

  // Collection references
  CollectionReference get _transactionsRef => 
      _db.collection('users').doc(userId).collection('transactions');
  
  CollectionReference get _goalsRef => 
      _db.collection('users').doc(userId).collection('goals');

  // Transactions CRUD operations
  Future<List<Transaction>> getTransactions() async {
    try {
      final snapshot = await _transactionsRef
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => Transaction.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching transactions: $e');
    }
  }

  Stream<List<Transaction>> streamTransactions() {
    return _transactionsRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Future<String> addTransaction(Transaction transaction) async {
    try {
      final docRef = await _transactionsRef.add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionsRef
          .doc(transaction.id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _transactionsRef.doc(transactionId).delete();
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // Goals CRUD operations
  Future<List<FinancialGoal>> getGoals() async {
    try {
      final snapshot = await _goalsRef
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => FinancialGoal.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching goals: $e');
    }
  }

  Stream<List<FinancialGoal>> streamGoals() {
    return _goalsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialGoal.fromMap({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>
                }))
            .toList());
  }

  Future<String> addGoal(FinancialGoal goal) async {
    try {
      final docRef = await _goalsRef.add(goal.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    try {
      await _goalsRef
          .doc(goal.id)
          .update(goal.toMap());
    } catch (e) {
      throw Exception('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _goalsRef.doc(goalId).delete();
    } catch (e) {
      throw Exception('Error deleting goal: $e');
    }
  }

  // Analytics methods
  Future<Map<ExpenseCategory, double>> getExpensesByCategory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await _transactionsRef
          .where('type', isEqualTo: TransactionType.expense.toString())
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      final expenses = snapshot.docs
          .map((doc) => Transaction.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .where((transaction) => transaction.type == TransactionType.expense)
          .toList();

      return {
        for (var category in ExpenseCategory.values)
          category: expenses
              .where((expense) => expense.category == category)
              .fold(0, (sum, expense) => sum + expense.amount)
      };
    } catch (e) {
      throw Exception('Error fetching expenses by category: $e');
    }
  }

  Future<double> getTotalIncome(DateTime startDate, DateTime endDate) async {
    try {
      final snapshot = await _transactionsRef
          .where('type', isEqualTo: TransactionType.income.toString())
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .get();

      return snapshot.docs
          .map((doc) => Transaction.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>
              }))
          .fold(0, (sum, transaction) => sum + transaction.amount);
    } catch (e) {
      throw Exception('Error calculating total income: $e');
    }
  }
}
