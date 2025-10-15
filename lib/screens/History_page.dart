// Clean responsive History page
import 'package:expense_track/Provider/balance_provider.dart';
import 'package:expense_track/Provider/category_provider.dart';
import 'package:expense_track/models/transaction_model.dart';
import 'package:expense_track/transaction/iconstest.dart';
import 'package:expense_track/screens/transaction_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  DateTime selectedMonth = DateTime.now();
  String? _selectedCategory;
  DateTime? _selectedDate;
  String? _selectedType;
  bool _showFilters = false;

  final List<String> _types = ['All', 'Income', 'Expense'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
  }

  Future<void> _loadCategories() async {
    final categoryProvider = context.read<CategoryProvider>();
    await categoryProvider.loadUserCategories('income');
    await categoryProvider.loadUserCategories('expense');
  }

  List<String> get _allCategories {
    final categoryProvider = context.read<CategoryProvider>();
    final defaultCategories = [
      'Food',
      'Transport',
      'Shopping',
      'Entertainment',
      'Bills',
      'Healthcare',
      'Education',
      'Salary',
      'Bonus',
      'Investment',
      'Other',
    ];

    final allCategories = <String>{
      ...defaultCategories,
      ...categoryProvider.incomeCategories,
      ...categoryProvider.expenseCategories,
    };

    return allCategories.toList()..sort();
  }

  List<String> get _filteredCategories {
    final categoryProvider = context.read<CategoryProvider>();
    if (_selectedType == 'Income') {
      final defaultIncomeCategories = ['Salary', 'Bonus', 'Investment'];
      return <String>{
        ...defaultIncomeCategories,
        ...categoryProvider.incomeCategories,
      }.toList()..sort();
    }

    if (_selectedType == 'Expense') {
      final defaultExpenseCategories = [
        'Food',
        'Transport',
        'Shopping',
        'Entertainment',
        'Bills',
        'Healthcare',
        'Education',
        'Other',
      ];
      return <String>{
        ...defaultExpenseCategories,
        ...categoryProvider.expenseCategories,
      }.toList()..sort();
    }

    return _allCategories;
  }

  void _pickMonth(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        _selectedDate = null;
      });
      Provider.of<BalanceProvider>(context, listen: false).loadMonth(picked);
    }
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedDate = null;
      _selectedType = 'All';
    });
  }

  bool _matchesFilters(TransactionModel transaction) {
    if (_selectedCategory != null &&
        transaction.category != _selectedCategory) {
      return false;
    }
    if (_selectedDate != null &&
        !DateUtils.isSameDay(_selectedDate, transaction.date)) {
      return false;
    }
    if (_selectedType != null && _selectedType != 'All') {
      if (_selectedType == 'Income' && !transaction.isIncome) return false;
      if (_selectedType == 'Expense' && transaction.isIncome) return false;
    }
    return true;
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(8),
            hint: Text('All $label'),
            items: [
              DropdownMenuItem<String>(value: null, child: Text('All $label')),
              ...items
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onDelete}) {
    return Chip(
      label: Text(label),
      onDeleted: onDelete,
      backgroundColor: Colors.blue.shade50,
      labelStyle: const TextStyle(fontSize: 12),
    );
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _selectedDate != null ||
      (_selectedType != null && _selectedType != 'All');

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BalanceProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: const Text('Transaction History'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _pickMonth(context),
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Select Month',
          ),
          IconButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Stack(
              children: [
                const Icon(Icons.filter_alt),
                if (_hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Show Filters',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1100;
          final isDesktop = constraints.maxWidth >= 1100;
          final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 24.0 : 12.0);
          // adaptive field width for filter controls
          final double fieldWidth = isDesktop
              ? 260
              : isTablet
              ? 220
              : (constraints.maxWidth - horizontalPadding * 2);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Showing: ${DateFormat.yMMM().format(selectedMonth)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  if (_showFilters)
                    Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.filter_list, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Filters',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: _loadCategories,
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Refresh Categories',
                                ),
                                TextButton(
                                  onPressed: _clearFilters,
                                  child: const Text(
                                    'Clear All',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Filters grid
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: fieldWidth,
                                  child: _buildFilterDropdown(
                                    label: 'Type',
                                    value: _selectedType ?? 'All',
                                    items: _types,
                                    onChanged: (v) => setState(() {
                                      _selectedType = v;
                                      if (_selectedCategory != null) {
                                        final available = _filteredCategories;
                                        if (!available.contains(
                                          _selectedCategory,
                                        )) {
                                          _selectedCategory = null;
                                        }
                                      }
                                    }),
                                  ),
                                ),

                                SizedBox(
                                  width: fieldWidth,
                                  child: _buildFilterDropdown(
                                    label: 'Category',
                                    value: _selectedCategory,
                                    items: _filteredCategories,
                                    onChanged: (v) =>
                                        setState(() => _selectedCategory = v),
                                  ),
                                ),

                                SizedBox(
                                  width: fieldWidth,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Date',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      InkWell(
                                        onTap: () => _pickDate(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: isDesktop
                                                    ? 22
                                                    : (isTablet ? 20 : 18),
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _selectedDate != null
                                                      ? DateFormat(
                                                          'dd/MM/yyyy',
                                                        ).format(_selectedDate!)
                                                      : 'Select Date',
                                                  style: TextStyle(
                                                    color: _selectedDate != null
                                                        ? Colors.black
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ),
                                              if (_selectedDate != null)
                                                IconButton(
                                                  onPressed: () => setState(
                                                    () => _selectedDate = null,
                                                  ),
                                                  icon: Icon(
                                                    Icons.clear,
                                                    size: isDesktop ? 18 : 16,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (_hasActiveFilters) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_selectedCategory != null)
                                    _buildFilterChip(
                                      'Category: $_selectedCategory',
                                      onDelete: () => setState(
                                        () => _selectedCategory = null,
                                      ),
                                    ),
                                  if (_selectedDate != null)
                                    _buildFilterChip(
                                      'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                                      onDelete: () =>
                                          setState(() => _selectedDate = null),
                                    ),
                                  if (_selectedType != null &&
                                      _selectedType != 'All')
                                    _buildFilterChip(
                                      'Type: $_selectedType',
                                      onDelete: () =>
                                          setState(() => _selectedType = 'All'),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  // Transactions list
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 8,
                      ),
                      child: StreamBuilder<List<TransactionModel>>(
                        stream: provider.getMonthlyTransactionsStream(
                          '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}',
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final transactions = snapshot.data ?? [];
                          final filtered = transactions
                              .where(_matchesFilters)
                              .toList();

                          if (_showFilters && transactions.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              ScaffoldMessenger.of(
                                context,
                              ).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Showing ${filtered.length} of ${transactions.length} transactions',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            });
                          }

                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No transactions found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _hasActiveFilters
                                        ? 'Try adjusting your filters'
                                        : 'for ${DateFormat.yMMM().format(selectedMonth)}',
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final tx = filtered[index];
                              final isIncome = tx.isIncome;
                              final imagePath = getCategoryImage(
                                tx.category,
                                tx.type,
                              );
                              final double imageSize = isDesktop
                                  ? 40
                                  : (isTablet ? 36 : 30);
                              final double iconPadding = isDesktop
                                  ? 16
                                  : (isTablet ? 14 : 12);
                              final double categoryFont = isDesktop
                                  ? 18
                                  : (isTablet ? 16 : 14);

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TransactionDetailPage(
                                        transaction: tx,
                                        transactionId: tx.id!,
                                      ),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(iconPadding),
                                          decoration: BoxDecoration(
                                            color: isIncome
                                                ? Colors.green.shade100
                                                : Colors.red.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Image.asset(
                                            imagePath,
                                            width: imageSize,
                                            height: imageSize,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                tx.category,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: categoryFont,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                tx.description.isEmpty
                                                    ? 'No description'
                                                    : tx.description,
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${isIncome ? '+' : '-'} AED ${tx.amount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isIncome
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                'dd/MM/yyyy',
                                              ).format(tx.date),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              DateFormat(
                                                'hh:mm a',
                                              ).format(tx.date),
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
