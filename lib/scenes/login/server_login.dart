 import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

abstract interface class ServerLogin {
  Future<Result> fetchLogin({required String email, required String password});
}

class LoginMockServer implements ServerLogin {
  const LoginMockServer({this.delay = const Duration(milliseconds: 2000)});

  static const email = 'ana@carteira.dev';
  static const password = '123456';
  final Duration delay;

  @override
  Future<Result> fetchLogin({required String email, required String password}) async {
      if (email.isEmpty || password.isEmpty) {
        return const Failure(ValidationError({},detail: 'Campos vazios'));
      }
      if (email != LoginMockServer.email || password != LoginMockServer.password) {
        return const Failure(ValidationError({}, detail: 'Email ou senha inválidos'));
      }

      return const Ok(true);
  }

}

class LoginServer implements ServerLogin {

  static String baseURL = !kIsWeb && defaultTargetPlatform == TargetPlatform.android
  ? "http://10.0.2.2:8082"
  : "http://127.0.0.1:8082";

  final ApiClient client;

  LoginServer({ApiClient? client}) : client = client ?? ApiClient(baseUrl: LoginServer.baseURL);

  @override
  Future<Result> fetchLogin(
      {required String email, required String password}) async {
    final result = await client.post('/auth/login', body: {'email': email , 'password': password});

    switch(result) {
      case Ok _:
        return Ok(true);
      case Failure _:
        return Failure(ValidationError({}, detail: 'email ou senha inválidos'));
    }
  }
}