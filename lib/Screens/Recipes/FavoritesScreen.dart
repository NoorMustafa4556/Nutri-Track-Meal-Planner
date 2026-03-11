import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/RecipeProvider.dart';
import 'RecipeDetailsScreen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    // Filter recipes that are marked as Favorite from Provider
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favoriteRecipes =
        recipeProvider.recipes.where((r) => r.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Favorites ❤️",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          favoriteRecipes.isEmpty
              ? const Center(child: Text("No favorite recipes yet!"))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = favoriteRecipes[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          recipe.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        recipe.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${recipe.calories} kcal  •  ${recipe.time}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    RecipeDetailsScreen(recipe: recipe),
                          ),
                        ).then(
                          (_) => setState(() {}),
                        ); // Refresh when coming back
                      },
                    ),
                  );
                },
              ),
    );
  }
}
