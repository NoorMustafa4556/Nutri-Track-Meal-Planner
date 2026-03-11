import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../../Models/RecipeModel.dart';
import '../../Providers/RecipeProvider.dart'; // Import Custom Provider
import '../../Services/AuthService.dart';
import '../../Services/DatabaseService.dart';
import '../Recipes/RecipeDetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Ek nayi list banayi jo screen par dikhegi
  List<Recipe> _foundRecipes = [];
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Recipes ko fetch karen jab screen load ho
    // Future.microtask ensures this runs after build context is available
    Future.microtask(
      () => Provider.of<RecipeProvider>(context, listen: false).fetchRecipes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Fetch User for Filtering
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getUserProfile(),
      builder: (context, snapshot) {
        List<Recipe> displayedRecipes = recipeProvider.recipes;

        // Apply Smart Filter if Profile Loaded
        if (snapshot.hasData && snapshot.data != null) {
          String? diet = snapshot.data!['dietType'];
          String? allergies = snapshot.data!['allergies'];
          displayedRecipes = recipeProvider.filterByPreferences(
            diet,
            allergies,
          );
        }

        // Search Overrides/Refines
        if (_searchQuery.isNotEmpty) {
          displayedRecipes =
              displayedRecipes.where((recipe) {
                return recipe.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    recipe.ingredients.any(
                      (ing) => ing.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    );
              }).toList();
        }

        _foundRecipes = displayedRecipes;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 3. Search Bar (Active)
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search recipes...",
                      prefixIcon: const Icon(Icons.search),
                      // Styling Theme se aayegi (main.dart)
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Filter Info Chip
                  if (snapshot.hasData)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.filter_list,
                            size: 16,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Personalized for you: ${snapshot.data!['dietType']}",
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 4. Recipe List (Filtered)
                  Expanded(
                    child:
                        recipeProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _foundRecipes.isNotEmpty
                            ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                  ),
                              itemCount: _foundRecipes.length,
                              itemBuilder: (context, index) {
                                return _buildRecipeCard(_foundRecipes[index]);
                              },
                            )
                            : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No matching recipes found!",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      return await DatabaseService().getUserProfile(user.uid);
    }
    return null;
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsScreen(recipe: recipe),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(recipe.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // Text color theme se
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            recipe.time,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Colors.orange,
                          ),
                          Text(
                            " ${recipe.calories}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
