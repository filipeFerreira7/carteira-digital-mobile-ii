import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';

import 'login_view_model.dart';

class LoginView extends StatefulWidget {
  const LoginView({required this.viewModel, super.key});

  final LoginViewModel viewModel;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  String? _lastErrorMessage;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void didUpdateWidget(covariant LoginView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_onViewModelChanged);
      widget.viewModel.addListener(_onViewModelChanged);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    widget.viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final errorMessage = widget.viewModel.errorMessage;
    if (errorMessage != null && errorMessage != _lastErrorMessage) {
      _lastErrorMessage = errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      });
    } else if (errorMessage == null) {
      _lastErrorMessage = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return AppScaffold(
      showAppBar: false,
      body: Center(
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Acesse sua carteira digital',
                    style: textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const Gap.xl(),
                  AppTextField(
                    key: const Key('login_email'),
                    label: 'E-mail',
                    hint: 'voce@exemplo.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: Icons.mail_outline,
                    autofillHints: const [AutofillHints.email],
                    onChanged: viewModel.onEmailChanged,
                  ),
                  const Gap.md(),
                  PasswordField(
                    key: const Key('login_password'),
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    onChanged: viewModel.onPasswordChanged,
                  ),
                  if (viewModel.errorMessage case final message?) ...[
                    const Gap.md(),
                    Text(
                      message,
                      key: const Key('login_error'),
                      style: textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Gap.xl(),
                  AppButton(
                    key: const Key('login_submit'),
                    label: 'Entrar',
                    isLoading: viewModel.isLoading,
                    onPressed: () => viewModel.submit(context),
                  ),
                  if (viewModel.userName case final name?) ...[
                    const Gap.md(),
                    Text(
                      'Bem-vindo, $name!',
                      key: const Key('login_welcome'),
                      style: textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
