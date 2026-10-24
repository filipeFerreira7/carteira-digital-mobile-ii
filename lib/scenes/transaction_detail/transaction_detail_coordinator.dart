import 'package:flutter/material.dart';

abstract interface class TransactionDetailCoordinator {
  void goBack(BuildContext context, {bool deleted = false});
}

class DefaultTransactionDetailCoordinator implements TransactionDetailCoordinator {
  const DefaultTransactionDetailCoordinator();

  @override
  void goBack(BuildContext context, {bool deleted = false}) {
    Navigator.of(context).pop(deleted);
  }
}
