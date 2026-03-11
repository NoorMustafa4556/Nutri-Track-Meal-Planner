import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../../Data/MealPlanManager.dart';
import '../../Providers/RecipeProvider.dart';
import '../../Services/AuthService.dart';
import '../../Services/DatabaseService.dart';
import '../../Models/RecipeModel.dart';
import '../Recipes/RecipeDetailsScreen.dart';
import '../Recipes/RecipePickerScreen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  @override
  void initState() {
    super.initState();
    _loadPlanFromFirebase();
  }

  Future<void> _loadPlanFromFirebase() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    final data = await DatabaseService().getWeeklyPlan(user.uid);
    if (data != null && data['weekPlan'] != null) {
      Map<String, dynamic> savedPlan = data['weekPlan'];
      final recipes =
          Provider.of<RecipeProvider>(context, listen: false).recipes;

      setState(() {
        MealPlanManager.weeklyPlan.forEach((day, _) {
          String? recipeId = savedPlan[day];
          if (recipeId != null) {
            // Find recipe object by ID
            try {
              MealPlanManager.weeklyPlan[day] = recipes.firstWhere(
                (r) => r.id == recipeId,
              );
            } catch (e) {
              // Recipe might not exist anymore
              MealPlanManager.weeklyPlan[day] = null;
            }
          } else {
            MealPlanManager.weeklyPlan[day] = null;
          }
        });
      });
    }
  }

  // 1. Auto-Generate Logic (Smart)
  void autoGeneratePlan() async {
    final recipes = Provider.of<RecipeProvider>(context, listen: false).recipes;
    if (recipes.isEmpty) return;

    // Loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Generating smart plan... 🧠")),
    );

    // 1. Fetch User Preferences
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    Map<String, dynamic>? profile;

    if (user != null) {
      profile = await DatabaseService().getUserProfile(user.uid);
    }

    List<Recipe> validRecipes = recipes;

    // 2. Filter by Diet & Allergy (if profile exists)
    if (profile != null) {
      String? diet = profile['dietType'];
      String? allergy = profile['allergies'];

      validRecipes =
          recipes.where((r) {
            bool matchesDiet = diet == null || r.dietType == diet;
            bool safeFromAllergy =
                allergy == null ||
                allergy == 'None' ||
                !r.ingredients.any((i) => i.contains(allergy));
            return matchesDiet && safeFromAllergy;
          }).toList();
    }

    if (validRecipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No matching recipes found for your diet! 😕"),
        ),
      );
      return;
    }

    // 3. Random Fill
    setState(() {
      final random = Random();
      MealPlanManager.weeklyPlan.updateAll((key, value) {
        return validRecipes[random.nextInt(validRecipes.length)];
      });
    });

    _savePlanToFirebase(); // Save after generating

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Weekly Plan Generated! ✨")));
  }

  // Helper to Save Plan
  Future<void> _savePlanToFirebase() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user == null) return;

    // Convert Recipe Objects to IDs
    Map<String, String?> planMap = {};
    MealPlanManager.weeklyPlan.forEach((day, recipe) {
      planMap[day] = recipe?.id;
    });

    await DatabaseService().saveWeeklyPlan(user.uid, planMap);
  }

  void _showNutritionDialog() {
    int totalCalories = 0;
    Map<String, int> nutrientCounts = {'Protein': 0, 'Carbs': 0, 'Fats': 0};

    MealPlanManager.weeklyPlan.forEach((day, recipe) {
      if (recipe != null) {
        totalCalories += recipe.calories;
        // Mocking macro data since simple RecipeModel only has calories
        // In real app, model would have protein/carbs/fats
      }
    });

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Weekly Nutrition 📊"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  title: const Text("Total Calories"),
                  subtitle: Text(
                    "$totalCalories kcal",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Divider(),
                const Text(
                  "Based on Planned Meals",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  // 2. Manual Add Logic
  Future<void> _pickRecipeForDay(String day) async {
    final Recipe? selectedRecipe = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RecipePickerScreen()),
    );

    if (selectedRecipe != null) {
      setState(() {
        MealPlanManager.weeklyPlan[day] = selectedRecipe;
      });
      _savePlanToFirebase();
    }
  }

  // 3. Clear All Confirmation Logic
  void _clearAllPlan() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Clear Weekly Plan?"),
            content: const Text(
              "Are you sure you want to delete ALL meals from the schedule?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx), // Cancel
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    MealPlanManager.weeklyPlan.updateAll((key, value) => null);
                  });
                  _savePlanToFirebase();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All meals cleared! 🗑️")),
                  );
                },
                child: const Text(
                  "Clear All",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // 4. Move Meal Logic
  void _moveMeal(String currentDay, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Move to which day?"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children:
                  MealPlanManager.weeklyPlan.keys.map((targetDay) {
                    return ListTile(
                      title: Text(targetDay),
                      onTap: () {
                        setState(() {
                          MealPlanManager.weeklyPlan[targetDay] = recipe;
                          MealPlanManager.weeklyPlan[currentDay] = null;
                        });
                        _savePlanToFirebase();
                        Navigator.pop(ctx);
                        Navigator.pop(context); // Close bottom sheet
                      },
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }

  // 5. Options Menu
  void _showMealOptions(String day, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.visibility, color: Colors.blue),
                title: const Text("View Recipe"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeDetailsScreen(recipe: recipe),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz, color: Colors.orange),
                title: const Text("Replace Meal"),
                onTap: () {
                  Navigator.pop(context);
                  _pickRecipeForDay(day);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.drive_file_move_outline,
                  color: Colors.purple,
                ),
                title: const Text("Move to Another Day"),
                onTap: () {
                  _moveMeal(day, recipe);
                },
              ),
              // Option inside Menu
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remove this Meal"),
                onTap: () {
                  setState(() {
                    MealPlanManager.weeklyPlan[day] = null;
                  });
                  _savePlanToFirebase();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Weekly Planner"),
        actions: [
          // Clear All Button (With Warning)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear All",
            onPressed: _clearAllPlan, // Ab ye direct delete nahi karega
          ),
          TextButton.icon(
            onPressed: autoGeneratePlan,
            icon: const Icon(Icons.autorenew, color: Color(0xFF4CAF50)),
            label: const Text(
              "Auto-Fill",
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children:
            MealPlanManager.weeklyPlan.entries.map((entry) {
              String day = entry.key;
              Recipe? recipe = entry.value;

              // Card Widget
              Widget cardContent = Card(
                margin: const EdgeInsets.only(bottom: 15),
                color: Theme.of(context).cardColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    if (recipe == null) {
                      _pickRecipeForDay(day);
                    } else {
                      _showMealOptions(day, recipe);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                            image:
                                recipe != null
                                    ? DecorationImage(
                                      image: NetworkImage(recipe.image),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                          ),
                          child:
                              recipe == null
                                  ? const Icon(
                                    Icons.add,
                                    color: Colors.grey,
                                    size: 30,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color:
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                recipe != null
                                    ? recipe.name
                                    : "Tap to add meal",
                                style: TextStyle(
                                  color:
                                      recipe != null
                                          ? (isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[800])
                                          : Colors.grey,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (recipe != null)
                                Text(
                                  "${recipe.calories} Kcal • ${recipe.time}",
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Icon(
                          recipe == null
                              ? Icons.add_circle_outline
                              : Icons.more_vert,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              );

              // ✅ SWIPE TO DELETE FEATURE
              // Agar recipe hai to Dismissible lagao, warna simple card dikhao
              if (recipe != null) {
                return Dismissible(
                  key: Key(day + recipe.name), // Unique Key
                  direction:
                      DismissDirection
                          .endToStart, // Sirf Right to Left swipe hoga
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      MealPlanManager.weeklyPlan[day] = null;
                    });
                    _savePlanToFirebase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("$day meal removed")),
                    );
                  },
                  child: cardContent,
                );
              } else {
                return cardContent;
              }
            }).toList(),
      ),
    );
  }
}
