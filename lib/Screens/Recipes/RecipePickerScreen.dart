import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Providers/RecipeProvider.dart';
import '../../Models/RecipeModel.dart';

class RecipePickerScreen extends StatelessWidget {
  const RecipePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access recipes from Provider
    final recipes = Provider.of<RecipeProvider>(context).recipes;

    return Scaffold(
      appBar: AppBar(title: const Text("Select a Meal")),
      body:
          recipes.isEmpty
              ? const Center(child: Text("No recipes available"))
              : ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(recipe.image),
                    ),
                    title: Text(recipe.name),
                    subtitle: Text("${recipe.calories} Kcal | ${recipe.time}"),
                    trailing: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                    onTap: () {
                      // Jab user click karega, ye Recipe wapas bhej di jayegi
                      Navigator.pop(context, recipe);
                    },
                  );
                },
              ),
    );
  }
}
