import 'package:flutter/material.dart';

/// Supported languages
enum AppLanguage {
  thai,
  english,
  chineseSimplified,
  chineseTraditional,
  japanese,
  korean,
  russian,
}

/// Language configuration
class LanguageConfig {
  final String code;
  final String name;
  final String nativeName;
  final Locale locale;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
  });

  static const Map<AppLanguage, LanguageConfig> languages = {
    AppLanguage.thai: LanguageConfig(
      code: 'th',
      name: 'Thai',
      nativeName: 'ไทย',
      locale: Locale('th'),
    ),
    AppLanguage.english: LanguageConfig(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      locale: Locale('en'),
    ),
    AppLanguage.chineseSimplified: LanguageConfig(
      code: 'zh_CN',
      name: 'Chinese Simplified',
      nativeName: '简体中文',
      locale: Locale('zh', 'CN'),
    ),
    AppLanguage.chineseTraditional: LanguageConfig(
      code: 'zh_TW',
      name: 'Chinese Traditional',
      nativeName: '繁體中文',
      locale: Locale('zh', 'TW'),
    ),
    AppLanguage.japanese: LanguageConfig(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      locale: Locale('ja'),
    ),
    AppLanguage.korean: LanguageConfig(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      locale: Locale('ko'),
    ),
    AppLanguage.russian: LanguageConfig(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      locale: Locale('ru'),
    ),
  };
}

/// App translations
class AppStrings {
  static AppLanguage _currentLanguage = AppLanguage.english;
  
  static AppLanguage get currentLanguage => _currentLanguage;
  
  static void setLanguage(AppLanguage language) {
    _currentLanguage = language;
  }

  // ========== Navigation ==========
  static String get home => _t({
    AppLanguage.english: 'Home',
    AppLanguage.thai: 'หน้าหลัก',
    AppLanguage.chineseSimplified: '首页',
    AppLanguage.chineseTraditional: '首頁',
    AppLanguage.japanese: 'ホーム',
    AppLanguage.korean: '홈',
    AppLanguage.russian: 'Главная',
  });

  static String get stats => _t({
    AppLanguage.english: 'Stats',
    AppLanguage.thai: 'สถิติ',
    AppLanguage.chineseSimplified: '统计',
    AppLanguage.chineseTraditional: '統計',
    AppLanguage.japanese: '統計',
    AppLanguage.korean: '통계',
    AppLanguage.russian: 'Статистика',
  });

  static String get profile => _t({
    AppLanguage.english: 'Profile',
    AppLanguage.thai: 'โปรไฟล์',
    AppLanguage.chineseSimplified: '个人资料',
    AppLanguage.chineseTraditional: '個人資料',
    AppLanguage.japanese: 'プロフィール',
    AppLanguage.korean: '프로필',
    AppLanguage.russian: 'Профиль',
  });

  static String get report => _t({
    AppLanguage.english: 'Report',
    AppLanguage.thai: 'รายงาน',
    AppLanguage.chineseSimplified: '报告',
    AppLanguage.chineseTraditional: '報告',
    AppLanguage.japanese: 'レポート',
    AppLanguage.korean: '보고서',
    AppLanguage.russian: 'Отчёт',
  });

  // ========== Dashboard ==========
  static String get welcome => _t({
    AppLanguage.english: 'Welcome!',
    AppLanguage.thai: 'ยินดีต้อนรับ!',
    AppLanguage.chineseSimplified: '欢迎！',
    AppLanguage.chineseTraditional: '歡迎！',
    AppLanguage.japanese: 'ようこそ！',
    AppLanguage.korean: '환영합니다!',
    AppLanguage.russian: 'Добро пожаловать!',
  });

  static String get goodMorning => _t({
    AppLanguage.english: 'Good Morning',
    AppLanguage.thai: 'สวัสดีตอนเช้า',
    AppLanguage.chineseSimplified: '早上好',
    AppLanguage.chineseTraditional: '早安',
    AppLanguage.japanese: 'おはようございます',
    AppLanguage.korean: '좋은 아침이에요',
    AppLanguage.russian: 'Доброе утро',
  });

  static String get goodAfternoon => _t({
    AppLanguage.english: 'Good Afternoon',
    AppLanguage.thai: 'สวัสดีตอนบ่าย',
    AppLanguage.chineseSimplified: '下午好',
    AppLanguage.chineseTraditional: '午安',
    AppLanguage.japanese: 'こんにちは',
    AppLanguage.korean: '좋은 오후에요',
    AppLanguage.russian: 'Добрый день',
  });

  static String get goodEvening => _t({
    AppLanguage.english: 'Good Evening',
    AppLanguage.thai: 'สวัสดีตอนเย็น',
    AppLanguage.chineseSimplified: '晚上好',
    AppLanguage.chineseTraditional: '晚安',
    AppLanguage.japanese: 'こんばんは',
    AppLanguage.korean: '좋은 저녁이에요',
    AppLanguage.russian: 'Добрый вечер',
  });

  static String get totalBalance => _t({
    AppLanguage.english: 'Total Balance',
    AppLanguage.thai: 'ยอดคงเหลือ',
    AppLanguage.chineseSimplified: '总余额',
    AppLanguage.chineseTraditional: '總餘額',
    AppLanguage.japanese: '総残高',
    AppLanguage.korean: '총 잔액',
    AppLanguage.russian: 'Общий баланс',
  });

  static String get income => _t({
    AppLanguage.english: 'Income',
    AppLanguage.thai: 'รายรับ',
    AppLanguage.chineseSimplified: '收入',
    AppLanguage.chineseTraditional: '收入',
    AppLanguage.japanese: '収入',
    AppLanguage.korean: '수입',
    AppLanguage.russian: 'Доход',
  });

  static String get expense => _t({
    AppLanguage.english: 'Expense',
    AppLanguage.thai: 'รายจ่าย',
    AppLanguage.chineseSimplified: '支出',
    AppLanguage.chineseTraditional: '支出',
    AppLanguage.japanese: '支出',
    AppLanguage.korean: '지출',
    AppLanguage.russian: 'Расход',
  });

  static String get recentTransactions => _t({
    AppLanguage.english: 'Recent Transactions',
    AppLanguage.thai: 'รายการล่าสุด',
    AppLanguage.chineseSimplified: '最近交易',
    AppLanguage.chineseTraditional: '最近交易',
    AppLanguage.japanese: '最近の取引',
    AppLanguage.korean: '최근 거래',
    AppLanguage.russian: 'Последние транзакции',
  });

  static String get todayTransactions => _t({
    AppLanguage.english: "Today's Transactions",
    AppLanguage.thai: 'รายการวันนี้',
    AppLanguage.chineseSimplified: '今日交易',
    AppLanguage.chineseTraditional: '今日交易',
    AppLanguage.japanese: '今日の取引',
    AppLanguage.korean: '오늘의 거래',
    AppLanguage.russian: 'Transactions за сегодня',
  });

  static String get noTransactions => _t({
    AppLanguage.english: 'No transactions yet',
    AppLanguage.thai: 'ยังไม่มีรายการ',
    AppLanguage.chineseSimplified: '暂无交易',
    AppLanguage.chineseTraditional: '暫無交易',
    AppLanguage.japanese: 'まだ取引がありません',
    AppLanguage.korean: '아직 거래가 없습니다',
    AppLanguage.russian: 'Пока нет транзакций',
  });

  // ========== Add Transaction ==========
  static String get addExpense => _t({
    AppLanguage.english: 'Add Expense',
    AppLanguage.thai: 'เพิ่มรายจ่าย',
    AppLanguage.chineseSimplified: '添加支出',
    AppLanguage.chineseTraditional: '新增支出',
    AppLanguage.japanese: '支出を追加',
    AppLanguage.korean: '지출 추가',
    AppLanguage.russian: 'Добавить расход',
  });

  static String get addIncome => _t({
    AppLanguage.english: 'Add Income',
    AppLanguage.thai: 'เพิ่มรายรับ',
    AppLanguage.chineseSimplified: '添加收入',
    AppLanguage.chineseTraditional: '新增收入',
    AppLanguage.japanese: '収入を追加',
    AppLanguage.korean: '수입 추가',
    AppLanguage.russian: 'Добавить доход',
  });

  static String get category => _t({
    AppLanguage.english: 'Category',
    AppLanguage.thai: 'หมวดหมู่',
    AppLanguage.chineseSimplified: '类别',
    AppLanguage.chineseTraditional: '類別',
    AppLanguage.japanese: 'カテゴリ',
    AppLanguage.korean: '카테고리',
    AppLanguage.russian: 'Категория',
  });

  static String get note => _t({
    AppLanguage.english: 'Note',
    AppLanguage.thai: 'บันทึก',
    AppLanguage.chineseSimplified: '备注',
    AppLanguage.chineseTraditional: '備註',
    AppLanguage.japanese: 'メモ',
    AppLanguage.korean: '메모',
    AppLanguage.russian: 'Заметка',
  });

  static String get date => _t({
    AppLanguage.english: 'Date',
    AppLanguage.thai: 'วันที่',
    AppLanguage.chineseSimplified: '日期',
    AppLanguage.chineseTraditional: '日期',
    AppLanguage.japanese: '日付',
    AppLanguage.korean: '날짜',
    AppLanguage.russian: 'Дата',
  });

  static String get save => _t({
    AppLanguage.english: 'Save',
    AppLanguage.thai: 'บันทึก',
    AppLanguage.chineseSimplified: '保存',
    AppLanguage.chineseTraditional: '儲存',
    AppLanguage.japanese: '保存',
    AppLanguage.korean: '저장',
    AppLanguage.russian: 'Сохранить',
  });

  static String get cancel => _t({
    AppLanguage.english: 'Cancel',
    AppLanguage.thai: 'ยกเลิก',
    AppLanguage.chineseSimplified: '取消',
    AppLanguage.chineseTraditional: '取消',
    AppLanguage.japanese: 'キャンセル',
    AppLanguage.korean: '취소',
    AppLanguage.russian: 'Отмена',
  });

  static String get all => _t({
    AppLanguage.english: 'All',
    AppLanguage.thai: 'ทั้งหมด',
    AppLanguage.chineseSimplified: '全部',
    AppLanguage.chineseTraditional: '全部',
    AppLanguage.japanese: 'すべて',
    AppLanguage.korean: '전체',
    AppLanguage.russian: 'Все',
  });

  static String get select => _t({
    AppLanguage.english: 'Select',
    AppLanguage.thai: 'เลือก',
    AppLanguage.chineseSimplified: '选择',
    AppLanguage.chineseTraditional: '選擇',
    AppLanguage.japanese: '選択',
    AppLanguage.korean: '선택',
    AppLanguage.russian: 'Выбрать',
  });

  // ========== Profile ==========
  static String get editName => _t({
    AppLanguage.english: 'Edit Name',
    AppLanguage.thai: 'แก้ไขชื่อ',
    AppLanguage.chineseSimplified: '编辑名称',
    AppLanguage.chineseTraditional: '編輯名稱',
    AppLanguage.japanese: '名前を編集',
    AppLanguage.korean: '이름 편집',
    AppLanguage.russian: 'Изменить имя',
  });

  static String get currency => _t({
    AppLanguage.english: 'Currency',
    AppLanguage.thai: 'สกุลเงิน',
    AppLanguage.chineseSimplified: '货币',
    AppLanguage.chineseTraditional: '貨幣',
    AppLanguage.japanese: '通貨',
    AppLanguage.korean: '통화',
    AppLanguage.russian: 'Валюта',
  });

  static String get monthlyBudget => _t({
    AppLanguage.english: 'Monthly Budget',
    AppLanguage.thai: 'งบประมาณรายเดือน',
    AppLanguage.chineseSimplified: '月度预算',
    AppLanguage.chineseTraditional: '月度預算',
    AppLanguage.japanese: '毎月の予算',
    AppLanguage.korean: '월간 예산',
    AppLanguage.russian: 'Месячный бюджет',
  });

  static String get recurringTransactions => _t({
    AppLanguage.english: 'Recurring Transactions',
    AppLanguage.thai: 'รายการประจำ',
    AppLanguage.chineseSimplified: '定期交易',
    AppLanguage.chineseTraditional: '定期交易',
    AppLanguage.japanese: '定期取引',
    AppLanguage.korean: '반복 거래',
    AppLanguage.russian: 'Регулярные транзакции',
  });

  static String get avatarColor => _t({
    AppLanguage.english: 'Avatar Color',
    AppLanguage.thai: 'สีอวาตาร์',
    AppLanguage.chineseSimplified: '头像颜色',
    AppLanguage.chineseTraditional: '頭像顏色',
    AppLanguage.japanese: 'アバターの色',
    AppLanguage.korean: '아바타 색상',
    AppLanguage.russian: 'Цвет аватара',
  });

  static String get darkMode => _t({
    AppLanguage.english: 'Dark Mode',
    AppLanguage.thai: 'โหมดมืด',
    AppLanguage.chineseSimplified: '深色模式',
    AppLanguage.chineseTraditional: '深色模式',
    AppLanguage.japanese: 'ダークモード',
    AppLanguage.korean: '다크 모드',
    AppLanguage.russian: 'Тёмная тема',
  });

  static String get language => _t({
    AppLanguage.english: 'Language',
    AppLanguage.thai: 'ภาษา',
    AppLanguage.chineseSimplified: '语言',
    AppLanguage.chineseTraditional: '語言',
    AppLanguage.japanese: '言語',
    AppLanguage.korean: '언어',
    AppLanguage.russian: 'Язык',
  });

  static String get about => _t({
    AppLanguage.english: 'About',
    AppLanguage.thai: 'เกี่ยวกับ',
    AppLanguage.chineseSimplified: '关于',
    AppLanguage.chineseTraditional: '關於',
    AppLanguage.japanese: '概要',
    AppLanguage.korean: '정보',
    AppLanguage.russian: 'О приложении',
  });

  // ========== Budget ==========
  static String get spent => _t({
    AppLanguage.english: 'Spent',
    AppLanguage.thai: 'ใช้ไป',
    AppLanguage.chineseSimplified: '已花费',
    AppLanguage.chineseTraditional: '已花費',
    AppLanguage.japanese: '使用額',
    AppLanguage.korean: '사용',
    AppLanguage.russian: 'Потрачено',
  });

  static String get limit => _t({
    AppLanguage.english: 'Limit',
    AppLanguage.thai: 'งบประมาณ',
    AppLanguage.chineseSimplified: '限额',
    AppLanguage.chineseTraditional: '限額',
    AppLanguage.japanese: '上限',
    AppLanguage.korean: '한도',
    AppLanguage.russian: 'Лимит',
  });

  static String get remaining => _t({
    AppLanguage.english: 'Remaining',
    AppLanguage.thai: 'เหลือ',
    AppLanguage.chineseSimplified: '剩余',
    AppLanguage.chineseTraditional: '剩餘',
    AppLanguage.japanese: '残り',
    AppLanguage.korean: '남음',
    AppLanguage.russian: 'Осталось',
  });

  static String get overBudget => _t({
    AppLanguage.english: 'Over Budget',
    AppLanguage.thai: 'เกินงบ',
    AppLanguage.chineseSimplified: '超预算',
    AppLanguage.chineseTraditional: '超預算',
    AppLanguage.japanese: '予算超過',
    AppLanguage.korean: '예산 초과',
    AppLanguage.russian: 'Превышен бюджет',
  });

  static String get frequency => _t({
    AppLanguage.english: 'Frequency',
    AppLanguage.thai: 'ความถี่',
    AppLanguage.chineseSimplified: '频率',
    AppLanguage.chineseTraditional: '頻率',
    AppLanguage.japanese: '頻度',
    AppLanguage.korean: '빈도',
    AppLanguage.russian: 'Частота',
  });

  static String get setBudget => _t({
    AppLanguage.english: 'Set Monthly Budget',
    AppLanguage.thai: 'ตั้งงบประมาณรายเดือน',
    AppLanguage.chineseSimplified: '设置月度预算',
    AppLanguage.chineseTraditional: '設置月度預算',
    AppLanguage.japanese: '毎月の予算を設定',
    AppLanguage.korean: '월간 예산 설정',
    AppLanguage.russian: 'Установить месячный бюджет',
  });

  // ========== Recurring ==========
  static String get daily => _t({
    AppLanguage.english: 'Daily',
    AppLanguage.thai: 'รายวัน',
    AppLanguage.chineseSimplified: '每日',
    AppLanguage.chineseTraditional: '每日',
    AppLanguage.japanese: '毎日',
    AppLanguage.korean: '매일',
    AppLanguage.russian: 'Ежедневно',
  });

  static String get weekly => _t({
    AppLanguage.english: 'Weekly',
    AppLanguage.thai: 'รายสัปดาห์',
    AppLanguage.chineseSimplified: '每周',
    AppLanguage.chineseTraditional: '每週',
    AppLanguage.japanese: '毎週',
    AppLanguage.korean: '매주',
    AppLanguage.russian: 'Еженедельно',
  });

  static String get monthly => _t({
    AppLanguage.english: 'Monthly',
    AppLanguage.thai: 'รายเดือน',
    AppLanguage.chineseSimplified: '每月',
    AppLanguage.chineseTraditional: '每月',
    AppLanguage.japanese: '毎月',
    AppLanguage.korean: '매월',
    AppLanguage.russian: 'Ежемесячно',
  });

  static String get yearly => _t({
    AppLanguage.english: 'Yearly',
    AppLanguage.thai: 'รายปี',
    AppLanguage.chineseSimplified: '每年',
    AppLanguage.chineseTraditional: '每年',
    AppLanguage.japanese: '毎年',
    AppLanguage.korean: '매년',
    AppLanguage.russian: 'Ежегодно',
  });

  static String get addRecurring => _t({
    AppLanguage.english: 'Add Recurring',
    AppLanguage.thai: 'เพิ่มรายการประจำ',
    AppLanguage.chineseSimplified: '添加定期交易',
    AppLanguage.chineseTraditional: '新增定期交易',
    AppLanguage.japanese: '定期取引を追加',
    AppLanguage.korean: '반복 추가',
    AppLanguage.russian: 'Добавить регулярную',
  });

  // ========== Transactions ==========
  static String get transactions => _t({
    AppLanguage.english: 'Transactions',
    AppLanguage.thai: 'รายการ',
    AppLanguage.chineseSimplified: '交易',
    AppLanguage.chineseTraditional: '交易',
    AppLanguage.japanese: '取引',
    AppLanguage.korean: '거래',
    AppLanguage.russian: 'Транзакции',
  });

  static String get today => _t({
    AppLanguage.english: 'Today',
    AppLanguage.thai: 'วันนี้',
    AppLanguage.chineseSimplified: '今天',
    AppLanguage.chineseTraditional: '今天',
    AppLanguage.japanese: '今日',
    AppLanguage.korean: '오늘',
    AppLanguage.russian: 'Сегодня',
  });

  static String get yesterday => _t({
    AppLanguage.english: 'Yesterday',
    AppLanguage.thai: 'เมื่อวาน',
    AppLanguage.chineseSimplified: '昨天',
    AppLanguage.chineseTraditional: '昨天',
    AppLanguage.japanese: '昨日',
    AppLanguage.korean: '어제',
    AppLanguage.russian: 'Вчера',
  });

  static String get noIncomeYet => _t({
    AppLanguage.english: 'No income found',
    AppLanguage.thai: 'ยังไม่มีรายรับ',
    AppLanguage.chineseSimplified: '暂无收入',
    AppLanguage.chineseTraditional: '暫無收入',
    AppLanguage.japanese: '収入がありません',
    AppLanguage.korean: '수입이 없습니다',
    AppLanguage.russian: 'Доходов нет',
  });

  static String get noData => _t({
    AppLanguage.english: 'No data',
    AppLanguage.thai: 'ไม่มีข้อมูล',
    AppLanguage.chineseSimplified: '暂无数据',
    AppLanguage.chineseTraditional: '暫無數據',
    AppLanguage.japanese: 'データがありません',
    AppLanguage.korean: '데이터 없음',
    AppLanguage.russian: 'Нет данных',
  });

  static String get noDataYet => _t({
    AppLanguage.english: 'No data yet',
    AppLanguage.thai: 'ยังไม่มีข้อมูล',
    AppLanguage.chineseSimplified: '暂无数据',
    AppLanguage.chineseTraditional: '暫無數據',
    AppLanguage.japanese: 'まだデータがありません',
    AppLanguage.korean: '아직 데이터가 없습니다',
    AppLanguage.russian: 'Пока нет данных',
  });

  static String get addCategory => _t({
    AppLanguage.english: 'Add Category',
    AppLanguage.thai: 'เพิ่มหมวดหมู่',
    AppLanguage.chineseSimplified: '添加分类',
    AppLanguage.chineseTraditional: '新增分類',
    AppLanguage.japanese: 'カテゴリを追加',
    AppLanguage.korean: '카테고리 추가',
    AppLanguage.russian: 'Добавить категорию',
  });

  static String get editCategory => _t({
    AppLanguage.english: 'Edit Category',
    AppLanguage.thai: 'แก้ไขหมวดหมู่',
    AppLanguage.chineseSimplified: '编辑分类',
    AppLanguage.chineseTraditional: '編輯分類',
    AppLanguage.japanese: 'カテゴリを編集',
    AppLanguage.korean: '카테고리 편집',
    AppLanguage.russian: 'Редактировать категорию',
  });

  static String get editExpense => _t({
    AppLanguage.english: 'Edit Expense',
    AppLanguage.thai: 'แก้ไขรายจ่าย',
    AppLanguage.chineseSimplified: '编辑支出',
    AppLanguage.chineseTraditional: '編輯支出',
    AppLanguage.japanese: '支出を編集',
    AppLanguage.korean: '지출 편집',
    AppLanguage.russian: 'Редактировать расход',
  });

  static String get editIncome => _t({
    AppLanguage.english: 'Edit Income',
    AppLanguage.thai: 'แก้ไขรายรับ',
    AppLanguage.chineseSimplified: '编辑收入',
    AppLanguage.chineseTraditional: '編輯收入',
    AppLanguage.japanese: '収入を編集',
    AppLanguage.korean: '수입 편집',
    AppLanguage.russian: 'Редактировать доход',
  });

  static String get addNote => _t({
    AppLanguage.english: 'Add note',
    AppLanguage.thai: 'เพิ่มบันทึก',
    AppLanguage.chineseSimplified: '添加备注',
    AppLanguage.chineseTraditional: '新增備註',
    AppLanguage.japanese: 'メモを追加',
    AppLanguage.korean: '메모 추가',
    AppLanguage.russian: 'Добавить заметку',
  });

  static String get deleteRecurring => _t({
    AppLanguage.english: 'Delete Recurring?',
    AppLanguage.thai: 'ลบรายการประจำ?',
    AppLanguage.chineseSimplified: '删除定期交易？',
    AppLanguage.chineseTraditional: '刪除定期交易？',
    AppLanguage.japanese: '定期取引を削除しますか？',
    AppLanguage.korean: '반복 거래를 삭제하시겠습니까?',
    AppLanguage.russian: 'Удалить регулярную?',
  });

  static String get editRecurring => _t({
    AppLanguage.english: 'Edit Recurring',
    AppLanguage.thai: 'แก้ไขรายการประจำ',
    AppLanguage.chineseSimplified: '编辑定期交易',
    AppLanguage.chineseTraditional: '編輯定期交易',
    AppLanguage.japanese: '定期取引を編集',
    AppLanguage.korean: '반복 거래 편집',
    AppLanguage.russian: 'Редактировать регулярную',
  });

  static String get topExpense => _t({
    AppLanguage.english: 'Top Expense',
    AppLanguage.thai: 'รายจ่ายสูงสุด',
    AppLanguage.chineseSimplified: '最高支出',
    AppLanguage.chineseTraditional: '最高支出',
    AppLanguage.japanese: 'トップ支出',
    AppLanguage.korean: '최고 지출',
    AppLanguage.russian: 'Топ расходов',
  });

  static String get topIncome => _t({
    AppLanguage.english: 'Top Income',
    AppLanguage.thai: 'รายรับสูงสุด',
    AppLanguage.chineseSimplified: '最高收入',
    AppLanguage.chineseTraditional: '最高收入',
    AppLanguage.japanese: 'トップ収入',
    AppLanguage.korean: '최고 수입',
    AppLanguage.russian: 'Топ доходов',
  });

  static String get leftAmount => _t({
    AppLanguage.english: 'Left',
    AppLanguage.thai: 'เหลือ',
    AppLanguage.chineseSimplified: '剩余',
    AppLanguage.chineseTraditional: '剩餘',
    AppLanguage.japanese: '残り',
    AppLanguage.korean: '남음',
    AppLanguage.russian: 'Осталось',
  });

  static String get overAmount => _t({
    AppLanguage.english: 'Over',
    AppLanguage.thai: 'เกิน',
    AppLanguage.chineseSimplified: '超出',
    AppLanguage.chineseTraditional: '超出',
    AppLanguage.japanese: '超過',
    AppLanguage.korean: '초과',
    AppLanguage.russian: 'Превышено',
  });

  static String get addFirstTransaction => _t({
    AppLanguage.english: 'Add your first transaction\nby tapping the + button',
    AppLanguage.thai: 'เพิ่มรายการแรกของคุณ\nโดยกดปุ่ม +',
    AppLanguage.chineseSimplified: '点击 + 按钮\n添加您的第一笔交易',
    AppLanguage.chineseTraditional: '點擊 + 按鈕\n新增您的第一筆交易',
    AppLanguage.japanese: '+ ボタンをタップして\n最初の取引を追加',
    AppLanguage.korean: '+ 버튼을 눌러\n첫 거래를 추가하세요',
    AppLanguage.russian: 'Добавьте первую транзакцию\nнажав кнопку +',
  });

  static String get addRecurringDesc => _t({
    AppLanguage.english: 'Add recurring payments like rent, subscriptions',
    AppLanguage.thai: 'เพิ่มรายการประจำ เช่น ค่าเช่า ค่าสมาชิก',
    AppLanguage.chineseSimplified: '添加定期付款，如房租、订阅',
    AppLanguage.chineseTraditional: '新增定期付款，如房租、訂閱',
    AppLanguage.japanese: '家賃、サブスクリプションなどの定期支払いを追加',
    AppLanguage.korean: '집세, 구독료 등 반복 결제 추가',
    AppLanguage.russian: 'Добавьте регулярные платежи: аренда, подписки',
  });

  static String get noRecurringTransactions => _t({
    AppLanguage.english: 'No Recurring Transactions',
    AppLanguage.thai: 'ยังไม่มีรายการประจำ',
    AppLanguage.chineseSimplified: '暂无定期交易',
    AppLanguage.chineseTraditional: '暫無定期交易',
    AppLanguage.japanese: '定期取引がありません',
    AppLanguage.korean: '반복 거래가 없습니다',
    AppLanguage.russian: 'Нет регулярных транзакций',
  });

  static String get addExpenses => _t({
    AppLanguage.english: 'Add Expenses',
    AppLanguage.thai: 'เพิ่มรายจ่าย',
    AppLanguage.chineseSimplified: '添加支出',
    AppLanguage.chineseTraditional: '新增支出',
    AppLanguage.japanese: '支出を追加',
    AppLanguage.korean: '지출 추가',
    AppLanguage.russian: 'Добавить расходы',
  });

  // ========== Errors ==========
  static String get pleaseEnterAmount => _t({
    AppLanguage.english: 'Please enter an amount',
    AppLanguage.thai: 'กรุณาใส่จำนวนเงิน',
    AppLanguage.chineseSimplified: '请输入金额',
    AppLanguage.chineseTraditional: '請輸入金額',
    AppLanguage.japanese: '金額を入力してください',
    AppLanguage.korean: '금액을 입력하세요',
    AppLanguage.russian: 'Введите сумму',
  });

  static String get pleaseSelectCategory => _t({
    AppLanguage.english: 'Please select a category',
    AppLanguage.thai: 'กรุณาเลือกหมวดหมู่',
    AppLanguage.chineseSimplified: '请选择类别',
    AppLanguage.chineseTraditional: '請選擇類別',
    AppLanguage.japanese: 'カテゴリを選択してください',
    AppLanguage.korean: '카테고리를 선택하세요',
    AppLanguage.russian: 'Выберите категорию',
  });

  // ========== Common ==========
  static String get delete => _t({
    AppLanguage.english: 'Delete',
    AppLanguage.thai: 'ลบ',
    AppLanguage.chineseSimplified: '删除',
    AppLanguage.chineseTraditional: '刪除',
    AppLanguage.japanese: '削除',
    AppLanguage.korean: '삭제',
    AppLanguage.russian: 'Удалить',
  });

  static String get edit => _t({
    AppLanguage.english: 'Edit',
    AppLanguage.thai: 'แก้ไข',
    AppLanguage.chineseSimplified: '编辑',
    AppLanguage.chineseTraditional: '編輯',
    AppLanguage.japanese: '編集',
    AppLanguage.korean: '편집',
    AppLanguage.russian: 'Редактировать',
  });

  static String get done => _t({
    AppLanguage.english: 'Done',
    AppLanguage.thai: 'เสร็จสิ้น',
    AppLanguage.chineseSimplified: '完成',
    AppLanguage.chineseTraditional: '完成',
    AppLanguage.japanese: '完了',
    AppLanguage.korean: '완료',
    AppLanguage.russian: 'Готово',
  });

  static String get on => _t({
    AppLanguage.english: 'On',
    AppLanguage.thai: 'เปิด',
    AppLanguage.chineseSimplified: '开',
    AppLanguage.chineseTraditional: '開',
    AppLanguage.japanese: 'オン',
    AppLanguage.korean: '켜짐',
    AppLanguage.russian: 'Вкл',
  });

  static String get off => _t({
    AppLanguage.english: 'Off',
    AppLanguage.thai: 'ปิด',
    AppLanguage.chineseSimplified: '关',
    AppLanguage.chineseTraditional: '關',
    AppLanguage.japanese: 'オフ',
    AppLanguage.korean: '꺼짐',
    AppLanguage.russian: 'Выкл',
  });

  // ========== Categories - Expense ==========
  static String get categoryFood => _t({
    AppLanguage.english: 'Food',
    AppLanguage.thai: 'อาหาร',
    AppLanguage.chineseSimplified: '餐饮',
    AppLanguage.chineseTraditional: '餐飲',
    AppLanguage.japanese: '食費',
    AppLanguage.korean: '식비',
    AppLanguage.russian: 'Еда',
  });

  static String get categoryShopping => _t({
    AppLanguage.english: 'Shopping',
    AppLanguage.thai: 'ช้อปปิ้ง',
    AppLanguage.chineseSimplified: '购物',
    AppLanguage.chineseTraditional: '購物',
    AppLanguage.japanese: 'ショッピング',
    AppLanguage.korean: '쇼핑',
    AppLanguage.russian: 'Покупки',
  });

  static String get categoryEntertainment => _t({
    AppLanguage.english: 'Entertainment',
    AppLanguage.thai: 'บันเทิง',
    AppLanguage.chineseSimplified: '娱乐',
    AppLanguage.chineseTraditional: '娛樂',
    AppLanguage.japanese: '娯楽',
    AppLanguage.korean: '엔터테인먼트',
    AppLanguage.russian: 'Развлечения',
  });

  static String get categoryTravel => _t({
    AppLanguage.english: 'Travel',
    AppLanguage.thai: 'เดินทาง',
    AppLanguage.chineseSimplified: '旅行',
    AppLanguage.chineseTraditional: '旅行',
    AppLanguage.japanese: '旅行',
    AppLanguage.korean: '여행',
    AppLanguage.russian: 'Путешествия',
  });

  static String get categoryHome => _t({
    AppLanguage.english: 'Home',
    AppLanguage.thai: 'ค่าบ้าน',
    AppLanguage.chineseSimplified: '房租',
    AppLanguage.chineseTraditional: '房租',
    AppLanguage.japanese: '住居費',
    AppLanguage.korean: '주거',
    AppLanguage.russian: 'Жильё',
  });

  static String get categoryPet => _t({
    AppLanguage.english: 'Pet',
    AppLanguage.thai: 'สัตว์เลี้ยง',
    AppLanguage.chineseSimplified: '宠物',
    AppLanguage.chineseTraditional: '寵物',
    AppLanguage.japanese: 'ペット',
    AppLanguage.korean: '반려동물',
    AppLanguage.russian: 'Питомцы',
  });

  static String get categoryRecharge => _t({
    AppLanguage.english: 'Recharge',
    AppLanguage.thai: 'เติมเงิน',
    AppLanguage.chineseSimplified: '充值',
    AppLanguage.chineseTraditional: '充值',
    AppLanguage.japanese: 'チャージ',
    AppLanguage.korean: '충전',
    AppLanguage.russian: 'Пополнение',
  });

  static String get categoryOther => _t({
    AppLanguage.english: 'Other',
    AppLanguage.thai: 'อื่นๆ',
    AppLanguage.chineseSimplified: '其他',
    AppLanguage.chineseTraditional: '其他',
    AppLanguage.japanese: 'その他',
    AppLanguage.korean: '기타',
    AppLanguage.russian: 'Другое',
  });

  // ========== Categories - Income ==========
  static String get categorySalary => _t({
    AppLanguage.english: 'Salary',
    AppLanguage.thai: 'เงินเดือน',
    AppLanguage.chineseSimplified: '工资',
    AppLanguage.chineseTraditional: '薪資',
    AppLanguage.japanese: '給料',
    AppLanguage.korean: '급여',
    AppLanguage.russian: 'Зарплата',
  });

  static String get categoryBonus => _t({
    AppLanguage.english: 'Bonus',
    AppLanguage.thai: 'โบนัส',
    AppLanguage.chineseSimplified: '奖金',
    AppLanguage.chineseTraditional: '獎金',
    AppLanguage.japanese: 'ボーナス',
    AppLanguage.korean: '보너스',
    AppLanguage.russian: 'Бонус',
  });

  static String get categoryInvestment => _t({
    AppLanguage.english: 'Investment',
    AppLanguage.thai: 'การลงทุน',
    AppLanguage.chineseSimplified: '投资',
    AppLanguage.chineseTraditional: '投資',
    AppLanguage.japanese: '投資',
    AppLanguage.korean: '투자',
    AppLanguage.russian: 'Инвестиции',
  });

  static String get categoryFreelance => _t({
    AppLanguage.english: 'Freelance',
    AppLanguage.thai: 'ฟรีแลนซ์',
    AppLanguage.chineseSimplified: '自由职业',
    AppLanguage.chineseTraditional: '自由工作',
    AppLanguage.japanese: 'フリーランス',
    AppLanguage.korean: '프리랜서',
    AppLanguage.russian: 'Фриланс',
  });

  // ========== Category Budget Strings ==========
  
  static String get categoryBudget => _t({
    AppLanguage.english: 'Expenses by Category',
    AppLanguage.thai: 'รายจ่ายตามหมวดหมู่',
    AppLanguage.chineseSimplified: '按分类支出',
    AppLanguage.chineseTraditional: '按分類支出',
    AppLanguage.japanese: 'カテゴリ別支出',
    AppLanguage.korean: '카테고리별 지출',
    AppLanguage.russian: 'Расходы по категориям',
  });

  static String get setCategoryBudget => _t({
    AppLanguage.english: 'Set Category Budget',
    AppLanguage.thai: 'ตั้งงบประมาณหมวดหมู่',
    AppLanguage.chineseSimplified: '设置分类预算',
    AppLanguage.chineseTraditional: '設置分類預算',
    AppLanguage.japanese: 'カテゴリ予算を設定',
    AppLanguage.korean: '카테고리 예산 설정',
    AppLanguage.russian: 'Установить бюджет категории',
  });

  static String get setCategoryBudgetDesc => _t({
    AppLanguage.english: 'Set spending limits for each category',
    AppLanguage.thai: 'กำหนดวงเงินสำหรับแต่ละหมวดหมู่',
    AppLanguage.chineseSimplified: '为每个分类设置支出限额',
    AppLanguage.chineseTraditional: '為每個分類設置支出限額',
    AppLanguage.japanese: '各カテゴリに支出制限を設定',
    AppLanguage.korean: '각 카테고리의 지출 한도 설정',
    AppLanguage.russian: 'Установите лимиты расходов для каждой категории',
  });

  static String get addCategoryBudget => _t({
    AppLanguage.english: 'Add Category Budget',
    AppLanguage.thai: 'เพิ่มงบประมาณหมวดหมู่',
    AppLanguage.chineseSimplified: '添加分类预算',
    AppLanguage.chineseTraditional: '添加分類預算',
    AppLanguage.japanese: 'カテゴリ予算を追加',
    AppLanguage.korean: '카테고리 예산 추가',
    AppLanguage.russian: 'Добавить бюджет категории',
  });

  static String get editCategoryBudget => _t({
    AppLanguage.english: 'Edit Category Budget',
    AppLanguage.thai: 'แก้ไขงบประมาณหมวดหมู่',
    AppLanguage.chineseSimplified: '编辑分类预算',
    AppLanguage.chineseTraditional: '編輯分類預算',
    AppLanguage.japanese: 'カテゴリ予算を編集',
    AppLanguage.korean: '카테고리 예산 편집',
    AppLanguage.russian: 'Редактировать бюджет категории',
  });

  static String get allCategoryBudgets => _t({
    AppLanguage.english: 'All Category Budgets',
    AppLanguage.thai: 'งบประมาณหมวดหมู่ทั้งหมด',
    AppLanguage.chineseSimplified: '所有分类预算',
    AppLanguage.chineseTraditional: '所有分類預算',
    AppLanguage.japanese: 'すべてのカテゴリ予算',
    AppLanguage.korean: '모든 카테고리 예산',
    AppLanguage.russian: 'Все бюджеты категорий',
  });

  static String get selectCategory => _t({
    AppLanguage.english: 'Select Category',
    AppLanguage.thai: 'เลือกหมวดหมู่',
    AppLanguage.chineseSimplified: '选择分类',
    AppLanguage.chineseTraditional: '選擇分類',
    AppLanguage.japanese: 'カテゴリを選択',
    AppLanguage.korean: '카테고리 선택',
    AppLanguage.russian: 'Выберите категорию',
  });

  static String get monthlyLimit => _t({
    AppLanguage.english: 'Monthly Limit',
    AppLanguage.thai: 'วงเงินรายเดือน',
    AppLanguage.chineseSimplified: '月度限额',
    AppLanguage.chineseTraditional: '月度限額',
    AppLanguage.japanese: '月間制限',
    AppLanguage.korean: '월간 한도',
    AppLanguage.russian: 'Месячный лимит',
  });

  static String get deleteBudget => _t({
    AppLanguage.english: 'Delete Budget',
    AppLanguage.thai: 'ลบงบประมาณ',
    AppLanguage.chineseSimplified: '删除预算',
    AppLanguage.chineseTraditional: '刪除預算',
    AppLanguage.japanese: '予算を削除',
    AppLanguage.korean: '예산 삭제',
    AppLanguage.russian: 'Удалить бюджет',
  });

  static String get budget => _t({
    AppLanguage.english: 'Budget',
    AppLanguage.thai: 'งบประมาณ',
    AppLanguage.chineseSimplified: '预算',
    AppLanguage.chineseTraditional: '預算',
    AppLanguage.japanese: '予算',
    AppLanguage.korean: '예산',
    AppLanguage.russian: 'Бюджет',
  });

  static String get noBudgetSet => _t({
    AppLanguage.english: 'No budget set',
    AppLanguage.thai: 'ไม่มีงบประมาณ',
    AppLanguage.chineseSimplified: '未设置预算',
    AppLanguage.chineseTraditional: '未設置預算',
    AppLanguage.japanese: '予算未設定',
    AppLanguage.korean: '예산 미설정',
    AppLanguage.russian: 'Бюджет не установлен',
  });

  /// Get category name by ID
  static String getCategoryName(String categoryId) {
    switch (categoryId) {
      case 'food': return categoryFood;
      case 'shopping': return categoryShopping;
      case 'entertainment': return categoryEntertainment;
      case 'travel': return categoryTravel;
      case 'home': return categoryHome;
      case 'pet': return categoryPet;
      case 'recharge': return categoryRecharge;
      case 'other_expense': return categoryOther;
      case 'salary': return categorySalary;
      case 'bonus': return categoryBonus;
      case 'investment': return categoryInvestment;
      case 'freelance': return categoryFreelance;
      case 'other_income': return categoryOther;
      default: return categoryId; // For custom categories, return as-is
    }
  }

  // ========== Report ==========
  static String get expenseByCategory => _t({
    AppLanguage.english: 'Expense by Category',
    AppLanguage.thai: 'สรุปรายจ่ายตามหมวดหมู่',
    AppLanguage.chineseSimplified: '按类别支出',
    AppLanguage.chineseTraditional: '按類別支出',
    AppLanguage.japanese: 'カテゴリ別支出',
    AppLanguage.korean: '카테고리별 지출',
    AppLanguage.russian: 'Расходы по категориям',
  });

  // ========== Period Selection ==========
  static String get day => _t({
    AppLanguage.english: 'Day',
    AppLanguage.thai: 'วัน',
    AppLanguage.chineseSimplified: '日',
    AppLanguage.chineseTraditional: '日',
    AppLanguage.japanese: '日',
    AppLanguage.korean: '일',
    AppLanguage.russian: 'День',
  });

  static String get month => _t({
    AppLanguage.english: 'Month',
    AppLanguage.thai: 'เดือน',
    AppLanguage.chineseSimplified: '月',
    AppLanguage.chineseTraditional: '月',
    AppLanguage.japanese: '月',
    AppLanguage.korean: '월',
    AppLanguage.russian: 'Месяц',
  });

  static String get year => _t({
    AppLanguage.english: 'Year',
    AppLanguage.thai: 'ปี',
    AppLanguage.chineseSimplified: '年',
    AppLanguage.chineseTraditional: '年',
    AppLanguage.japanese: '年',
    AppLanguage.korean: '년',
    AppLanguage.russian: 'Год',
  });

  // ========== Settings/Profile ==========
  static String get selectLanguage => _t({
    AppLanguage.english: 'Select Language',
    AppLanguage.thai: 'เลือกภาษา',
    AppLanguage.chineseSimplified: '选择语言',
    AppLanguage.chineseTraditional: '選擇語言',
    AppLanguage.japanese: '言語を選択',
    AppLanguage.korean: '언어 선택',
    AppLanguage.russian: 'Выберите язык',
  });

  static String get selectCurrency => _t({
    AppLanguage.english: 'Select Currency',
    AppLanguage.thai: 'เลือกสกุลเงิน',
    AppLanguage.chineseSimplified: '选择货币',
    AppLanguage.chineseTraditional: '選擇貨幣',
    AppLanguage.japanese: '通貨を選択',
    AppLanguage.korean: '통화 선택',
    AppLanguage.russian: 'Выберите валюту',
  });

  static String get setMonthlyBudget => _t({
    AppLanguage.english: 'Set Monthly Budget',
    AppLanguage.thai: 'ตั้งงบประมาณรายเดือน',
    AppLanguage.chineseSimplified: '设置月度预算',
    AppLanguage.chineseTraditional: '設置月度預算',
    AppLanguage.japanese: '月間予算を設定',
    AppLanguage.korean: '월간 예산 설정',
    AppLanguage.russian: 'Установить месячный бюджет',
  });

  static String get exceededBudget => _t({
    AppLanguage.english: 'You\'ve exceeded your monthly budget!',
    AppLanguage.thai: 'คุณใช้จ่ายเกินงบประมาณรายเดือนแล้ว!',
    AppLanguage.chineseSimplified: '您已超出月度预算！',
    AppLanguage.chineseTraditional: '您已超出月度預算！',
    AppLanguage.japanese: '月間予算を超過しました！',
    AppLanguage.korean: '월간 예산을 초과했습니다!',
    AppLanguage.russian: 'Вы превысили месячный бюджет!',
  });

  static String get controlSpending => _t({
    AppLanguage.english: 'Control your spending by setting a budget limit',
    AppLanguage.thai: 'ควบคุมการใช้จ่ายด้วยการตั้งวงเงินงบประมาณ',
    AppLanguage.chineseSimplified: '通过设置预算限额来控制支出',
    AppLanguage.chineseTraditional: '透過設置預算限額來控制支出',
    AppLanguage.japanese: '予算限度額を設定して支出を管理',
    AppLanguage.korean: '예산 한도를 설정하여 지출을 관리하세요',
    AppLanguage.russian: 'Контролируйте расходы, установив лимит бюджета',
  });

  static String get setSpendingLimit => _t({
    AppLanguage.english: 'Set a spending limit for this month',
    AppLanguage.thai: 'ตั้งวงเงินใช้จ่ายสำหรับเดือนนี้',
    AppLanguage.chineseSimplified: '设置本月支出限额',
    AppLanguage.chineseTraditional: '設置本月支出限額',
    AppLanguage.japanese: '今月の支出限度額を設定',
    AppLanguage.korean: '이번 달 지출 한도 설정',
    AppLanguage.russian: 'Установите лимит расходов на этот месяц',
  });

  static String get saveBudget => _t({
    AppLanguage.english: 'Save Budget',
    AppLanguage.thai: 'บันทึกงบประมาณ',
    AppLanguage.chineseSimplified: '保存预算',
    AppLanguage.chineseTraditional: '保存預算',
    AppLanguage.japanese: '予算を保存',
    AppLanguage.korean: '예산 저장',
    AppLanguage.russian: 'Сохранить бюджет',
  });

  static String get enterName => _t({
    AppLanguage.english: 'Enter your name',
    AppLanguage.thai: 'กรอกชื่อของคุณ',
    AppLanguage.chineseSimplified: '输入您的名字',
    AppLanguage.chineseTraditional: '輸入您的名字',
    AppLanguage.japanese: '名前を入力',
    AppLanguage.korean: '이름을 입력하세요',
    AppLanguage.russian: 'Введите ваше имя',
  });

  // ========== Category Screen ==========
  static String get categoryName => _t({
    AppLanguage.english: 'Category Name',
    AppLanguage.thai: 'ชื่อหมวดหมู่',
    AppLanguage.chineseSimplified: '分类名称',
    AppLanguage.chineseTraditional: '分類名稱',
    AppLanguage.japanese: 'カテゴリ名',
    AppLanguage.korean: '카테고리 이름',
    AppLanguage.russian: 'Название категории',
  });

  static String get selectIcon => _t({
    AppLanguage.english: 'Select Icon',
    AppLanguage.thai: 'เลือกไอคอน',
    AppLanguage.chineseSimplified: '选择图标',
    AppLanguage.chineseTraditional: '選擇圖標',
    AppLanguage.japanese: 'アイコンを選択',
    AppLanguage.korean: '아이콘 선택',
    AppLanguage.russian: 'Выберите иконку',
  });

  static String get selectColor => _t({
    AppLanguage.english: 'Select Color',
    AppLanguage.thai: 'เลือกสี',
    AppLanguage.chineseSimplified: '选择颜色',
    AppLanguage.chineseTraditional: '選擇顏色',
    AppLanguage.japanese: '色を選択',
    AppLanguage.korean: '색상 선택',
    AppLanguage.russian: 'Выберите цвет',
  });

  static String get preview => _t({
    AppLanguage.english: 'Preview',
    AppLanguage.thai: 'ตัวอย่าง',
    AppLanguage.chineseSimplified: '预览',
    AppLanguage.chineseTraditional: '預覽',
    AppLanguage.japanese: 'プレビュー',
    AppLanguage.korean: '미리보기',
    AppLanguage.russian: 'Предпросмотр',
  });

  static String get saveCategory => _t({
    AppLanguage.english: 'SAVE CATEGORY',
    AppLanguage.thai: 'บันทึกหมวดหมู่',
    AppLanguage.chineseSimplified: '保存分类',
    AppLanguage.chineseTraditional: '保存分類',
    AppLanguage.japanese: 'カテゴリを保存',
    AppLanguage.korean: '카테고리 저장',
    AppLanguage.russian: 'СОХРАНИТЬ КАТЕГОРИЮ',
  });

  static String get enterCategoryName => _t({
    AppLanguage.english: 'Enter category name',
    AppLanguage.thai: 'กรอกชื่อหมวดหมู่',
    AppLanguage.chineseSimplified: '输入分类名称',
    AppLanguage.chineseTraditional: '輸入分類名稱',
    AppLanguage.japanese: 'カテゴリ名を入力',
    AppLanguage.korean: '카테고리 이름 입력',
    AppLanguage.russian: 'Введите название категории',
  });

  static String get pleaseEnterCategoryName => _t({
    AppLanguage.english: 'Please enter a category name',
    AppLanguage.thai: 'กรุณากรอกชื่อหมวดหมู่',
    AppLanguage.chineseSimplified: '请输入分类名称',
    AppLanguage.chineseTraditional: '請輸入分類名稱',
    AppLanguage.japanese: 'カテゴリ名を入力してください',
    AppLanguage.korean: '카테고리 이름을 입력하세요',
    AppLanguage.russian: 'Пожалуйста, введите название категории',
  });

  static String categoryUpdated(String name) => _t({
    AppLanguage.english: 'Category "$name" updated!',
    AppLanguage.thai: 'อัพเดทหมวดหมู่ "$name" แล้ว!',
    AppLanguage.chineseSimplified: '分类"$name"已更新！',
    AppLanguage.chineseTraditional: '分類"$name"已更新！',
    AppLanguage.japanese: 'カテゴリ「$name」が更新されました！',
    AppLanguage.korean: '카테고리 "$name"이(가) 업데이트되었습니다!',
    AppLanguage.russian: 'Категория "$name" обновлена!',
  });

  static String categoryAdded(String name) => _t({
    AppLanguage.english: 'Category "$name" added!',
    AppLanguage.thai: 'เพิ่มหมวดหมู่ "$name" แล้ว!',
    AppLanguage.chineseSimplified: '分类"$name"已添加！',
    AppLanguage.chineseTraditional: '分類"$name"已添加！',
    AppLanguage.japanese: 'カテゴリ「$name」が追加されました！',
    AppLanguage.korean: '카테고리 "$name"이(가) 추가되었습니다!',
    AppLanguage.russian: 'Категория "$name" добавлена!',
  });

  static String get failedToSaveCategory => _t({
    AppLanguage.english: 'Failed to save category',
    AppLanguage.thai: 'บันทึกหมวดหมู่ไม่สำเร็จ',
    AppLanguage.chineseSimplified: '保存分类失败',
    AppLanguage.chineseTraditional: '保存分類失敗',
    AppLanguage.japanese: 'カテゴリの保存に失敗しました',
    AppLanguage.korean: '카테고리 저장 실패',
    AppLanguage.russian: 'Не удалось сохранить категорию',
  });

  static String get paused => _t({
    AppLanguage.english: 'Paused',
    AppLanguage.thai: 'หยุดชั่วคราว',
    AppLanguage.chineseSimplified: '已暂停',
    AppLanguage.chineseTraditional: '已暫停',
    AppLanguage.japanese: '一時停止',
    AppLanguage.korean: '일시중지',
    AppLanguage.russian: 'Приостановлено',
  });

  static String get tapToChangeColor => _t({
    AppLanguage.english: 'Tap to change color',
    AppLanguage.thai: 'แตะเพื่อเปลี่ยนสี',
    AppLanguage.chineseSimplified: '点击更改颜色',
    AppLanguage.chineseTraditional: '點擊更改顏色',
    AppLanguage.japanese: 'タップして色を変更',
    AppLanguage.korean: '탭하여 색상 변경',
    AppLanguage.russian: 'Нажмите для изменения цвета',
  });

  // Helper function
  static String _t(Map<AppLanguage, String> translations) {
    return translations[_currentLanguage] ?? translations[AppLanguage.english] ?? '';
  }
}
