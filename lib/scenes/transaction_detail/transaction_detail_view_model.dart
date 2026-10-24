import 'package:carteira_core/carteira_core.dart' as core;
import 'package:flutter/material.dart';
import 'transaction_detail_coordinator.dart';
import 'transaction_detail_server.dart';

class TransactionDetailViewModel extends ChangeNotifier {
  TransactionDetailViewModel({
    required String transactionId,
    required core.AuthRepository authRepository,
    required TransactionDetailServer server,
    required this.coordinator,
  })  : _transactionId = transactionId,
        _authRepository = authRepository,
        _server = server {
    _initSessionAndLoad();
  }

  final String _transactionId;
  final core.AuthRepository _authRepository;
  final TransactionDetailServer _server;
  final TransactionDetailCoordinator coordinator;

  core.Transaction? _transaction;
  bool _isLoading = true;
  bool _isDeleting = false;
  String? _errorMessage;

  core.Transaction? get transaction => _transaction;
  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;

  Future<void> _initSessionAndLoad() async {
    await _authRepository.restore();
    loadTransaction();
  }

  Future<void> loadTransaction() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _server.getById(_transactionId);
    _isLoading = false;

    switch (result) {
      case core.Ok(value: final tx):
        _transaction = tx;
      case core.Failure(error: final error):
        _errorMessage = error.message;
        _transaction = null;
    }
    notifyListeners();
  }

  Future<void> deleteTransaction(BuildContext context) async {
    _isDeleting = true;
    notifyListeners();

    final result = await _server.delete(_transactionId);
    _isDeleting = false;

    switch (result) {
      case core.Ok():
        if (!context.mounted) return;
        coordinator.goBack(context, deleted: true);
      case core.Failure(error: final error):
        _errorMessage = error.message;
        notifyListeners();
    }
  }
}
