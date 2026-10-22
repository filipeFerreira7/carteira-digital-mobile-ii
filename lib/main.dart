import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_digital/scenes/home/home_factory.dart';
import 'package:carteira_digital/scenes/login/login_factory.dart';
import 'package:carteira_digital/storage/auth_storage.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const authStorage = AuthStorage();
  final session = await authStorage.read();

  runApp(CarteiraApp(isLoggedIn: session != null));
}

class CarteiraApp extends StatelessWidget {
  const CarteiraApp({required this.isLoggedIn, super.key});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carteira Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: isLoggedIn ? HomeFactory.make() : LoginFactory.make(),
    );
  }
}
