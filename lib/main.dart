import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_digital/scenes/home/home_factory.dart';
import 'package:carteira_digital/scenes/login/login_factory.dart';
import 'package:carteira_digital/storage/auth_storage.dart';
import 'package:flutter/material.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const authStorage = AuthStorage();
  final session = await authStorage.read();

  runApp(CarteiraApp(isLoggedIn: session != null));
}

class CarteiraApp extends StatefulWidget {
  const CarteiraApp({required this.isLoggedIn, super.key});

  final bool isLoggedIn;

  @override
  State<CarteiraApp> createState() => _CarteiraAppState();
}

class _CarteiraAppState extends State<CarteiraApp> {
  late final Widget _homeWidget;

  @override
  void initState() {
    super.initState();
    _homeWidget = HomeFactory.make(themeNotifier: themeNotifier);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Carteira Digital',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: widget.isLoggedIn ? _homeWidget : LoginFactory.make(),
        );
      },
    );
  }
}
