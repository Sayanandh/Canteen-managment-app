import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_card.dart';
import '../models/user.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final mealPlan = appState.mealPlan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => appState.refreshData(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => appState.logout(),
          ),
        ],
      ),
      body: appState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => appState.refreshData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  user?.fullName ?? 'Guest',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                user?.fullName.substring(0, 1).toUpperCase() ?? 'G',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: InfoCard(
                              title: 'Balance',
                              subtitle: '₹${user?.balance.toStringAsFixed(2) ?? '0.00'}',
                              icon: Icons.account_balance_wallet,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const AddMoneyDialog(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InfoCard(
                              title: 'Meals Left',
                              subtitle: '${mealPlan?.mealsRemaining ?? 0}',
                              icon: Icons.restaurant,
                              onTap: () {
                                Navigator.pushNamed(context, '/meals');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      if (appState.transactions.isEmpty)
                        Center(
                          child: Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: appState.transactions.length > 5
                              ? 5
                              : appState.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = appState.transactions[index];
                            return ListTile(
                              title: Text(transaction.description ?? 'Transaction'),
                              subtitle: Text(
                                transaction.timestamp.toString(),
                              ),
                              trailing: Text(
                                '₹${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: transaction.amount > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                // TODO: Implement transaction details view
                              },
                            );
                          },
                        ),
                      if (appState.transactions.length > 5) ...[
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to full transaction history
                            },
                            child: Text(
                              'View All Transactions',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary.withAlpha(204),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class AddMoneyDialog extends StatefulWidget {
  const AddMoneyDialog({Key? key}) : super(key: key);

  @override
  State<AddMoneyDialog> createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Money'),
      content: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: '₹',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_isProcessing)
          const CircularProgressIndicator()
        else
          TextButton(
            onPressed: () async {
              if (_amountController.text.isEmpty) return;

              setState(() => _isProcessing = true);
              final amount = double.tryParse(_amountController.text);
              
              if (amount != null && amount > 0) {
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.addBalance(amount);
                if (!mounted) return;
                Navigator.pop(context);
              }
              if (!mounted) return;
              setState(() => _isProcessing = false);
            },
            child: const Text('Add'),
          ),
      ],
    );
  }
} 