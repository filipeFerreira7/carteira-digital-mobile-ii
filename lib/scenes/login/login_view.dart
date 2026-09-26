import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'login_view_model.dart';

class LoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const LoginView({super.key, required this.viewModel});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: widget.viewModel.emailController,
            label: 'E-mail',
            hint: 'Digite seu e-mail',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            onChanged: widget.viewModel.onEmailChanged,
          ),
          const SizedBox(height: 16),
          PasswordField(
            controller: widget.viewModel.passwordController,
            label: 'Senha',
            onChanged: widget.viewModel.onPasswordChanged,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Entrar',
            onPressed: widget.viewModel.submit
          ),
        ],
      ),
    );
  }
}
