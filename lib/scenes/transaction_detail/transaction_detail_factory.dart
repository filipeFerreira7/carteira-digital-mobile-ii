import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'transaction_detail.dart';
import 'transaction_detail_coordinator.dart';
import 'transaction_detail_server.dart';
import 'transaction_detail_view_model.dart';

abstract final class TransactionDetailFactory {
  static Widget make({required String transactionId}) {
    final baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? "http://10.0.2.2:8082"
        : "http://localhost:8082";

    final apiClient = ApiClient(baseUrl: baseUrl);
    const authStorage = AuthStorage();
    final authRepository = RemoteAuthRepository(
      client: apiClient,
      storage: authStorage,
    );
    final repository = RemoteTransactionRepository(client: apiClient);
    final server = TransactionDetailServer(repository: repository);
    const coordinator = DefaultTransactionDetailCoordinator();

    final viewModel = TransactionDetailViewModel(
      transactionId: transactionId,
      authRepository: authRepository,
      server: server,
      coordinator: coordinator,
    );
    return TransactionDetailView(viewModel: viewModel);
  }
}
