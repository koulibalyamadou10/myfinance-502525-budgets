import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(
    symbol: 'GNF ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final balance = provider.totalBalance;
        final totalExpenses = provider.needsExpenses + 
                            provider.wantsExpenses + 
                            provider.savingsAmount;

        return Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(balance),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: balance >= 0 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            balance >= 0 
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: balance >= 0 ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 4),
                          Text(
                            balance >= 0 ? 'Positive' : 'Negative',
                            style: TextStyle(
                              color: balance >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                Divider(height: 32),
                
                // Expenses Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(totalExpenses),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    
                    // Expense Breakdown
                    _buildExpenseItem(
                      context,
                      'Needs',
                      provider.needsExpenses,
                      totalExpenses,
                      Colors.blue,
                    ),
                    SizedBox(height: 8),
                    _buildExpenseItem(
                      context,
                      'Wants',
                      provider.wantsExpenses,
                      totalExpenses,
                      Colors.purple,
                    ),
                    SizedBox(height: 8),
                    _buildExpenseItem(
                      context,
                      'Savings',
                      provider.savingsAmount,
                      totalExpenses,
                      Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpenseItem(
    BuildContext context,
    String label,
    double amount,
    double total,
    Color color,
  ) {
    final percentage = total > 0 ? (amount / total * 100) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              currencyFormatter.format(amount),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        SizedBox(height: 2),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
