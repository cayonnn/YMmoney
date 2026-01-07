import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/recurring_transaction.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../widgets/category_selector.dart';
import '../widgets/gradient_button.dart';
import '../widgets/type_toggle.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';

class AddRecurringScreen extends StatefulWidget {
  final RecurringTransaction? editRecurring;

  const AddRecurringScreen({
    super.key,
    this.editRecurring,
  });

  @override
  State<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<AddRecurringScreen> {
  final _db = DatabaseService();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isExpense = true;
  String? _selectedCategoryId;
  DateTime _startDate = DateTime.now();
  int _frequencyIndex = 2; // Monthly
  String _selectedCurrency = '฿';
  bool _isLoading = false;

  static const List<String> _frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  static const List<String> _currencySymbols = ['฿', '\$', '€', '¥', '元', '£', '₩', 'NT\$', '₽'];

  @override
  void initState() {
    super.initState();
    if (widget.editRecurring != null) {
      final r = widget.editRecurring!;
      _nameController.text = r.name;
      _amountController.text = r.amount.toString();
      _noteController.text = r.note;
      _isExpense = r.isExpense;
      _selectedCategoryId = r.categoryId;
      _startDate = r.startDate;
      _frequencyIndex = r.frequencyIndex;
      _selectedCurrency = r.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isExpense
        ? CategoryModel.expenseCategories
        : CategoryModel.incomeCategories;
    final isEditing = widget.editRecurring != null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? AppStrings.editRecurring : AppStrings.addRecurring,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: _deleteRecurring,
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Name Input
            _buildTextField(
              controller: _nameController,
              label: 'Name',
              hint: 'e.g. Monthly Rent, Netflix',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 16),

            // Amount Input
            _buildAmountInput(),
            const SizedBox(height: 16),

            // Frequency Selector
            _buildFrequencySelector(),
            const SizedBox(height: 16),

            // Category
            _buildSectionTile(
              icon: Icons.category_outlined,
              title: 'Category',
              trailing: _selectedCategoryId != null
                  ? CategoryModel.getById(_selectedCategoryId!)?.nameEn ?? 'Select'
                  : 'Select',
              onTap: () => _showCategoryPicker(categories),
            ),
            const SizedBox(height: 16),

            // Start Date
            _buildSectionTile(
              icon: Icons.calendar_today_outlined,
              title: 'Start Date',
              trailing: DateFormat('dd MMM yyyy').format(_startDate),
              onTap: _showDatePicker,
            ),
            const SizedBox(height: 16),

            // Note
            _buildTextField(
              controller: _noteController,
              label: 'Note (Optional)',
              hint: AppStrings.addNote,
              icon: Icons.note_outlined,
            ),
            const SizedBox(height: 40),

            // Save Button
            GradientButton(
              text: isEditing ? 'UPDATE' : 'SAVE',
              onPressed: _saveRecurring,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return TypeToggle(
      isExpense: _isExpense,
      onChanged: (value) {
        setState(() {
          _isExpense = value;
          _selectedCategoryId = null;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color ?? Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Row(
      children: [
        // Currency Selector
        GestureDetector(
          onTap: _showCurrencyPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  _selectedCurrency,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppTheme.primaryOrange),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Amount Field
        Expanded(
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.repeat, color: AppTheme.primaryOrange),
              const SizedBox(width: 12),
              Text(
                AppStrings.frequency,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_frequencies.length, (index) {
              final isSelected = _frequencyIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _frequencyIndex = index),
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _frequencies[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
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
          color: Theme.of(context).cardTheme.color ?? Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryOrange),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              trailing,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(List<CategoryModel> categories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: CategorySelector(
                categories: categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (category) {
                  setState(() => _selectedCategoryId = category.id);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _currencySymbols.map((currency) {
                final isSelected = currency == _selectedCurrency;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCurrency = currency);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        currency,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _saveRecurring() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter a name');
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
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
      if (widget.editRecurring != null) {
        // Update existing
        final r = widget.editRecurring!;
        r.name = _nameController.text.trim();
        r.amount = amount;
        r.categoryId = _selectedCategoryId!;
        r.note = _noteController.text.trim();
        r.isExpense = _isExpense;
        r.currency = _selectedCurrency;
        r.frequencyIndex = _frequencyIndex;
        r.startDate = _startDate;
        await _db.updateRecurringTransaction(r);
      } else {
        // Create new
        // Calculate initial lastGenerated by going back one full period
        // This ensures the startDate will be treated as the first next due date
        DateTime initialLastGenerated;
        switch (_frequencyIndex) {
          case 0: // Daily
            initialLastGenerated = _startDate.subtract(const Duration(days: 1));
            break;
          case 1: // Weekly
            initialLastGenerated = _startDate.subtract(const Duration(days: 7));
            break;
          case 2: // Monthly
            // Go back one month, preserving the day
            int prevMonth = _startDate.month - 1;
            int prevYear = _startDate.year;
            if (prevMonth < 1) {
              prevMonth = 12;
              prevYear--;
            }
            final daysInPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
            final day = _startDate.day > daysInPrevMonth ? daysInPrevMonth : _startDate.day;
            initialLastGenerated = DateTime(prevYear, prevMonth, day);
            break;
          case 3: // Yearly
            initialLastGenerated = DateTime(_startDate.year - 1, _startDate.month, _startDate.day);
            break;
          default:
            initialLastGenerated = _startDate.subtract(const Duration(days: 1));
        }
        
        final recurring = RecurringTransaction(
          id: _db.generateId(),
          name: _nameController.text.trim(),
          amount: amount,
          categoryId: _selectedCategoryId!,
          note: _noteController.text.trim(),
          isExpense: _isExpense,
          currency: _selectedCurrency,
          frequencyIndex: _frequencyIndex,
          startDate: _startDate,
          lastGenerated: initialLastGenerated,
          createdAt: DateTime.now(),
        );
        await _db.addRecurringTransaction(recurring);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to save');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteRecurring() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteRecurring),
        content: const Text('This will stop all future transactions from being generated.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppStrings.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && widget.editRecurring != null) {
      await _db.deleteRecurringTransaction(widget.editRecurring!.id);
      if (mounted) {
        Navigator.pop(context, true);
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
