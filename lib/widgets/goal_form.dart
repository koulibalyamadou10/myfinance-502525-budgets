import 'package:flutter/material.dart';
import 'package:myfinance/models/goal.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:intl/intl.dart';

class GoalForm extends StatefulWidget {
  final FinancialGoal? goal; // For editing existing goal

  const GoalForm({
    Key? key,
    this.goal,
  }) : super(key: key);

  @override
  _GoalFormState createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  late TextEditingController _notesController;
  DateTime? _targetDate;
  String _selectedIcon = 'savings'; // Default icon

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'savings', 'icon': Icons.savings},
    {'name': 'home', 'icon': Icons.home},
    {'name': 'car', 'icon': Icons.directions_car},
    {'name': 'vacation', 'icon': Icons.beach_access},
    {'name': 'education', 'icon': Icons.school},
    {'name': 'electronics', 'icon': Icons.computer},
    {'name': 'other', 'icon': Icons.flag},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing
    _titleController = TextEditingController(
      text: widget.goal?.title ?? '',
    );
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount.toString() ?? '',
    );
    _currentAmountController = TextEditingController(
      text: widget.goal?.currentAmount.toString() ?? '0',
    );
    _notesController = TextEditingController(
      text: widget.goal?.notes ?? '',
    );
    _targetDate = widget.goal?.targetDate;
    _selectedIcon = widget.goal?.iconName ?? 'savings';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    
    final goal = FinancialGoal(
      id: widget.goal?.id ?? DateTime.now().toString(),
      title: _titleController.text,
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: double.parse(_currentAmountController.text),
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      targetDate: _targetDate,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      iconName: _selectedIcon,
    );

    try {
      if (widget.goal == null) {
        // Adding new goal
        provider.addGoal(goal);
      } else {
        // Updating existing goal
        provider.updateGoal(goal);
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Goal Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Target Amount Field
            TextFormField(
              controller: _targetAmountController,
              decoration: InputDecoration(
                labelText: 'Target Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter target amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Current Amount Field
            TextFormField(
              controller: _currentAmountController,
              decoration: InputDecoration(
                labelText: 'Current Amount',
                prefixIcon: Icon(Icons.savings),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter current amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Target Date Picker
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Target Date (Optional)'),
              subtitle: Text(
                _targetDate != null 
                    ? DateFormat('MMM dd, yyyy').format(_targetDate!)
                    : 'Not set',
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),

            // Icon Selection
            DropdownButtonFormField<String>(
              value: _selectedIcon,
              decoration: InputDecoration(
                labelText: 'Icon',
                prefixIcon: Icon(_availableIcons
                    .firstWhere((item) => item['name'] == _selectedIcon)['icon']),
              ),
              items: _availableIcons.map((iconData) {
                return DropdownMenuItem(
                  value: iconData['name'],
                  child: Row(
                    children: [
                      Icon(iconData['icon']),
                      SizedBox(width: 8),
                      Text(iconData['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedIcon = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Notes Field
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                widget.goal == null ? 'Add Goal' : 'Update Goal',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
