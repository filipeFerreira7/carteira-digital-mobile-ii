import 'package:flutter/material.dart';
import '../login/login_factory.dart';
import '../profile/profile_factory.dart';
import '../transaction_detail/transaction_detail_factory.dart';

abstract interface class HomeCoordinator {
  void navigateToLogin(BuildContext context);
  void navigateToProfile(BuildContext context, ValueNotifier<ThemeMode> themeNotifier);
  Future<void> navigateToTransactionDetail(
    BuildContext context, {
    required String transactionId,
    required VoidCallback onDeleted,
  });
}

class DefaultHomeCoordinator implements HomeCoordinator {
  const DefaultHomeCoordinator();

  @override
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginFactory.make()),
      (route) => false,
    );
  }

  @override
  void navigateToProfile(BuildContext context, ValueNotifier<ThemeMode> themeNotifier) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, _, __) => ProfileFactory.make(themeNotifier: themeNotifier),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Future<void> navigateToTransactionDetail(
    BuildContext context, {
    required String transactionId,
    required VoidCallback onDeleted,
  }) async {
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TransactionDetailFactory.make(transactionId: transactionId),
      ),
    );
    if (deleted == true) {
      onDeleted();
    }
  }
}
