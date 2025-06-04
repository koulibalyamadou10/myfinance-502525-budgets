import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:myfinance/widgets/balance_card.dart';
import 'package:myfinance/widgets/budget_pie_chart.dart';
import 'package:myfinance/widgets/transaction_form.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:myfinance/screens/income_screen.dart';
import 'package:myfinance/screens/expenses_screen.dart';
import 'package:myfinance/screens/goals_screen.dart';
import 'package:myfinance/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _screens = [
    _DashboardContent(),
    IncomeScreen(),
    ExpensesScreen(),
    GoalsScreen(),
  ];

  void _showAddTransactionDialog(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: TransactionForm(type: type),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Dashboard' : 
                    _currentIndex == 1 ? 'Income' :
                    _currentIndex == 2 ? 'Expenses' : 'Goals'),
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                Provider.of<FinanceProvider>(context, listen: false).refreshData();
              },
            ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'profile',
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'settings',
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                value: 'logout',
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await _authService.signOut();
                Navigator.of(context).pushReplacementNamed('/auth');
              }
              // TODO: Handle other menu items
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Income',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'Goals',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'addIncome',
                  onPressed: () => _showAddTransactionDialog(
                    context,
                    TransactionType.income,
                  ),
                  child: Icon(Icons.add),
                  backgroundColor: Colors.green,
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: 'addExpense',
                  onPressed: () => _showAddTransactionDialog(
                    context,
                    TransactionType.expense,
                  ),
                  child: Icon(Icons.remove),
                  backgroundColor: Colors.red,
                ),
              ],
            )
          : null,
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<FinanceProvider>(context, listen: false).refreshData();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(),
            SizedBox(height: 24),
            Text(
              'Budget Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            BudgetPieChart(),
            SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle,
                    label: 'Add Income',
                    color: Colors.green,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          child: TransactionForm(type: TransactionType.income),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.remove_circle,
                    label: 'Add Expense',
                    color: Colors.red,
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: SingleChildScrollView(
                          child: TransactionForm(type: TransactionType.expense),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
