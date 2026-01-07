import 'package:flutter/material.dart';
import '../models/category.dart';
import '../config/theme.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final Function(CategoryModel) onCategorySelected;
  final VoidCallback? onAddNewCategory;
  final Function(CategoryModel)? onEditCategory;
  final Function(CategoryModel)? onDeleteCategory;

  const CategorySelector({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.onAddNewCategory,
    this.onEditCategory,
    this.onDeleteCategory,
  });

  @override
  Widget build(BuildContext context) {
    // Store context to use for bottom sheet
    final rootContext = context;
    
    // Add 1 for the "Add New" button
    final totalItems = categories.length + (onAddNewCategory != null ? 1 : 0);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        // Last item is "Add New" button
        if (onAddNewCategory != null && index == categories.length) {
          return _buildAddNewButton();
        }
        
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        return GestureDetector(
          onTap: () => onCategorySelected(category),
          // Allow long-press for all categories
          onLongPress: (onEditCategory != null || onDeleteCategory != null)
              ? () => _showOptionsMenu(rootContext, category) 
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? category.color.withValues(alpha: 0.2) 
                          : category.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? category.color : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: category.color.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 26,
                    ),
                  ),
                  // Show edit indicator for all categories
                  if (onEditCategory != null || onDeleteCategory != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? category.color : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsMenu(BuildContext outerContext, CategoryModel category) {
    final isDark = Theme.of(outerContext).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: outerContext,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Category header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: category.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  category.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Edit option
            if (onEditCategory != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit_outlined, color: Colors.blue),
                ),
                title: const Text('Edit Category'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onEditCategory?.call(category);
                },
              ),
            // Delete option
            if (onDeleteCategory != null) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outlined, color: Colors.red),
                ),
                title: const Text('Delete Category', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(outerContext, category);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDeleteCategory?.call(category);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewButton() {
    return GestureDetector(
      onTap: onAddNewCategory,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Icon(
              Icons.add,
              color: AppTheme.primaryOrange,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add New',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryOrange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
