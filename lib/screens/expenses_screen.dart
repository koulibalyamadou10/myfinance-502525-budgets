import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:myfinance/widgets/transaction_form.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:myfinance/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  _ExpensesScreenState createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _selectedFilter = 'all';
  final currencyFormatter = NumberFormat.currency(
    symbol: 'GNF ',
    decimalDigits: 0,
  );

  String _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.needs:
        return '🏠'; // Home/Needs
      case ExpenseCategory.wants:
        return '🎮'; // Entertainment/Wants
      case ExpenseCategory.savings:
        return '💰'; // Savings
      default:
        return '📊'; // Default
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.needs:
        return AppTheme.categoryColors['needs']!;
      case ExpenseCategory.wants:
        return AppTheme.categoryColors['wants']!;
      case ExpenseCategory.savings:
        return AppTheme.categoryColors['savings']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final expenseTransactions = provider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        // Filter transactions based on selected filter
        if (_selectedFilter == 'month') {
          final now = DateTime.now();
          expenseTransactions.removeWhere(
            (t) => t.date.month != now.month || t.date.year != now.year,
          );
        }

        // Group transactions by category
        final groupedExpenses = <ExpenseCategory, List<Transaction>>{};
        for (var category in ExpenseCategory.values) {
          groupedExpenses[category] = expenseTransactions
              .where((t) => t.category == category)
              .toList();
        }

        return Column(
          children: [
            // Filter Section
            Padding(
              padding: EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'month', label: Text('Month')),
                  ButtonSegment(value: 'category', label: Text('Category')),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),

            // Expenses List
            Expanded(
              child: expenseTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No expenses yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddExpenseDialog(context),
                            child: Text('Add Expense'),
                          ),
                        ],
                      ),
                    )
                  : _selectedFilter == 'category'
                      ? ListView.builder(
                          itemCount: ExpenseCategory.values.length,
                          itemBuilder: (context, index) {
                            final category = ExpenseCategory.values[index];
                            final transactions = groupedExpenses[category] ?? [];
                            if (transactions.isEmpty) return SizedBox.shrink();

                            final totalAmount = transactions.fold<double>(
                              0,
                              (sum, t) => sum + t.amount,
                            );

                            return ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                                child: Text(_getCategoryIcon(category)),
                              ),
                              title: Text(
                                category.toString().split('.').last,
                                style: TextStyle(
                                  color: _getCategoryColor(category),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                currencyFormatter.format(totalAmount),
                              ),
                              children: transactions.map((transaction) {
                                return _buildExpenseListItem(
                                  context,
                                  transaction,
                                  provider,
                                );
                              }).toList(),
                            );
                          },
                        )
                      : ListView.builder(
                          itemCount: expenseTransactions.length,
                          itemBuilder: (context, index) {
                            return _buildExpenseListItem(
                              context,
                              expenseTransactions[index],
                              provider,
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseListItem(
    BuildContext context,
    Transaction transaction,
    FinanceProvider provider,
  ) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Expense'),
            content: Text('Are you sure you want to delete this expense?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        provider.deleteTransaction(transaction.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                provider.addTransaction(transaction);
              },
            ),
          ),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(transaction.category!).withOpacity(0.1),
          child: Text(_getCategoryIcon(transaction.category!)),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          '${transaction.category.toString().split('.').last} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
        ),
        trailing: Text(
          currencyFormatter.format(transaction.amount),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () => _showAddExpenseDialog(
          context,
          transaction: transaction,
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, {Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: TransactionForm(
            type: TransactionType.expense,
            transaction: transaction,
          ),
        ),
      ),
    );
  }
}
