import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';
import 'profile_view_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({required this.viewModel, super.key});

  final ProfileViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppScaffold(
      showAppBar: false,
      bottom: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            viewModel.navigateToHome(context);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Lançamentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final user = viewModel.user;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Title "Perfil" and Theme Toggle action (top right)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Perfil',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          viewModel.themeNotifier.value == ThemeMode.light
                              ? Icons.brightness_6_outlined
                              : Icons.brightness_6,
                        ),
                        tooltip: 'Alternar tema',
                        onPressed: viewModel.toggleTheme,
                      ),
                    ],
                  ),
                ),
                const Gap.xl(),
                if (viewModel.isLoading && user == null)
                  const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  // Avatar
                  Center(
                    child: AppAvatar(
                      name: user?.name ?? '',
                      imageUrl: user?.avatarUrl,
                      size: 88,
                    ),
                  ),
                  const Gap.md(),
                  // User Name
                  Text(
                    user?.name ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap.xxs(),
                  // User Email
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.semanticColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap.xxs(),
                  // Creation Date
                  if (user != null)
                    Text(
                      'Na Carteira desde ${formatDate(user.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.semanticColors.muted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const Gap.xl(),
                  // Section "DADOS" with input fields
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'DADOS',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.semanticColors.muted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Gap.sm(),
                  AppTextField(
                    label: 'Nome',
                    controller: viewModel.nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const Gap.md(),
                  AppTextField(
                    label: 'URL da foto',
                    controller: viewModel.avatarUrlController,
                    prefixIcon: Icons.image_outlined,
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const Gap.md(),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (viewModel.successMessage != null) ...[
                    const Gap.md(),
                    Text(
                      viewModel.successMessage!,
                      style: TextStyle(color: context.semanticColors.income),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const Gap.xl(),
                  // Save Button
                  AppButton(
                    label: 'Salvar',
                    isLoading: viewModel.isSaving,
                    onPressed: viewModel.saveProfile,
                  ),
                  const Gap.md(),
                  // Logout Button
                  AppButton(
                    label: 'Sair da conta',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => viewModel.logout(context),
                  ),
                ],
                const Gap.xxl(),
              ],
            ),
          );
        },
      ),
    );
  }
}
