 abstract interface class ServerLogin {
  Future<void> fetchLogin({required String email, required String password});
}

class DefaultServerLogin implements ServerLogin {
  const DefaultServerLogin();

  @override
  Future<void> fetchLogin({required String email, required String password}) async {}
}

class  ServerLoginImpl implements ServerLogin {
  const ServerLoginImpl();

  @override
  Future<void> fetchLogin({required String email, required String password}) async {}

}