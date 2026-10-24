import 'package:carteira_core/carteira_core.dart' as core;
import 'package:carteira_digital/scenes/transaction_detail/transaction_detail_coordinator.dart';
import 'package:carteira_digital/scenes/transaction_detail/transaction_detail_server.dart';
import 'package:carteira_digital/scenes/transaction_detail/transaction_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockTransactionRepository implements core.TransactionRepository {
  core.Transaction? mockTransaction;
  bool shouldFail = false;

  @override
  Future<core.Result<core.Transaction>> getById(String id) async {
    if (shouldFail) return const core.Failure(core.NotFoundError());
    if (mockTransaction != null) return core.Ok(mockTransaction!);
    return const core.Failure(core.NotFoundError());
  }

  @override
  Future<core.Result<void>> delete(String id) async {
    if (shouldFail) return const core.Failure(core.ServerError(500));
    return const core.Ok(null);
  }

  @override
  Future<core.Result<core.Page<core.Transaction>>> list(core.TransactionFilter filter) async =>
      throw UnimplementedError();

  @override
  Future<core.Result<core.Transaction>> create(core.Transaction transaction) async =>
      throw UnimplementedError();

  @override
  Future<core.Result<core.Transaction>> update(core.Transaction transaction) async =>
      throw UnimplementedError();

  @override
  Future<core.Result<core.Summary>> summary(String month) async =>
      throw UnimplementedError();

  @override
  Stream<List<core.Transaction>> watch() => throw UnimplementedError();
}

class MockAuthRepository implements core.AuthRepository {
  @override
  core.Session? currentSession;

  @override
  Future<core.Result<core.Session>> login({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<core.Result<void>> logout() async => const core.Ok(null);

  @override
  Future<core.Result<core.Session?>> restore() async => core.Ok(currentSession);
}

class MockCoordinator implements TransactionDetailCoordinator {
  bool wentBack = false;
  bool wasDeleted = false;

  @override
  void goBack(BuildContext context, {bool deleted = false}) {
    wentBack = true;
    wasDeleted = deleted;
  }
}

void main() {
  group('TransactionDetailViewModel Tests', () {
    test('loads transaction successfully', () async {
      final repo = MockTransactionRepository()
        ..mockTransaction = core.Expense(
          id: 'tx_0059',
          amount: 480.0,
          description: 'Plano de saúde Amil',
          date: DateTime(2026, 9, 26, 15, 55),
          account: 'Carteira',
          category: 'Saúde',
        );
      final server = TransactionDetailServer(repository: repo);
      final authRepo = MockAuthRepository();
      final coordinator = MockCoordinator();

      final viewModel = TransactionDetailViewModel(
        transactionId: 'tx_0059',
        authRepository: authRepo,
        server: server,
        coordinator: coordinator,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.transaction, isNotNull);
      expect(viewModel.transaction?.id, 'tx_0059');
      expect(viewModel.transaction?.description, 'Plano de saúde Amil');
    });
  });
}
