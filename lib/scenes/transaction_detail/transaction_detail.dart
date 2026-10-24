import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/material.dart';
import 'transaction_detail_view_model.dart';

class TransactionDetailView extends StatelessWidget {
  const TransactionDetailView({required this.viewModel, super.key});

  final TransactionDetailViewModel viewModel;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text('Você tem certeza que quer excluir essa transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('NÃO'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              viewModel.deleteTransaction(context);
            },
            child: const Text('SIM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final moneyFormatter = MoneyFormatter.forCurrency(Currency.brl);

    return AppScaffold(
      showAppBar: false,
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final tx = viewModel.transaction;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom AppBar: Back arrow, "Lançamento" title, and Delete icon
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => viewModel.coordinator.goBack(context),
                        ),
                        Text(
                          'Lançamento',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (tx != null)
                      viewModel.isDeleting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              tooltip: 'Excluir',
                              onPressed: () => _confirmDelete(context),
                            ),
                  ],
                ),
              ),
              const Gap.lg(),
              if (viewModel.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (tx == null)
                Expanded(
                  child: Center(
                    child: Text(viewModel.errorMessage ?? 'Transação não encontrada'),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top item summary card matching screenshot
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: (tx.type == TransactionType.income
                                            ? context.semanticColors.income
                                            : tx.type == TransactionType.expense
                                                ? context.semanticColors.expense
                                                : context.semanticColors.transfer)
                                        .withValues(alpha: 0.14),
                                    borderRadius: AppRadius.mdAll,
                                  ),
                                  child: Icon(
                                    tx.type == TransactionType.income
                                        ? Icons.arrow_downward_rounded
                                        : tx.type == TransactionType.expense
                                            ? Icons.arrow_upward_rounded
                                            : Icons.swap_horiz_rounded,
                                    color: tx.type == TransactionType.income
                                        ? context.semanticColors.income
                                        : tx.type == TransactionType.expense
                                            ? context.semanticColors.expense
                                            : context.semanticColors.transfer,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.description,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: AppSpacing.xxs),
                                      Text(
                                        tx.type == TransactionType.income
                                            ? 'Receita'
                                            : tx.type == TransactionType.expense
                                                ? 'Despesa'
                                                : 'Transferência',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: context.semanticColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MoneyText(
                                  moneyFormatter.format(tx.amount),
                                  tone: tx.type == TransactionType.income
                                      ? MoneyTone.income
                                      : tx.type == TransactionType.expense
                                          ? MoneyTone.expense
                                          : MoneyTone.neutral,
                                  signed: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap.xl(),
                        // Big amount display
                        Center(
                          child: MoneyText(
                            moneyFormatter.format(tx.signedAmount),
                            size: MoneySize.display,
                            tone: tx.type == TransactionType.income
                                ? MoneyTone.income
                                : tx.type == TransactionType.expense
                                    ? MoneyTone.expense
                                    : MoneyTone.neutral,
                            signed: true,
                          ),
                        ),
                        const Gap.xxl(),
                        // Detail Rows matching screenshot
                        _buildDetailRow(
                          context,
                          'Data',
                          formatDateTime(tx.date),
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Conta',
                          tx.account,
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Categoria',
                          tx.category ?? 'Sem categoria',
                        ),
                        const Divider(),
                        _buildDetailRow(
                          context,
                          'Observação',
                          tx.note ?? 'Sem observação',
                        ),
                        const Gap.xl(),
                        Text(
                          'ID ${tx.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: context.semanticColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: context.semanticColors.muted,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
