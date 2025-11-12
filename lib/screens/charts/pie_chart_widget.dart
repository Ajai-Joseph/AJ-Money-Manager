import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data_model.dart';

/// Widget for displaying expense distribution as a pie chart
class PieChartWidget extends StatefulWidget {
  final List<CategoryData> categoryData;

  const PieChartWidget({
    super.key,
    required this.categoryData,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.categoryData.isEmpty
          ? const Center(
              child: Text('No data available'),
            )
          : PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex = pieTouchResponse
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieChartSections(),
              ),
            ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return List.generate(widget.categoryData.length, (index) {
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 70.0 : 60.0;
      final widgetSize = isTouched ? 55.0 : 45.0;

      final data = widget.categoryData[index];

      return PieChartSectionData(
        color: data.color,
        value: data.amount,
        title: '${data.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Colors.black26,
              blurRadius: 2,
            ),
          ],
        ),
        badgeWidget: isTouched
            ? _buildBadge(
                data.category,
                data.color,
                widgetSize,
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildBadge(String label, Color color, double size) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(label),
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // Map common category names to icons
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('food') || categoryLower.contains('restaurant')) {
      return Icons.restaurant;
    } else if (categoryLower.contains('transport') || categoryLower.contains('travel')) {
      return Icons.directions_car;
    } else if (categoryLower.contains('shopping') || categoryLower.contains('clothes')) {
      return Icons.shopping_bag;
    } else if (categoryLower.contains('entertainment') || categoryLower.contains('movie')) {
      return Icons.movie;
    } else if (categoryLower.contains('health') || categoryLower.contains('medical')) {
      return Icons.local_hospital;
    } else if (categoryLower.contains('education') || categoryLower.contains('book')) {
      return Icons.school;
    } else if (categoryLower.contains('bill') || categoryLower.contains('utility')) {
      return Icons.receipt;
    } else if (categoryLower.contains('rent') || categoryLower.contains('house')) {
      return Icons.home;
    } else if (categoryLower.contains('gift')) {
      return Icons.card_giftcard;
    } else if (categoryLower.contains('phone') || categoryLower.contains('internet')) {
      return Icons.phone_android;
    } else {
      return Icons.category;
    }
  }
}
