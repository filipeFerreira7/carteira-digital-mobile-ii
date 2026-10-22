import 'package:carteira_core/carteira_core.dart';
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
    required AuthRepository authRepository,
    required TransactionRepository transactionRepository,
    required this.coordinator,
  })  : _authRepository = authRepository,
        _transactionRepository = transactionRepository {
    _initSessionAndFetch();
  }

  final HomeServer server;
  final AuthRepository _authRepository;
  final TransactionRepository _transactionRepository;
  final HomeCoordinator coordinator;

  final List<MapEntry<String, String>> _months = [];
  String _selectedMonth = '';
  Summary? _summary;
  List<CategorySummary> _categories = [];
  List<Transaction> _transactions = [];
  String _searchQuery = '';
  TransactionType? _selectedType;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;

  List<MapEntry<String, String>> get months => _months;
  String get selectedMonth => _selectedMonth;
  Summary? get summary => _summary;
  List<CategorySummary> get categories => _categories;
  List<Transaction> get transactions => _transactions;
  String get searchQuery => _searchQuery;
  TransactionType? get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userName => _userName;

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

  void setFilterType(TransactionType? type) {
    if (_selectedType == type) return;
    _selectedType = type;
    notifyListeners();
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final summaryResult = await _transactionRepository.summary(_selectedMonth);
    final allTransactionsResult = await _transactionRepository.list(
      TransactionFilter(month: _selectedMonth, pageSize: 100),
    );
    final filteredTransactionsResult = await _transactionRepository.list(
      TransactionFilter(
        month: _selectedMonth,
        type: _selectedType,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        pageSize: 100,
      ),
    );

    _isLoading = false;

    switch (summaryResult) {
      case Ok(value: final summaryData):
        _summary = summaryData;
      case Failure(error: final error):
        _errorMessage = error.message;
        _summary = null;
    }

    switch (allTransactionsResult) {
      case Ok(value: final page):
        _processCategories(page.items);
      case Failure():
        _categories = [];
    }

    switch (filteredTransactionsResult) {
      case Ok(value: final page):
        _transactions = page.items;
      case Failure():
        _transactions = [];
    }

    notifyListeners();
  }

  void _processCategories(List<Transaction> transactions) {
    final expenses = transactions.where((t) => t.type == TransactionType.expense);
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

    final formatter = MoneyFormatter.forCurrency(Currency.brl);

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
}
