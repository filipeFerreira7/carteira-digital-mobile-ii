import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'login_coordinator.dart';
import 'login_view.dart';
import 'login_view_model.dart';

abstract final class LoginFactory {
  static Widget make() {
    final baseUrl = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? "http://10.0.2.2:8082"
        : "http://localhost:8082";

    final apiClient = ApiClient(baseUrl: baseUrl);
    const authStorage = AuthStorage();
    final authRepository = RemoteAuthRepository(
      client: apiClient,
      storage: authStorage,
    );

    final viewModel = LoginViewModel(
      authRepository: authRepository,
      coordinator: const DefaultLoginCoordinator(),
    );
    return LoginView(viewModel: viewModel);
  }
}
