import 'package:flutter/material.dart';
import '../models/custom_category.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../config/theme.dart';
import '../l10n/app_strings.dart';
import '../widgets/gradient_button.dart';
import '../widgets/type_toggle.dart';
import '../utils/icon_helper.dart'; // Added import

class AddCategoryScreen extends StatefulWidget {
  final bool isExpense;
  final VoidCallback? onCategoryAdded;
  final CategoryModel? categoryToEdit;

  const AddCategoryScreen({
    super.key,
    this.isExpense = true,
    this.onCategoryAdded,
    this.categoryToEdit,
  });

  bool get isEditMode => categoryToEdit != null;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _db = DatabaseService();
  final _nameController = TextEditingController();
  
  bool _isExpense = true;
  IconData _selectedIcon = Icons.category; // Store selected IconData directly
  int _selectedColorIndex = 0;
  bool _isLoading = false;

  // Available colors for categories
  static const List<Color> _availableColors = [
    Color(0xFF4A90E2),
    Color(0xFFFF9F43),
    Color(0xFFFF6B6B),
    Color(0xFF5F9EE9),
    Color(0xFFFFB347),
    Color(0xFF9B59B6),
    Color(0xFF2ECC71),
    Color(0xFF27AE60),
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
    Color(0xFF1ABC9C),
    Color(0xFFF39C12),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF673AB7),
    Color(0xFFFF5722),
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.isExpense;
    
    // Set default icon
    if (IconHelper.allIcons.isNotEmpty) {
      _selectedIcon = IconHelper.allIcons.first;
    }

    // Pre-fill form if editing
    if (widget.isEditMode) {
      final cat = widget.categoryToEdit!;
      _nameController.text = cat.isCustom ? cat.name : cat.nameEn;
      _isExpense = cat.type == TransactionType.expense;
      
      // Set selected icon directly from model
      _selectedIcon = cat.icon;
      
      // Find matching color index
      final colorIndex = _availableColors.indexWhere(
        (color) => color == cat.color
      );
      if (colorIndex >= 0) _selectedColorIndex = colorIndex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditMode ? AppStrings.editCategory : AppStrings.addCategory,
          style: const TextStyle(
            color: Colors.black87,
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
                  });
                },
              ),
            ),

            // Category Name Input
            const Text(
              'Category Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter category name',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Icon Selection
            const Text(
              'Select Icon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildIconSelector(),
            const SizedBox(height: 24),

            // Color Selection
            const Text(
              'Select Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildColorGrid(),
            const SizedBox(height: 32),

            // Preview
            _buildPreview(),
            const SizedBox(height: 32),

            // Save Button
            GradientButton(
              text: 'SAVE CATEGORY',
              onPressed: _saveCategory,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Container(
      height: 300, // Fixed height for scrollable area
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: IconHelper.iconGroups.length,
          itemBuilder: (context, index) {
            final entry = IconHelper.iconGroups.entries.elementAt(index);
            final groupName = entry.key;
            final icons = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8, top: index == 0 ? 0 : 16),
                  child: Text(
                    groupName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: icons.map((icon) {
                    final isSelected = icon.codePoint == _selectedIcon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _availableColors[_selectedColorIndex].withValues(alpha: 0.15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? _availableColors[_selectedColorIndex]
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? _availableColors[_selectedColorIndex]
                              : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_availableColors.length, (index) {
        final isSelected = index == _selectedColorIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedColorIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _availableColors[index],
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _availableColors[index].withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _availableColors[_selectedColorIndex].withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedIcon,
              color: _availableColors[_selectedColorIndex],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _nameController.text.isEmpty
                      ? 'Category Name'
                      : _nameController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isExpense
                  ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                  : AppTheme.incomeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isExpense ? 'Expense' : 'Income',
              style: TextStyle(
                fontSize: 12,
                color: _isExpense ? AppTheme.primaryOrange : AppTheme.incomeColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Please enter a category name');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = CustomCategory(
        id: widget.isEditMode ? widget.categoryToEdit!.id : _db.generateId(),
        name: name,
        iconCodePoint: _selectedIcon.codePoint,
        colorValue: _availableColors[_selectedColorIndex].toARGB32(),
        isExpense: _isExpense,
        createdAt: DateTime.now(),
      );

      await _db.addCustomCategory(category);

      if (mounted) {
        widget.onCategoryAdded?.call();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditMode 
                ? 'Category "$name" updated!' 
                : 'Category "$name" added!'),
            backgroundColor: AppTheme.incomeColor,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save category');
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
