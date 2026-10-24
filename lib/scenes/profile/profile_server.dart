import 'package:carteira_core/carteira_core.dart';

class ProfileServer {
  const ProfileServer({
    required UserRepository userRepository,
    required AuthRepository authRepository,
  })  : _userRepository = userRepository,
        _authRepository = authRepository;

  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  Future<Result<User>> getProfile() => _userRepository.getProfile();

  Future<Result<User>> updateProfile({required String name, String? avatarUrl}) =>
      _userRepository.updateProfile(name: name, avatarUrl: avatarUrl);

  Future<Result<void>> logout() => _authRepository.logout();
}
