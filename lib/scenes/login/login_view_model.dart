import 'package:flutter/material.dart';
import 'login_coordinator.dart';
import 'server_login.dart';

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({
    required this.serverLogin,
    required this.coordinator,
  });

  final ServerLogin serverLogin;
  final LoginCoordinator coordinator;

  String _email = '';
  String _password = '';
  
  String get email => _email;
  String get password => _password;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onEmailChanged(String value) {
    _email = value;
    notifyListeners();
  }

  void onPasswordChanged(String value) {
    _password = value;
    notifyListeners();
  }

  void submit() {

  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
