import 'package:flutter/material.dart';
import 'package:myfinance/models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final TransactionType type;
  final Transaction? transaction; // For editing existing transaction

  const TransactionForm({
    Key? key,
    required this.type,
    this.transaction,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  ExpenseCategory? _selectedCategory;
  String? _selectedSource;

  final List<String> _incomeSources = [
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if editing
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedCategory = widget.transaction?.category;
    _selectedSource = widget.transaction?.source;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final amount = double.parse(_amountController.text);
    
    final transaction = Transaction(
      id: widget.transaction?.id ?? DateTime.now().toString(),
      description: _descriptionController.text,
      amount: amount,
      date: _selectedDate,
      type: widget.type,
      category: widget.type == TransactionType.expense ? _selectedCategory : null,
      source: widget.type == TransactionType.income ? _selectedSource : null,
    );

    try {
      if (widget.transaction == null) {
        // Adding new transaction
        provider.addTransaction(transaction);
      } else {
        // Updating existing transaction
        provider.updateTransaction(transaction);
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
            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Date Picker
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Date'),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(_selectedDate),
              ),
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 16),

            // Category/Source Dropdown
            if (widget.type == TransactionType.expense)
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              )
            else
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: InputDecoration(
                  labelText: 'Source',
                  prefixIcon: Icon(Icons.source),
                ),
                items: _incomeSources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSource = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a source';
                  }
                  return null;
                },
              ),
            SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                widget.transaction == null ? 'Add' : 'Update',
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
