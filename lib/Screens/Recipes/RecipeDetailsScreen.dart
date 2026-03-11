import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/RecipeModel.dart';
import '../../Providers/RecipeProvider.dart';
import '../../Services/AuthService.dart';
import '../../Data/MealPlanManager.dart';
import 'CookModeScreen.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    // Listen to provider for changes
    final recipes = Provider.of<RecipeProvider>(context).recipes;
    // Find the current recipe object from provider (to get updated isFavorite status)
    final recipe = recipes.firstWhere(
      (r) => r.id == widget.recipe.id,
      orElse: () => widget.recipe,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Image.network(recipe.image, fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () {
                  final user =
                      Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).currentUser;
                  if (user != null) {
                    Provider.of<RecipeProvider>(
                      context,
                      listen: false,
                    ).toggleFavorite(recipe.id, user.uid);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please login to save favorites"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),

          // 2. Recipe Info (Time, Calories, Diet)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoChip(Icons.timer, widget.recipe.time),
                      _buildInfoChip(
                        Icons.local_fire_department,
                        "${widget.recipe.calories} kcal",
                      ),
                      _buildInfoChip(Icons.star, "${widget.recipe.rating}"),
                      _buildInfoChip(
                        Icons.restaurant_menu,
                        widget.recipe.dietType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Macros Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroInfo(
                          "Protein",
                          "${widget.recipe.protein}g",
                          Colors.blue,
                        ),
                        _buildMacroInfo(
                          "Carbs",
                          "${widget.recipe.carbs}g",
                          Colors.green,
                        ),
                        _buildMacroInfo(
                          "Fats",
                          "${widget.recipe.fats}g",
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Ingredients Section
                  const Text(
                    "Ingredients",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...widget.recipe.ingredients.map(
                    (ing) => ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF4CAF50),
                      ),
                      title: Text(ing),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Cooking Instructions Section
                  const Text(
                    "Instructions",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...widget.recipe.steps.asMap().entries.map((entry) {
                    int idx = entry.key + 1;
                    String step = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFFF7043),
                            child: Text(
                              "$idx",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 80), // Space for button
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: "btn1",
                onPressed: () {
                  _showAddToPlanDialog(context);
                },
                backgroundColor: Colors.white,
                label: const Text(
                  "Add to Plan",
                  style: TextStyle(color: Color(0xFF4CAF50)),
                ),
                icon: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: FloatingActionButton.extended(
                heroTag: "btn2",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CookModeScreen(recipe: widget.recipe),
                    ),
                  );
                },
                backgroundColor: const Color(0xFFFF7043),
                label: const Text(
                  "Start Cooking",
                  style: TextStyle(color: Colors.white),
                ),
                icon: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showAddToPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Select Day"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                MealPlanManager.weeklyPlan.keys.map((day) {
                  return ListTile(
                    title: Text(day),
                    onTap: () {
                      // 1. Update Local Manager
                      MealPlanManager.weeklyPlan[day] = widget.recipe;

                      // 2. Feedback
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${widget.recipe.name} added to $day!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
