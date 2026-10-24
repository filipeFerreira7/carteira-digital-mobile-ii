import 'package:flutter/material.dart';
import '../home/home_factory.dart';
import '../login/login_factory.dart';

abstract interface class ProfileCoordinator {
  void navigateToHome(BuildContext context, ValueNotifier<ThemeMode> themeNotifier);
  void navigateToLogin(BuildContext context);
}

class DefaultProfileCoordinator implements ProfileCoordinator {
  const DefaultProfileCoordinator();

  @override
  void navigateToHome(BuildContext context, ValueNotifier<ThemeMode> themeNotifier) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => HomeFactory.make(themeNotifier: themeNotifier),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginFactory.make()),
      (route) => false,
    );
  }
}
