import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/menu_item.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({Key? key}) : super(key: key);

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMeals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMeals() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<AppState>(context, listen: false).fetchMenu();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<MenuItem> _getMealsByType(List<MenuItem> items, String type) {
    return items.where((item) => item.mealType.toLowerCase() == type.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMeals,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final menuItems = appState.menuItems;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildMealList('Breakfast', _getMealsByType(menuItems, 'breakfast')),
              _buildMealList('Lunch', _getMealsByType(menuItems, 'lunch')),
              _buildMealList('Dinner', _getMealsByType(menuItems, 'dinner')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMealList(String mealType, List<MenuItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No $mealType items available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Today\'s $mealType Menu',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final item = items[index - 1];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: item.isVeg ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        item.isVeg ? Icons.circle : Icons.square,
                        color: item.isVeg ? Colors.green : Colors.red,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: item.isAvailable ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    Text(
                      '₹${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: item.isAvailable 
                          ? Theme.of(context).primaryColor 
                          : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.isAvailable ? 'Available' : 'Not Available',
                      style: TextStyle(
                        fontSize: 14,
                        color: item.isAvailable ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: item.isAvailable ? () {
                        // TODO: Implement order functionality
                      } : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Order'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 