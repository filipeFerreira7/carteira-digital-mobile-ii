import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';
import 'home_view_model.dart';

class HomeView extends StatelessWidget {
  const HomeView({required this.viewModel, super.key});

  final HomeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final moneyFormatter = MoneyFormatter.forCurrency(Currency.brl);

    return AppScaffold(
      showAppBar: false,
      bottom: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            viewModel.navigateToProfile(context);
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
          final groupedTransactions = groupBy(
            viewModel.transactions,
            (tx) => formatDayHeading(tx.date).toUpperCase(),
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header: Title "Carteira", Greeting, and Theme Toggle action (top right)
                Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.lg,
                    bottom: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Carteira',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Row(
                            children: [
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
                        ],
                      ),
                      if (viewModel.userName != null) ...[
                        const Gap.xxs(),
                        Text(
                          'Olá ${viewModel.userName}! Vamos organizar suas finanças? :)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Gap.md(),
                // Month Filter Chips (horizontal scroll)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.months.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final entry = viewModel.months[index];
                      final isSelected = entry.key == viewModel.selectedMonth;

                      return InkWell(
                        onTap: () => viewModel.selectMonth(entry.key),
                        borderRadius: AppRadius.mdAll,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.secondaryContainer
                                : colorScheme.surface,
                            borderRadius: AppRadius.mdAll,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : colorScheme.outline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                              Text(
                                entry.value,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? colorScheme.onSecondaryContainer
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Gap.xl(),
                // Balance Card from Design System showing Summary data
                if (viewModel.isLoading && viewModel.summary == null)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  BalanceCard(
                    title: 'Saldo do mês',
                    monthLabel: viewModel.selectedMonth.isNotEmpty
                        ? formatMonthKey(viewModel.selectedMonth)
                        : null,
                    balance: moneyFormatter.format(viewModel.summary?.balance ?? 0.0),
                    income: moneyFormatter.format(viewModel.summary?.income ?? 0.0),
                    expense: moneyFormatter.format(viewModel.summary?.expense ?? 0.0),
                  ),
                const SectionHeader(title: 'Por Categoria'),
                if (viewModel.categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(child: Text('Nenhuma despesa neste mês')),
                  )
                else
                  ...viewModel.categories.map(
                    (cat) => CategoryBar(
                      label: cat.label,
                      amount: cat.formattedAmount,
                      share: cat.share,
                    ),
                  ),
                const Gap.xl(),
                // Search Field
                AppTextField(
                  label: '',
                  hint: 'Buscar por descrição',
                  prefixIcon: Icons.search,
                  onChanged: viewModel.setSearchQuery,
                ),
                const Gap.md(),
                // Transaction Type Filter Chips (Todos, Receita, Despesa, Transf.)
                Row(
                  children: [
                    Expanded(
                      child: _FilterChipButton(
                        label: 'Todos',
                        isSelected: viewModel.selectedType == null,
                        onTap: () => viewModel.setFilterType(null),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _FilterChipButton(
                        label: 'Receita',
                        isSelected: viewModel.selectedType == TransactionType.income,
                        onTap: () => viewModel.setFilterType(TransactionType.income),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _FilterChipButton(
                        label: 'Despesa',
                        isSelected: viewModel.selectedType == TransactionType.expense,
                        onTap: () => viewModel.setFilterType(TransactionType.expense),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: _FilterChipButton(
                        label: 'Transf.',
                        isSelected: viewModel.selectedType == TransactionType.transfer,
                        onTap: () => viewModel.setFilterType(TransactionType.transfer),
                      ),
                    ),
                  ],
                ),
                const Gap.md(),
                // Transactions grouped by date
                if (groupedTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('Nenhum lançamento encontrado')),
                  )
                else
                  for (final entry in groupedTransactions.entries) ...[
                    SectionHeader(title: entry.key),
                    ...entry.value.map((tx) {
                      final kind = switch (tx.type) {
                        TransactionType.income => TransactionKind.income,
                        TransactionType.expense => TransactionKind.expense,
                        TransactionType.transfer => TransactionKind.transfer,
                      };
                      final subtitleParts = [
                        if (tx.category != null && tx.category!.isNotEmpty) tx.category!,
                        tx.account,
                      ];
                      return TransactionTile(
                        kind: kind,
                        title: tx.description,
                        subtitle: subtitleParts.join(' · '),
                        amount: moneyFormatter.format(tx.amount),
                        onTap: () => viewModel.onTransactionSelected(context, tx.id),
                      );
                    }),
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

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.secondaryContainer : colorScheme.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: isSelected ? Colors.transparent : colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? colorScheme.onSecondaryContainer : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
