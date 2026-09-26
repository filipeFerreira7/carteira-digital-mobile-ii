import 'package:flutter/material.dart';
import 'server_login.dart';
import 'login_coordinator.dart';
import 'login_view_model.dart';
import 'login_view.dart';

abstract final class LoginFactory {
  static Widget make() {
    final viewModel = LoginViewModel(
      serverLogin: const DefaultServerLogin(),
      coordinator: const DefaultLoginCoordinator(),
    );
    return LoginView(viewModel: viewModel);
  }
}
