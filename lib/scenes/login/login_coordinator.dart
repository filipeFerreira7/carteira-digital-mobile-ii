import 'package:flutter/material.dart';
import '../home/home_factory.dart';

abstract interface class LoginCoordinator {
  void navigateToHome(BuildContext context);
}

class DefaultLoginCoordinator implements LoginCoordinator {
  const DefaultLoginCoordinator();

  @override
  void navigateToHome(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeFactory.make()),
    );
  }
}
