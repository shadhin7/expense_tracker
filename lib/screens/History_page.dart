// history_page.dart
// Redesigned History page UI to match the provided screenshot style
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
  String? _selectedType; // 'All', 'Income', 'Expense', 'Transfer'
  String? _sortBy; // 'Highest', 'Lowest', 'Newest', 'Oldest'
  bool _showFilters = false;

  final List<String> _types = ['All', 'Income', 'Expense'];
  final List<String> _sortOptions = ['Highest', 'Lowest'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCategories());
    _selectedType = 'All';
  }

  Future<void> _loadCategories() async {
    final categoryProvider = context.read<CategoryProvider>();
    await categoryProvider.loadUserCategories('income');
    await categoryProvider.loadUserCategories('expense');
    setState(() {});
  }

  List<String> get _allCategories {
    final categoryProvider = context.read<CategoryProvider>();
    final defaultCategories = [
      'Food',
      'Shopping',
      'Bills',
      'Healthcare',
      'Salary',
      'Bonus',
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
      _sortBy = null;
    });
  }

  // Keep backward-compatible matching but include Transfer checking via tx.type
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
      if (_selectedType == 'Transfer' &&
          (transaction.type.toLowerCase() != 'transfer')) {
        return false;
      }
    }

    return true;
  }

  List<TransactionModel> _applySort(List<TransactionModel> list) {
    if (_sortBy == null) return list;

    final sorted = List<TransactionModel>.from(list);
    switch (_sortBy) {
      case 'Highest':
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Lowest':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Newest':
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Oldest':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      default:
        break;
    }
    return sorted;
  }

  Widget _buildPillButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Color.fromARGB(46, 6, 143, 255) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? Colors.blue : Colors.grey.shade300,
            width: selected ? 0.0 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSortPill(String label) {
    final selected = _sortBy == label;
    return _buildPillButton(
      label: label,
      selected: selected,
      onTap: () => setState(() {
        _sortBy = selected ? null : label;
      }),
    );
  }

  Widget _buildTypePill(String label) {
    final selected = (_selectedType ?? 'All') == label;
    return _buildPillButton(
      label: label,
      selected: selected,
      onTap: () => setState(() {
        _selectedType = label;
        // if previously selected category becomes invalid, clear it
        if (_selectedCategory != null &&
            !_filteredCategories.contains(_selectedCategory)) {
          _selectedCategory = null;
        }
      }),
    );
  }

  Future<void> _showCategorySelector() async {
    final categories = _filteredCategories;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Choose Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == _selectedCategory;
                      return ListTile(
                        title: Text(cat),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.purple)
                            : null,
                        onTap: () => Navigator.of(context).pop(cat),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: categories.length,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedCategory = selected);
    } else {
      // if user cleared in sheet, set to null
      // NOTE: we only set null here if they explicitly used 'Clear' and the sheet returned null
      // but this also happens if they cancelled. Keep original to not forcibly clear on cancel.
    }
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _selectedDate != null ||
      (_selectedType != null && _selectedType != 'All') ||
      (_sortBy != null);

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
          final double cardRadius = 18.0;

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

                  // Filter card (collapsible)
                  if (_showFilters)
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(cardRadius),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Row with Reset
                          Row(
                            children: [
                              const Text(
                                'Filter Transaction',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _clearFilters,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Color(0xFFEDE6FF),
                                  ),
                                ),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Filter By (Income / Expense / Transfer)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Filter By',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _types.map((t) {
                                // make label prettier: use 'All' as 'All'
                                final display = t;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _buildTypePill(display),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Sort By row (pills)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              'Sort By',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _sortOptions.map((s) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: _buildSortPill(s),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Category chooser and Date picker inline
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _showCategorySelector,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Choose Category',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _selectedCategory == null
                                              ? '0 Selected'
                                              : '1 Selected',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => _pickDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 18,
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
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      if (_selectedDate != null)
                                        GestureDetector(
                                          onTap: () => setState(
                                            () => _selectedDate = null,
                                          ),
                                          child: const Icon(
                                            Icons.clear,
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Active filter chips
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (_selectedCategory != null)
                                  InputChip(
                                    label: Text('Category: $_selectedCategory'),
                                    onDeleted: () => setState(
                                      () => _selectedCategory = null,
                                    ),
                                  ),
                                if (_selectedDate != null)
                                  InputChip(
                                    label: Text(
                                      'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                                    ),
                                    onDeleted: () =>
                                        setState(() => _selectedDate = null),
                                  ),
                                if (_selectedType != null &&
                                    _selectedType != 'All')
                                  InputChip(
                                    label: Text('Type: $_selectedType'),
                                    onDeleted: () =>
                                        setState(() => _selectedType = 'All'),
                                  ),
                                if (_sortBy != null)
                                  InputChip(
                                    label: Text('Sort: $_sortBy'),
                                    onDeleted: () =>
                                        setState(() => _sortBy = null),
                                  ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 18),

                          // Apply big button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // simply close/hide filters and keep the selected filters applied
                                setState(() => _showFilters = false);
                                // optionally provide a small feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Filters applied'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Summary card
                  Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Income',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'AED ${provider.formattedTotalIncome}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Expense',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'AED ${provider.formattedTotalExpense}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Balance',
                                style: TextStyle(
                                  color: provider.balance >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'AED ${provider.formattedBalance}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Transaction list
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
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }

                          final transactions = snapshot.data ?? [];
                          // apply filter
                          var filtered = transactions
                              .where(_matchesFilters)
                              .toList();
                          // apply sort
                          filtered = _applySort(filtered);

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

                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TransactionDetailPage(
                                          transaction: tx,
                                          transactionId: tx.id,
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.02,
                                            ),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(
                                              iconPadding,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isIncome
                                                  ? Colors.green.shade100
                                                  : Colors.red.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
