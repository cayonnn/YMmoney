import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../config/theme.dart';
import '../controllers/theme_controller.dart';
import '../controllers/language_controller.dart';
import '../l10n/app_strings.dart';
import 'recurring_transactions_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = DatabaseService();
  late UserProfile _profile;
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  int _selectedColorIndex = 0;
  String _selectedCurrency = '฿';

  // Avatar colors
  static const List<Color> _avatarColors = [
    Color(0xFFFF9A9E),
    Color(0xFFFECFEF),
    Color(0xFF667EEA),
    Color(0xFF4A90E2),
    Color(0xFF27AE60),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFFF39C12),
    Color(0xFF1ABC9C),
    Color(0xFFE91E63),
    Color(0xFF00BCD4),
    Color(0xFF673AB7),
  ];

  // Available currencies
  static const List<Map<String, String>> _currencies = [
    {'symbol': '฿', 'name': 'Thai Baht (THB)'},
    {'symbol': '\$', 'name': 'US Dollar (USD)'},
    {'symbol': '€', 'name': 'Euro (EUR)'},
    {'symbol': '¥', 'name': 'Japanese Yen (JPY)'},
    {'symbol': '元', 'name': 'Chinese Yuan (CNY)'},
    {'symbol': '£', 'name': 'British Pound (GBP)'},
    {'symbol': '₩', 'name': 'Korean Won (KRW)'},
    {'symbol': 'NT\$', 'name': 'Taiwan Dollar (TWD)'},
    {'symbol': '₽', 'name': 'Russian Ruble (RUB)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profile = _db.getUserProfile();
    _nameController.text = _profile.name;
    _selectedCurrency = _profile.currency;
    
    // Find the color index
    final colorIndex = _avatarColors.indexWhere(
      (c) => c.toARGB32() == _profile.avatarColorValue,
    );
    _selectedColorIndex = colorIndex >= 0 ? colorIndex : 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    final totalIncome = _db.getTotalIncome();
    final totalExpense = _db.getTotalExpense();
    final transactionCount = _db.getAllTransactions().length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.profile,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(),
            const SizedBox(height: 24),

            // Stats Card
            _buildStatsCard(totalIncome, totalExpense, transactionCount, formatter),
            const SizedBox(height: 24),

            // Settings List
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (isDark ? AppTheme.cardBackgroundDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: _showAvatarColorPicker,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _avatarColors[_selectedColorIndex],
                    _avatarColors[_selectedColorIndex].withValues(alpha: 0.7),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: _avatarColors[_selectedColorIndex].withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tapToChangeColor,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            _profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Currency: $_selectedCurrency',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(double income, double expense, int count, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total Income', '$_selectedCurrency${formatter.format(income)}'),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          _buildStatItem('Total Expense', '$_selectedCurrency${formatter.format(expense)}'),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
          _buildStatItem('Transactions', '$count'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? (Theme.of(context).brightness == Brightness.dark ? AppTheme.cardBackgroundDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.person_outline,
            title: AppStrings.editName,
            subtitle: _profile.name,
            onTap: _showNameEditor,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.account_balance_wallet_outlined,
            title: AppStrings.monthlyBudget,
            subtitle: _getBudgetSubtitle(),
            onTap: _showBudgetEditor,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.attach_money,
            title: AppStrings.currency,
            subtitle: _selectedCurrency,
            onTap: _showCurrencyPicker,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.repeat,
            title: AppStrings.recurringTransactions,
            subtitle: '',
            onTap: _openRecurringScreen,
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.palette_outlined,
            title: AppStrings.avatarColor,
            subtitle: '',
            onTap: _showAvatarColorPicker,
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _avatarColors[_selectedColorIndex],
                shape: BoxShape.circle,
              ),
            ),
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.language,
            title: AppStrings.language,
            subtitle: _getLanguageName(_profile.languageCode),
            onTap: _showLanguagePicker,
          ),
          _buildDivider(),
          _buildDarkModeToggle(),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: AppStrings.about,
            subtitle: 'Monivy v1.1.0',
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'th': return 'ไทย';
      case 'en': return 'English';
      case 'zh_CN': return '简体中文';
      case 'zh_TW': return '繁體中文';
      case 'ja': return '日本語';
      case 'ko': return '한국어';
      case 'ru': return 'Русский';
      default: return 'English';
    }
  }

  Widget _buildDarkModeToggle() {
    final isDark = _profile.isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppTheme.primaryOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _profile.isDarkMode ? AppStrings.on : AppStrings.off,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isDark,
            activeTrackColor: AppTheme.primaryOrange,
            onChanged: (value) async {
              _profile.isDarkMode = value;
              await _db.updateUserProfile(_profile);
              ThemeController().setDarkMode(value);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  String _getBudgetSubtitle() {
    final budget = _db.getCurrentMonthBudget();
    if (budget == null || budget.monthlyLimit <= 0) {
      return 'Not set';
    }
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$_selectedCurrency${formatter.format(budget.monthlyLimit)}/month';
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryOrange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 68,
      color: Colors.grey.shade100,
    );
  }

  void _showLanguagePicker() {
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'th', 'name': 'Thai', 'native': 'ไทย'},
      {'code': 'zh_CN', 'name': 'Chinese Simplified', 'native': '简体中文'},
      {'code': 'zh_TW', 'name': 'Chinese Traditional', 'native': '繁體中文'},
      {'code': 'ja', 'name': 'Japanese', 'native': '日本語'},
      {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
      {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectLanguage,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = _profile.languageCode == lang['code'];
                  return ListTile(
                    leading: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primaryOrange)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    title: Text(lang['native']!),
                    subtitle: Text(lang['name']!),
                    onTap: () async {
                      _profile.languageCode = lang['code']!;
                      await _profile.save();
                      // Update language globally
                      LanguageController().setLanguageFromCode(lang['code']!);
                      setState(() {});
                      if (mounted) Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _openRecurringScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecurringTransactionsScreen(),
      ),
    );
  }

  void _showNameEditor() {
    _nameController.text = _profile.name;
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
                AppStrings.editName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: AppStrings.enterName,
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
                  onPressed: () async {
                    final newName = _nameController.text.trim();
                    if (newName.isNotEmpty) {
                      _profile.name = newName;
                      await _db.updateUserProfile(_profile);
                      setState(() {});
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetEditor() {
    final currentBudget = _db.getCurrentMonthBudget();
    _budgetController.text = currentBudget != null && currentBudget.monthlyLimit > 0
        ? currentBudget.monthlyLimit.toStringAsFixed(0)
        : '';
    
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
                AppStrings.setMonthlyBudget,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.setSpendingLimit,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _budgetController,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '$_selectedCurrency ',
                  prefixStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                  hintText: '0',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(AppStrings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () async {
                        final budgetText = _budgetController.text.trim();
                        final budget = double.tryParse(budgetText) ?? 0;
                        await _db.setBudget(budget);
                        setState(() {});
                        if (mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(AppStrings.saveBudget),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectCurrency,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  final isSelected = currency['symbol'] == _selectedCurrency;
                  return ListTile(
                    onTap: () async {
                      _selectedCurrency = currency['symbol']!;
                      _profile.currency = _selectedCurrency;
                      await _db.updateUserProfile(_profile);
                      setState(() {});
                      if (mounted) Navigator.pop(ctx);
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryOrange.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          currency['symbol']!,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.primaryOrange : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    title: Text(currency['name']!),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primaryOrange)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Avatar Color',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(_avatarColors.length, (index) {
                final isSelected = index == _selectedColorIndex;
                return GestureDetector(
                  onTap: () async {
                    _selectedColorIndex = index;
                    _profile.avatarColorValue = _avatarColors[index].toARGB32();
                    await _db.updateUserProfile(_profile);
                    setState(() {});
                    if (mounted) Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _avatarColors[index],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _avatarColors[index].withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Monivy'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Version 1.0.0'),
            const SizedBox(height: 8),
            Text(
              'A professional money tracking app built with Flutter.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 Monivy',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
}
