import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'profile.dart';
import 'profile_coordinator.dart';
import 'profile_server.dart';
import 'profile_view_model.dart';

abstract final class ProfileFactory {
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
    final userRepository = RemoteUserRepository(client: apiClient);
    final server = ProfileServer(
      userRepository: userRepository,
      authRepository: authRepository,
    );
    const coordinator = DefaultProfileCoordinator();

    final viewModel = ProfileViewModel(
      server: server,
      authRepository: authRepository,
      coordinator: coordinator,
      themeNotifier: themeNotifier ?? ValueNotifier<ThemeMode>(ThemeMode.light),
    );
    return ProfileView(viewModel: viewModel);
  }
}
