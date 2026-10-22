import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';
import 'login_coordinator.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required this._authRepository,
    required this.coordinator,
  });

  final AuthRepository _authRepository;
  final LoginCoordinator coordinator;

  String _email = '';
  String _password = '';
  String? _errorMessage;
  bool _isLoading = false;
  String? _userName;

  String? get userName => _userName;
  String get email => _email;
  String get password => _password;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onEmailChanged(String value) {
    _email = value;
    _errorMessage = null;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> submit(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authRepository.login(
      email: emailController.text.isNotEmpty ? emailController.text : _email,
      password: passwordController.text.isNotEmpty ? passwordController.text : _password,
    );

    _isLoading = false;

    switch (result) {
      case Ok(value: final session):
        _errorMessage = null;
        _userName = session.user.name;
        if (!context.mounted) return;
        coordinator.navigateToHome(context);
      case Failure(error: final error):
        _errorMessage = error.message;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
