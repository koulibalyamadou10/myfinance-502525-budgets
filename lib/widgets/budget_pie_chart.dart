import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:myfinance/providers/finance_provider.dart';
import 'package:myfinance/theme/app_theme.dart';

class BudgetPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, provider, _) {
        final needsPercentage = provider.needsPercentage;
        final wantsPercentage = provider.wantsPercentage;
        final savingsPercentage = provider.savingsPercentage;

        return Column(
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      value: needsPercentage,
                      title: '${needsPercentage.toStringAsFixed(1)}%',
                      color: AppTheme.categoryColors['needs'],
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: wantsPercentage,
                      title: '${wantsPercentage.toStringAsFixed(1)}%',
                      color: AppTheme.categoryColors['wants'],
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: savingsPercentage,
                      title: '${savingsPercentage.toStringAsFixed(1)}%',
                      color: AppTheme.categoryColors['savings'],
                      radius: 100,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  context,
                  'Needs (50%)',
                  AppTheme.categoryColors['needs']!,
                  needsPercentage,
                ),
                _buildLegendItem(
                  context,
                  'Wants (25%)',
                  AppTheme.categoryColors['wants']!,
                  wantsPercentage,
                ),
                _buildLegendItem(
                  context,
                  'Savings (25%)',
                  AppTheme.categoryColors['savings']!,
                  savingsPercentage,
                ),
              ],
            ),
            // Alerts for overspending
            if (needsPercentage > 50 || wantsPercentage > 25 || savingsPercentage < 25)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: _buildAlert(
                  needsPercentage,
                  wantsPercentage,
                  savingsPercentage,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    double percentage,
  ) {
    final isOverBudget = (label.contains('Needs') && percentage > 50) ||
        (label.contains('Wants') && percentage > 25) ||
        (label.contains('Savings') && percentage < 25);

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isOverBudget ? Colors.red : null,
                fontWeight: isOverBudget ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOverBudget ? Colors.red : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAlert(
    double needsPercentage,
    double wantsPercentage,
    double savingsPercentage,
  ) {
    List<String> alerts = [];

    if (needsPercentage > 50) {
      alerts.add('Needs spending exceeds 50% target');
    }
    if (wantsPercentage > 25) {
      alerts.add('Wants spending exceeds 25% target');
    }
    if (savingsPercentage < 25) {
      alerts.add('Savings below 25% target');
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: alerts.map((alert) {
          return Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
