import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'home_coordinator.dart';
import 'home_server.dart';
import 'home_view.dart';
import 'home_view_model.dart';

abstract final class HomeFactory {
  static Widget make({ValueNotifier<ThemeMode>? themeNotifier}) {
    final baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? "http://10.0.2.2:8082"
        : "http://localhost:8082";

    final apiClient = ApiClient(baseUrl: baseUrl);
    const authStorage = AuthStorage();
    final authRepository = RemoteAuthRepository(
      client: apiClient,
      storage: authStorage,
    );
    final transactionRepository = RemoteTransactionRepository(client: apiClient);
    const coordinator = DefaultHomeCoordinator();

    final viewModel = HomeViewModel(
      server: const DefaultHomeServer(),
      authRepository: authRepository,
      transactionRepository: transactionRepository,
      coordinator: coordinator,
      themeNotifier: themeNotifier ?? ValueNotifier<ThemeMode>(ThemeMode.light),
    );
    return HomeView(viewModel: viewModel);
  }
}
