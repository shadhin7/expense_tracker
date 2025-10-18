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
  List<String> _selectedCategories = [];
  DateTime? _selectedDate;
  String? _selectedType; // 'All', 'Income', 'Expense', 'Transfer'
  String? _sortBy; // 'Highest', 'Lowest', 'Newest', 'Oldest'

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

  void _pickMonth(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        headerSettings: PickerHeaderSettings(
          headerBackgroundColor: Colors.blue, // ✅ Header background
          headerCurrentPageTextStyle: TextStyle(
            color: Colors.white, // ✅ Header text color
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        dateButtonsSettings: const PickerDateButtonsSettings(
          currentMonthTextColor: Colors.blue,
          unselectedMonthsTextColor: Colors.black,

          selectedMonthBackgroundColor:
              Colors.blue, // ✅ Selected month highlight
          selectedMonthTextColor: Colors.white, // ✅ Text on selected month
        ),
        actionBarSettings: const PickerActionBarSettings(),
        // Optional: Dialog background
        dialogSettings: const PickerDialogSettings(
          dialogBackgroundColor: Colors.white,
        ),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
        _selectedDate = null;
      });
      Provider.of<BalanceProvider>(context, listen: false).loadMonth(picked);
    }
  }

  // Keep backward-compatible matching but include Transfer checking via tx.type
  bool _matchesFilters(TransactionModel transaction) {
    // Category filter
    if (_selectedCategories.isNotEmpty &&
        !_selectedCategories.contains(transaction.category)) {
      return false;
    }

    // Date filter
    if (_selectedDate != null &&
        !DateUtils.isSameDay(_selectedDate, transaction.date)) {
      return false;
    }

    // Type filter
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

  Future<void> _showFilterModal() async {
    // Store current values to use in the modal
    final List<String> tempSelectedCategories = List.from(_selectedCategories);
    String? tempSelectedType = _selectedType;
    String? tempSortBy = _sortBy;
    DateTime? tempSelectedDate = _selectedDate;

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<String> getFilteredCategoriesForModal() {
              final categoryProvider = context.read<CategoryProvider>();
              if (tempSelectedType == 'Income') {
                final defaultIncomeCategories = [
                  'Salary',
                  'Bonus',
                  'Investment',
                ];
                return <String>{
                  ...defaultIncomeCategories,
                  ...categoryProvider.incomeCategories,
                }.toList()..sort();
              }

              if (tempSelectedType == 'Expense') {
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

            final modalCategories = getFilteredCategoriesForModal();

            return SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Filter Transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempSelectedCategories.clear();
                              tempSelectedDate = null;
                              tempSelectedType = 'All';
                              tempSortBy = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            side: const BorderSide(color: Color(0xFFEDE6FF)),
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
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Filter By',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _types.map((t) {
                          final display = t;
                          final selected = (tempSelectedType ?? 'All') == t;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setModalState(() {
                                tempSelectedType = t;
                                // if previously selected categories become invalid, clear them
                                if (tempSelectedCategories.isNotEmpty) {
                                  final validCategories =
                                      getFilteredCategoriesForModal();
                                  tempSelectedCategories.removeWhere(
                                    (cat) => !validCategories.contains(cat),
                                  );
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Color.fromARGB(46, 6, 143, 255)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: selected ? 0.0 : 1.0,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  display,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.blue
                                        : Colors.black87,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sort By row (pills)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sort By',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sortOptions.map((s) {
                          final selected = tempSortBy == s;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () => setModalState(() {
                                tempSortBy = selected ? null : s;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Color.fromARGB(46, 6, 143, 255)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: selected ? 0.0 : 1.0,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: Colors.blue.withOpacity(
                                              0.06,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.blue
                                        : Colors.black87,
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Category',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tempSelectedCategories.isEmpty
                                ? 'Select Categories'
                                : '${tempSelectedCategories.length} Selected',
                            style: TextStyle(
                              color: tempSelectedCategories.isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (tempSelectedCategories.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tempSelectedCategories.map((category) {
                                return InputChip(
                                  deleteIconColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  backgroundColor: const Color.fromARGB(
                                    46,
                                    6,
                                    143,
                                    255,
                                  ),
                                  label: Text(
                                    category,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  onDeleted: () => setModalState(() {
                                    tempSelectedCategories.remove(category);
                                  }),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Category Selection List
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: modalCategories.length,
                        itemBuilder: (context, index) {
                          final category = modalCategories[index];
                          final isSelected = tempSelectedCategories.contains(
                            category,
                          );
                          return CheckboxListTile(
                            activeColor: Colors.blue,
                            title: Text(category),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setModalState(() {
                                if (value == true) {
                                  if (!tempSelectedCategories.contains(
                                    category,
                                  )) {
                                    tempSelectedCategories.add(category);
                                  }
                                } else {
                                  tempSelectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempSelectedDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors
                                          .blue, // Header background & selected date
                                      onPrimary:
                                          Colors.white, // Header text color
                                      onSurface:
                                          Colors.black, // Default text color
                                    ),
                                    dialogBackgroundColor:
                                        Colors.white, // Calendar background
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setModalState(() => tempSelectedDate = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
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
                                    tempSelectedDate != null
                                        ? DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(tempSelectedDate!)
                                        : 'Select Date',
                                    style: TextStyle(
                                      color: tempSelectedDate != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                if (tempSelectedDate != null)
                                  GestureDetector(
                                    onTap: () => setModalState(
                                      () => tempSelectedDate = null,
                                    ),
                                    child: const Icon(Icons.clear, size: 18),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Apply Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Update the main state with modal values
                          setState(() {
                            _selectedCategories = List.from(
                              tempSelectedCategories,
                            );
                            _selectedType = tempSelectedType;
                            _sortBy = tempSortBy;
                            _selectedDate = tempSelectedDate;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Filters applied'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool get _hasActiveFilters =>
      _selectedCategories.isNotEmpty ||
      _selectedDate != null ||
      (_selectedType != null && _selectedType != 'All') ||
      (_sortBy != null);

  // Calculate filtered totals based on current filters
  Map<String, dynamic> _calculateFilteredTotals(
    List<TransactionModel> transactions,
  ) {
    double totalIncome = 0;
    double totalExpense = 0;

    // Calculate category-wise totals
    Map<String, double> categoryTotals = {};

    final filteredTransactions = transactions.where(_matchesFilters).toList();

    for (final transaction in filteredTransactions) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }

      // Update category totals
      if (!categoryTotals.containsKey(transaction.category)) {
        categoryTotals[transaction.category] = 0;
      }
      categoryTotals[transaction.category] =
          categoryTotals[transaction.category]! + transaction.amount;
    }

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
      'categoryTotals': categoryTotals,
      'filteredTransactions': filteredTransactions,
    };
  }

  Widget _buildSummaryCard(Map<String, dynamic> totals) {
    final double income = totals['income'] as double;
    final double expense = totals['expense'] as double;
    final double balance = totals['balance'] as double;
    final Map<String, double> categoryTotals =
        totals['categoryTotals'] as Map<String, double>;
    final List<TransactionModel> filteredTransactions =
        totals['filteredTransactions'] as List<TransactionModel>;

    // If we have specific filters, show detailed breakdown
    if (_selectedCategories.isNotEmpty ||
        _selectedDate != null ||
        _selectedType != 'All') {
      List<Widget> summaryWidgets = [];

      // Show overall totals first
      summaryWidgets.addAll([
        const SizedBox(height: 8),
        const Text(
          'Overall Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
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
                  'AED ${income.toStringAsFixed(2)}',
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
                  'AED ${expense.toStringAsFixed(2)}',
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
                    color: balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AED ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ]);

      // Show category-wise breakdown if categories are selected
      if (_selectedCategories.isNotEmpty) {
        summaryWidgets.addAll([
          const SizedBox(height: 16),
          const Text(
            'Category Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: _selectedCategories.map((category) {
              final amount = categoryTotals[category] ?? 0;
              return Chip(
                backgroundColor: Colors.white,
                label: Text(
                  '$category = AED ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ]);
      }

      // Show date-specific total if date is selected
      if (_selectedDate != null) {
        double dateTotal = 0;
        for (final transaction in filteredTransactions) {
          if (DateUtils.isSameDay(_selectedDate, transaction.date)) {
            dateTotal += transaction.amount;
          }
        }

        summaryWidgets.addAll([
          const SizedBox(height: 16),
          const Text(
            'Date Summary',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Chip(
            backgroundColor: const Color.fromARGB(46, 6, 143, 255),
            label: Text(
              '${DateFormat('dd/MM/yyyy').format(_selectedDate!)}: AED ${dateTotal.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ]);
      }

      return Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: summaryWidgets,
          ),
        ),
      );
    }

    // Default summary when no specific filters
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  'AED ${income.toStringAsFixed(2)}',
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
                  'AED ${expense.toStringAsFixed(2)}',
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
                    color: balance >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AED ${balance.toStringAsFixed(2)}',
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
    );
  }

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
            onPressed: _showFilterModal,
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

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                children: [
                  // Summary card
                  StreamBuilder<List<TransactionModel>>(
                    stream: provider.getMonthlyTransactionsStream(
                      '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}',
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }

                      final transactions = snapshot.data ?? [];
                      final totals = _calculateFilteredTotals(transactions);

                      return _buildSummaryCard(totals);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'Showing: ${DateFormat.yMMM().format(selectedMonth)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  // Active filter chips
                  if (_hasActiveFilters)
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedCategories.isNotEmpty)
                            ..._selectedCategories.map((category) {
                              return InputChip(
                                deleteIconColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                backgroundColor: const Color.fromARGB(
                                  46,
                                  6,
                                  143,
                                  255,
                                ),
                                label: Text(
                                  'Category: $category',
                                  style: const TextStyle(color: Colors.blue),
                                ),
                                onDeleted: () => setState(() {
                                  _selectedCategories.remove(category);
                                }),
                              );
                            }),
                          if (_selectedDate != null)
                            InputChip(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              deleteIconColor: Colors.blue,
                              backgroundColor: const Color.fromARGB(
                                46,
                                6,
                                143,
                                255,
                              ),
                              label: Text(
                                'Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                                style: const TextStyle(color: Colors.blue),
                              ),
                              onDeleted: () =>
                                  setState(() => _selectedDate = null),
                            ),
                          if (_selectedType != null && _selectedType != 'All')
                            InputChip(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              deleteIconColor: Colors.blue,
                              backgroundColor: const Color.fromARGB(
                                46,
                                6,
                                143,
                                255,
                              ),
                              label: Text(
                                'Type: $_selectedType',
                                style: const TextStyle(color: Colors.blue),
                              ),
                              onDeleted: () =>
                                  setState(() => _selectedType = 'All'),
                            ),
                          if (_sortBy != null)
                            InputChip(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              deleteIconColor: Colors.blue,
                              backgroundColor: const Color.fromARGB(
                                46,
                                6,
                                143,
                                255,
                              ),
                              label: Text(
                                'Sort: $_sortBy',
                                style: const TextStyle(color: Colors.blue),
                              ),
                              onDeleted: () => setState(() => _sortBy = null),
                            ),
                        ],
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
                                          color: Colors.black.withOpacity(0.02),
                                          blurRadius: 6,
                                        ),
                                      ],
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
