import 'package:carteira_core/carteira_core.dart' as core;
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'home_coordinator.dart';
import 'home_server.dart';

class CategorySummary {
  const CategorySummary({
    required this.label,
    required this.amount,
    required this.formattedAmount,
    required this.share,
  });

  final String label;
  final double amount;
  final String formattedAmount;
  final double share;
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this.server,
    required core.AuthRepository authRepository,
    required core.TransactionRepository transactionRepository,
    required this.coordinator,
    required ValueNotifier<ThemeMode> themeNotifier,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository,
        _themeNotifier = themeNotifier {
    _themeNotifier.addListener(_onThemeChanged);
    _initSessionAndFetch();
  }

  final HomeServer server;
  final core.AuthRepository _authRepository;
  final core.TransactionRepository _transactionRepository;
  final HomeCoordinator coordinator;
  final ValueNotifier<ThemeMode> _themeNotifier;

  final List<MapEntry<String, String>> _months = [];
  String _selectedMonth = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
  core.Summary? _summary;
  List<CategorySummary> _categories = [];
  List<core.Transaction> _transactions = [];
  String _searchQuery = '';
  core.TransactionType? _selectedType;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;

  List<MapEntry<String, String>> get months => _months;
  String get selectedMonth => _selectedMonth;
  core.Summary? get summary => _summary;
  List<CategorySummary> get categories => _categories;
  List<core.Transaction> get transactions => _transactions;
  String get searchQuery => _searchQuery;
  core.TransactionType? get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;
  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  void toggleTheme() {
    _themeNotifier.value = _themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  Future<void> _initSessionAndFetch() async {
    await _authRepository.restore();
    _userName = _authRepository.currentSession?.user.name;
    _initMonths();
  }

  void _initMonths() {
    final now = DateTime.now();
    for (var i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final year = date.year.toString();
      final monthNum = date.month.toString().padLeft(2, '0');
      final key = '$year-$monthNum';

      const monthNames = [
        'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
        'jul', 'ago', 'set', 'out', 'nov', 'dez'
      ];
      final label = '${monthNames[date.month - 1]}/$year';

      _months.add(MapEntry(key, label));
    }
    if (_months.isNotEmpty) {
      _selectedMonth = _months.first.key;
      loadData();
    }
  }

  void selectMonth(String key) {
    if (_selectedMonth == key) return;
    _selectedMonth = key;
    notifyListeners();
    loadData();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadData();
  }

  void setFilterType(core.TransactionType? type) {
    if (_selectedType == type) return;
    _selectedType = type;
    notifyListeners();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _transactionRepository.summary(_selectedMonth),
      _transactionRepository.list(
        core.TransactionFilter(month: _selectedMonth, pageSize: 100),
      ),
      _transactionRepository.list(
        core.TransactionFilter(
          month: _selectedMonth,
          type: _selectedType,
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          pageSize: 100,
        ),
      ),
    ]);

    _isLoading = false;

    final summaryResult = results[0] as core.Result<core.Summary>;
    final allTransactionsResult = results[1] as core.Result<core.Page<core.Transaction>>;
    final filteredTransactionsResult = results[2] as core.Result<core.Page<core.Transaction>>;

    switch (summaryResult) {
      case core.Ok(value: final summaryData):
        _summary = summaryData;
      case core.Failure(error: final error):
        _errorMessage = error.message;
        _summary = null;
    }

    switch (allTransactionsResult) {
      case core.Ok(value: final page):
        _processCategories(page.items);
      case core.Failure():
        _categories = [];
    }

    switch (filteredTransactionsResult) {
      case core.Ok(value: final page):
        _transactions = page.items;
      case core.Failure():
        _transactions = [];
    }

    notifyListeners();
  }

  void _processCategories(List<core.Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == core.TransactionType.expense);
    final totals = <String, double>{};
    double totalExpenseSum = 0;

    for (final tx in expenses) {
      final category = (tx.category != null && tx.category!.trim().isNotEmpty)
          ? tx.category!
          : 'Sem categoria';
      totals[category] = (totals[category] ?? 0) + tx.amount;
      totalExpenseSum += tx.amount;
    }

    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final formatter = core.MoneyFormatter.forCurrency(core.Currency.brl);

    _categories = sortedEntries.map((entry) {
      final amount = entry.value;
      final share = totalExpenseSum > 0 ? amount / totalExpenseSum : 0.0;
      return CategorySummary(
        label: entry.key,
        amount: amount,
        formattedAmount: formatter.format(amount),
        share: share,
      );
    }).toList();
  }

  Future<void> logout(BuildContext context) async {
    const authStorage = AuthStorage();
    await authStorage.clear();
    if (!context.mounted) return;
    coordinator.navigateToLogin(context);
  }

  void navigateToProfile(BuildContext context) {
    coordinator.navigateToProfile(context, _themeNotifier);
  }

  void onTransactionSelected(BuildContext context, String transactionId) {
    coordinator.navigateToTransactionDetail(
      context,
      transactionId: transactionId,
      onDeleted: loadData,
    );
  }
}
