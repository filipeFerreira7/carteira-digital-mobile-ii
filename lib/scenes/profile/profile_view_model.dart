import 'package:carteira_core/carteira_core.dart' as core;
import 'package:flutter/material.dart';
import '../../storage/auth_storage.dart';
import 'profile_coordinator.dart';
import 'profile_server.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({
    required ProfileServer server,
    required core.AuthRepository authRepository,
    required this.coordinator,
    required ValueNotifier<ThemeMode> themeNotifier,
  })  : _server = server,
        _authRepository = authRepository,
        _themeNotifier = themeNotifier {
    _themeNotifier.addListener(_onThemeChanged);
    _initSessionAndLoad();
  }

  final ProfileServer _server;
  final core.AuthRepository _authRepository;
  final ProfileCoordinator coordinator;
  final ValueNotifier<ThemeMode> _themeNotifier;

  core.User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  core.User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  final nameController = TextEditingController();
  final avatarUrlController = TextEditingController();

  void toggleTheme() {
    _themeNotifier.value = _themeNotifier.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void _onThemeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    nameController.dispose();
    avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _initSessionAndLoad() async {
    await _authRepository.restore();
    await loadProfile();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _server.getProfile();
    _isLoading = false;

    switch (result) {
      case core.Ok(value: final userData):
        _user = userData;
        nameController.text = userData.name;
        avatarUrlController.text = userData.avatarUrl ?? '';
      case core.Failure(error: final error):
        _errorMessage = error.message;
        _user = null;
    }
    notifyListeners();
  }

  Future<void> saveProfile() async {
    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await _server.updateProfile(
      name: nameController.text,
      avatarUrl: avatarUrlController.text.trim().isEmpty ? null : avatarUrlController.text.trim(),
    );

    _isSaving = false;

    switch (result) {
      case core.Ok(value: final userData):
        _user = userData;
        _successMessage = 'Perfil atualizado com sucesso!';
      case core.Failure(error: final error):
        _errorMessage = error.message;
    }
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    await _server.logout();
    const authStorage = AuthStorage();
    await authStorage.clear();
    if (!context.mounted) return;
    coordinator.navigateToLogin(context);
  }

  void navigateToHome(BuildContext context) {
    coordinator.navigateToHome(context, _themeNotifier);
  }
}
