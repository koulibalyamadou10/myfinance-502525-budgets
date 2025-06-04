import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:myfinance/widgets/transaction_form.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:intl/intl.dart';

class IncomeScreen extends StatefulWidget {
  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  String _selectedFilter = 'all';
  final currencyFormatter = NumberFormat.currency(
    symbol: 'GNF ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final incomeTransactions = provider.transactions
            .where((t) => t.type == TransactionType.income)
            .toList();

        return Column(
          children: [
            // Filter Section
            Padding(
              padding: EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'all', label: Text('All')),
                  ButtonSegment(value: 'month', label: Text('Month')),
                  ButtonSegment(value: 'category', label: Text('Source')),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedFilter = newSelection.first;
                  });
                },
              ),
            ),

            // Income List
            Expanded(
              child: incomeTransactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No income transactions yet',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _showAddIncomeDialog(context),
                            child: Text('Add Income'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: incomeTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = incomeTransactions[index];
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
                                title: Text('Delete Income'),
                                content: Text('Are you sure you want to delete this income?'),
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
                                content: Text('Income deleted'),
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
                              backgroundColor: Colors.green.withOpacity(0.1),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text(
                              '${transaction.source} • ${DateFormat('MMM dd, yyyy').format(transaction.date)}',
                            ),
                            trailing: Text(
                              currencyFormatter.format(transaction.amount),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () => _showAddIncomeDialog(
                              context,
                              transaction: transaction,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showAddIncomeDialog(BuildContext context, {Transaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: TransactionForm(
            type: TransactionType.income,
            transaction: transaction,
          ),
        ),
      ),
    );
  }
}
