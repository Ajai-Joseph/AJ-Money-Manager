import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:aj_money_manager/db/category/category_db.dart';
import 'package:aj_money_manager/models/category_model.dart';
import 'package:aj_money_manager/config/theme/app_colors.dart';
import 'package:aj_money_manager/config/theme/app_text_styles.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedCategoryType = 'income';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

    // If editing, populate fields
    if (widget.category != null) {
      _purposeController.text = widget.category!.purpose;
      _amountController.text = widget.category!.amount.toString();
      _selectedDate = widget.category!.dateTime;
      _selectedCategoryType = widget.category!.categoryType;
    }
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validatePurpose(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a purpose';
    }
    if (value.trim().length < 3) {
      return 'Purpose must be at least 3 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a date'),
          backgroundColor: AppColors.errorLight,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final category = CategoryModel(
        id: widget.category?.id ?? DateTime.now().toString(),
        purpose: _purposeController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        categoryType: _selectedCategoryType,
        dateTime: _selectedDate!,
      );

      await addCategory(category);

      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.errorLight,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.incomeColor,
                      size: 64,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                widget.category == null
                    ? 'Transaction Added!'
                    : 'Transaction Updated!',
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _selectedCategoryType == 'income';
    final categoryColor = isIncome
        ? AppColors.incomeColor
        : AppColors.expenseColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Type Selector
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCategoryTypeButton(
                          'income',
                          'Income',
                          Icons.arrow_downward,
                          AppColors.incomeColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCategoryTypeButton(
                          'expense',
                          'Expense',
                          Icons.arrow_upward,
                          AppColors.expenseColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Purpose Field
                TextFormField(
                  controller: _purposeController,
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    hintText: 'Enter transaction purpose',
                    prefixIcon: Icon(Icons.description, color: categoryColor),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: _validatePurpose,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),

                // Amount Field
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    prefixIcon: Icon(
                      Icons.currency_rupee,
                      color: categoryColor,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: _validateAmount,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 20),

                // Date Picker
                InkWell(
                  onTap: _isLoading ? null : () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: _selectedDate == null
                            ? AppColors.errorLight.withValues(alpha: 0.5)
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: categoryColor),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedDate == null
                                    ? 'Select date'
                                    : DateFormat(
                                        'dd MMM yyyy',
                                      ).format(_selectedDate!),
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _selectedDate == null
                                      ? Theme.of(context).colorScheme.onSurface
                                            .withValues(alpha: 0.4)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          widget.category == null
                              ? 'Add Transaction'
                              : 'Update Transaction',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTypeButton(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCategoryType == value;

    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _selectedCategoryType = value;
              });
            },
      borderRadius: BorderRadius.circular(12.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
