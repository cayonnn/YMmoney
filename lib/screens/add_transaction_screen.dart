import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/category_selector.dart';
import '../widgets/gradient_button.dart';
import '../widgets/type_toggle.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';
import 'add_category_screen.dart';

class AddTransactionScreen extends StatefulWidget {
  final VoidCallback? onTransactionAdded;
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({
    super.key,
    this.onTransactionAdded,
    this.transactionToEdit,
  });

  bool get isEditMode => transactionToEdit != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _db = DatabaseService();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isExpense = true;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    // Get currency from user profile
    _selectedCurrency = _db.getUserProfile().currency;
    
    // Pre-fill form if editing
    if (widget.isEditMode) {
      final t = widget.transactionToEdit!;
      _amountController.text = t.amount.toString();
      _noteController.text = t.note;
      _isExpense = t.isExpense;
      _selectedCategoryId = t.categoryId;
      _selectedDate = t.date;
      _selectedCurrency = t.currency;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isExpense 
        ? CategoryModel.expenseCategories 
        : CategoryModel.incomeCategories;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditMode 
              ? (_isExpense ? AppStrings.editExpense : AppStrings.editIncome)
              : (_isExpense ? AppStrings.addExpenses : AppStrings.addIncome),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Toggle
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: TypeToggle(
                isExpense: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value;
                    _selectedCategoryId = null;
                  });
                },
              ),
            ),

            // Amount Input
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _selectedCurrency,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w500,
                            color: _isExpense 
                                ? AppTheme.primaryOrange 
                                : AppTheme.incomeColor,
                          ),
                        ),
                      ),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                            color: _isExpense 
                                ? AppTheme.primaryOrange 
                                : AppTheme.incomeColor,
                          ),
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            hintText: '0',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Section
            _buildSectionTile(
              icon: Icons.category_outlined,
              title: 'Category',
              trailing: _selectedCategoryId != null
                  ? CategoryModel.getById(_selectedCategoryId!)?.nameEn ?? 'Select'
                  : 'Select',
              onTap: () => _showCategoryPicker(categories),
            ),
            const SizedBox(height: 12),

            // Note Section
            _buildSectionTile(
              icon: Icons.note_outlined,
              title: 'Note',
              trailing: _noteController.text.isEmpty ? AppStrings.addNote : _noteController.text,
              onTap: _showNoteInput,
            ),
            const SizedBox(height: 12),

            // Date Section
            _buildSectionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Date',
              trailing: _formatDate(_selectedDate),
              onTap: _showDatePicker,
            ),
            const SizedBox(height: 40),

            // Save Button
            GradientButton(
              text: 'SAVE',
              onPressed: _saveTransaction,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Icon(
                icon,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              trailing,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: CategorySelector(
                    categories: _isExpense 
                        ? CategoryModel.expenseCategories 
                        : CategoryModel.incomeCategories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategoryId = category.id;
                      });
                      Navigator.pop(context);
                    },
                    onAddNewCategory: () {
                      Navigator.pop(context);
                      _openAddCategoryScreen();
                    },
                    onEditCategory: (category) {
                      // Pop the category selector, then open edit screen
                      Navigator.pop(context);
                      _openEditCategoryScreen(category);
                    },
                    onDeleteCategory: (category) {
                      // Pop the category selector, then delete
                      Navigator.pop(context);
                      _deleteCategory(category);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddCategoryScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddCategoryScreen(
          isExpense: _isExpense,
          onCategoryAdded: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  void _openEditCategoryScreen(CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => AddCategoryScreen(
          isExpense: _isExpense,
          categoryToEdit: category,
          onCategoryAdded: () {
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _deleteCategory(CategoryModel category) async {
    // Clean up any category budgets for this category
    await _db.deleteAllCategoryBudgets(category.id);
    
    // For system categories, hide them. For custom categories, delete them.
    if (category.isCustom) {
      await _db.deleteCustomCategory(category.id);
    } else {
      // System category - hide it
      await _db.hideCategory(category.id);
    }
    
    if (mounted) {
      setState(() {
        if (_selectedCategoryId == category.id) {
          _selectedCategoryId = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Category "${category.displayName}" deleted'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
  }

  void _showNoteInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addNote,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                autofocus: true,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Enter note',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    // Validation
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = TransactionModel(
        id: widget.isEditMode ? widget.transactionToEdit!.id : _db.generateId(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        note: _noteController.text.trim(),
        date: _selectedDate,
        isExpense: _isExpense,
        currency: _selectedCurrency,
      );

      if (widget.isEditMode) {
        await _db.updateTransaction(transaction);
      } else {
        await _db.addTransaction(transaction);
      }

      if (mounted) {
        widget.onTransactionAdded?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode 
                ? 'Transaction updated!' 
                : (_isExpense ? 'Expense added!' : 'Income added!')),
            backgroundColor: AppTheme.incomeColor,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save transaction');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }
}
