import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/chart_data_model.dart';
import '../../config/theme/app_colors.dart';

/// Bar chart widget for displaying monthly income vs expense comparison
class BarChartWidget extends StatefulWidget {
  final List<MonthlyData> monthlyData;

  const BarChartWidget({
    super.key,
    required this.monthlyData,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedGroupIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
      child: Column(
        children: [
          // Legend
          _buildLegend(),
          const SizedBox(height: 24),
          
          // Chart
          Expanded(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  _buildBarChartData(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Income', AppColors.incomeColor),
        const SizedBox(width: 24),
        _buildLegendItem('Expense', AppColors.expenseColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData() {
    final maxY = _calculateMaxY();
    
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      minY: 0,
      groupsSpace: 12,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black87,
          tooltipPadding: const EdgeInsets.all(8),
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final monthData = widget.monthlyData[groupIndex];
            final isIncome = rodIndex == 0;
            final amount = isIncome ? monthData.income : monthData.expense;
            final label = isIncome ? 'Income' : 'Expense';
            
            return BarTooltipItem(
              '$label\n₹${amount.toStringAsFixed(2)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              _touchedGroupIndex = null;
              return;
            }
            _touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _buildBottomTitles,
            reservedSize: 32,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: maxY / 5,
            getTitlesWidget: _buildLeftTitles,
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
            dashArray: [5, 5],
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
          left: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      barGroups: _buildBarGroups(),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(widget.monthlyData.length, (index) {
      final monthData = widget.monthlyData[index];
      final isTouched = index == _touchedGroupIndex;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          // Income bar (green)
          BarChartRodData(
            toY: monthData.income * _animation.value,
            color: AppColors.incomeColor,
            width: isTouched ? 18 : 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: Colors.grey[200],
            ),
          ),
          // Expense bar (red)
          BarChartRodData(
            toY: monthData.expense * _animation.value,
            color: AppColors.expenseColor,
            width: isTouched ? 18 : 14,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
        barsSpace: 4,
      );
    });
  }

  Widget _buildBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= widget.monthlyData.length) {
      return const SizedBox.shrink();
    }
    
    final monthData = widget.monthlyData[value.toInt()];
    final isTouched = value.toInt() == _touchedGroupIndex;
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        monthData.month,
        style: TextStyle(
          fontSize: isTouched ? 13 : 12,
          fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
          color: isTouched ? AppColors.primaryLight : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildLeftTitles(double value, TitleMeta meta) {
    if (value == 0) {
      return const SizedBox.shrink();
    }
    
    String text;
    if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}k';
    } else {
      text = value.toStringAsFixed(0);
    }
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  double _calculateMaxY() {
    if (widget.monthlyData.isEmpty) return 100;
    
    double maxValue = 0;
    for (var data in widget.monthlyData) {
      if (data.income > maxValue) maxValue = data.income;
      if (data.expense > maxValue) maxValue = data.expense;
    }
    
    // Add 20% padding to the top
    maxValue = maxValue * 1.2;
    
    // Round up to nearest nice number
    if (maxValue < 100) {
      return ((maxValue / 10).ceil() * 10).toDouble();
    } else if (maxValue < 1000) {
      return ((maxValue / 100).ceil() * 100).toDouble();
    } else {
      return ((maxValue / 1000).ceil() * 1000).toDouble();
    }
  }
}
