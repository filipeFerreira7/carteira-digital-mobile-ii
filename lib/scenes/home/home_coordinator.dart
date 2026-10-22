import 'package:flutter/material.dart';
import '../login/login_factory.dart';

abstract interface class HomeCoordinator {
  void navigateToLogin(BuildContext context);
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator();

  @override
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginFactory.make()),
    );
  }
}
