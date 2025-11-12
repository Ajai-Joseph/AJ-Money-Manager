import 'package:flutter/material.dart';
import 'package:aj_money_manager/screens/category/expense_category_list.dart';
import 'package:aj_money_manager/screens/category/income_category_list.dart';
import 'package:aj_money_manager/widgets/modern_search_bar.dart';

class ScreenCategory extends StatefulWidget {
  const ScreenCategory({super.key});

  @override
  State<ScreenCategory> createState() => _ScreenCategoryState();
}

class _ScreenCategoryState extends State<ScreenCategory>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late AnimationController _fabRotationController;
  late Animation<double> _fabRotationAnimation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabRotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabRotationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Start animations after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fabAnimationController.forward();
        _fabRotationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    _fabRotationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? null
            : const Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isSearching ? 120 : 48),
          child: Column(
            children: [
              if (_isSearching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ModernSearchBar(
                    controller: _searchController,
                    hintText: 'Search categories...',
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              ],
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                    ),
                  ),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.arrow_downward),
                      text: "INCOME",
                    ),
                    Tab(
                      icon: Icon(Icons.arrow_upward),
                      text: "EXPENSE",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          IncomeCategoryList(searchQuery: _searchQuery),
          ExpenseCategoryList(searchQuery: _searchQuery),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'Add new category',
        button: true,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
          child: RotationTransition(
            turns: _fabRotationAnimation,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/add-category');
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Category'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              heroTag: 'add_category_fab',
            ),
          ),
        ),
      ),
    );
  }
}
