import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:myfinance/widgets/goal_form.dart';
import 'package:myfinance/models/goal.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatelessWidget {
  final currencyFormatter = NumberFormat.currency(
    symbol: 'GNF ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final goals = provider.goals;

        return Stack(
          children: [
            goals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No financial goals yet',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _showAddGoalDialog(context),
                          child: Text('Add Goal'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals[index];
                      return Dismissible(
                        key: Key(goal.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Goal'),
                              content: Text('Are you sure you want to delete this goal?'),
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
                          provider.deleteGoal(goal.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Goal deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  provider.addGoal(goal);
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: InkWell(
                            onTap: () => _showAddGoalDialog(context, goal: goal),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Goal Header
                                  Row(
                                    children: [
                                      Icon(
                                        _getGoalIcon(goal.iconName),
                                        size: 24,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          goal.title,
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ),
                                      if (goal.isCompleted)
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Progress Bar
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: goal.progress,
                                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            goal.isCompleted ? Colors.green : Theme.of(context).primaryColor,
                                          ),
                                          minHeight: 8,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${(goal.progress * 100).toStringAsFixed(1)}%',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: goal.isCompleted ? Colors.green : null,
                                            ),
                                          ),
                                          Text(
                                            '${currencyFormatter.format(goal.currentAmount)} / ${currencyFormatter.format(goal.targetAmount)}',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),

                                  // Goal Details
                                  if (goal.targetDate != null) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Target: ${DateFormat('MMM dd, yyyy').format(goal.targetDate!)}',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                  if (goal.notes != null && goal.notes!.isNotEmpty) ...[
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.note,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            goal.notes!,
                                            style: Theme.of(context).textTheme.bodySmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            
            // Add Goal Button
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _showAddGoalDialog(context),
                child: Icon(Icons.add),
                tooltip: 'Add Goal',
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getGoalIcon(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'home':
        return Icons.home;
      case 'car':
        return Icons.directions_car;
      case 'vacation':
        return Icons.beach_access;
      case 'education':
        return Icons.school;
      case 'electronics':
        return Icons.computer;
      default:
        return Icons.flag;
    }
  }

  void _showAddGoalDialog(BuildContext context, {FinancialGoal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: GoalForm(goal: goal),
        ),
      ),
    );
  }
}
