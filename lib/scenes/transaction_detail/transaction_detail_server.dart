import 'package:carteira_core/carteira_core.dart';

class TransactionDetailServer {
  const TransactionDetailServer({required TransactionRepository repository})
      : _repository = repository;

  final TransactionRepository _repository;

  Future<Result<Transaction>> getById(String id) => _repository.getById(id);

  Future<Result<void>> delete(String id) => _repository.delete(id);
}
