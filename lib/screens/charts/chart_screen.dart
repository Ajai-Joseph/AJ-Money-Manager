import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/category_model.dart';
import '../../models/chart_data_model.dart';
import '../../services/chart_service.dart';
import '../../config/theme/app_colors.dart';
import '../../db/category/category_db.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import 'pie_chart_widget.dart';
import 'bar_chart_widget.dart';

/// Screen for displaying chart visualizations of financial data
class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  String _selectedPeriod = 'Monthly';
  final List<String> _periods = ['Monthly', 'Quarterly', 'Yearly'];
  
  List<CategoryModel> _allTransactions = [];
  List<CategoryData> _categoryData = [];
  List<MonthlyData> _monthlyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoryDB = await Hive.openBox<CategoryModel>(CATEGORY_DB_NAME);
      _allTransactions = categoryDB.values.toList();
      
      _updateChartData();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Start fade animation after data loads
      _fadeAnimationController.forward();
    }
  }

  void _updateChartData() {
    // Get filtered transactions based on selected period
    final filteredTransactions = _getFilteredTransactions();
    
    // Update category data for pie chart
    _categoryData = ChartService.getCategoryDataWithColors(filteredTransactions);
    
    // Update monthly data for bar chart
    final months = _selectedPeriod == 'Monthly' ? 6 : 
                   _selectedPeriod == 'Quarterly' ? 3 : 12;
    _monthlyData = ChartService.getMonthlyComparisonData(filteredTransactions, months);
  }

  List<CategoryModel> _getFilteredTransactions() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'Monthly':
        // Last 6 months
        final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
        return _allTransactions.where((t) => t.dateTime.isAfter(sixMonthsAgo)).toList();
      
      case 'Quarterly':
        // Last 3 months
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        return _allTransactions.where((t) => t.dateTime.isAfter(threeMonthsAgo)).toList();
      
      case 'Yearly':
        // Last 12 months
        final twelveMonthsAgo = DateTime(now.year, now.month - 12, now.day);
        return _allTransactions.where((t) => t.dateTime.isAfter(twelveMonthsAgo)).toList();
      
      default:
        return _allTransactions;
    }
  }

  void _onPeriodChanged(String? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
        _updateChartData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          // Time period selector
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  items: _periods.map((String period) {
                    return DropdownMenuItem<String>(
                      value: period,
                      child: Text(
                        period,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _onPeriodChanged,
                  underline: const SizedBox(),
                  dropdownColor: AppColors.primaryLight,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Categories',
            ),
            Tab(
              icon: Icon(Icons.bar_chart),
              text: 'Comparison',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pie Chart Tab
                  _buildPieChartTab(),
                  // Bar Chart Tab
                  _buildBarChartTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const ChartShimmer(),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: LoadingShimmer(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartTab() {
    if (_categoryData.isEmpty) {
      return const EmptyChartState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Breakdown by category',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Pie Chart
          PieChartWidget(categoryData: _categoryData),
          
          const SizedBox(height: 32),
          
          // Data Summary Section
          _buildDataSummary(),
        ],
      ),
    );
  }

  Widget _buildBarChartTab() {
    if (_monthlyData.isEmpty) {
      return const EmptyChartState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart title
          Text(
            'Income vs Expense',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly comparison',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Bar Chart
          BarChartWidget(monthlyData: _monthlyData),
          
          const SizedBox(height: 32),
          
          // Monthly Summary
          _buildMonthlySummary(),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
    final totalExpense = _categoryData.fold<double>(
      0, 
      (sum, data) => sum + data.amount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Total expense card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.expenseGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '₹${totalExpense.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Category list with legend
        ..._categoryData.map((data) => _buildCategoryLegendItem(data)),
      ],
    );
  }

  Widget _buildCategoryLegendItem(CategoryData data) {
    return InkWell(
      onTap: () {
        _showCategoryDetails(data);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: data.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            
            // Category name
            Expanded(
              child: Text(
                data.category,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Percentage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.formattedPercentage,
                style: TextStyle(
                  color: data.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Amount
            Text(
              data.formattedAmount,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ..._monthlyData.map((data) => _buildMonthlyItem(data)),
      ],
    );
  }

  Widget _buildMonthlyItem(MonthlyData data) {
    final balance = data.income - data.expense;
    final isPositive = balance >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month name
          Text(
            data.month,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Income row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.incomeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Income',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Text(
                '₹${data.income.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.incomeColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Expense row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.expenseColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Expense',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Text(
                '₹${data.expense.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.expenseColor,
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),
          
          // Balance row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Balance',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isPositive 
                      ? AppColors.balancePositive 
                      : AppColors.balanceNegative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(CategoryData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.category),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Amount', data.formattedAmount),
            const SizedBox(height: 8),
            _buildDetailRow('Percentage', data.formattedPercentage),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  data.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
