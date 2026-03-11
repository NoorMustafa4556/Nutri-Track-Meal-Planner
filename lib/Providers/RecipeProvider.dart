import 'package:flutter/material.dart';
import '../Models/RecipeModel.dart';
import '../Services/RecipeService.dart';
import '../Services/DatabaseService.dart';

class RecipeProvider with ChangeNotifier {
  final RecipeService _recipeService = RecipeService();

  List<Recipe> _recipes = [];
  bool _isLoading = false;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();

    _recipes = await _recipeService.loadRecipes();

    _isLoading = false;
    notifyListeners();
  }

  // Filter recipes logic can also move here later
  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) {
      return _recipes;
    }
    return _recipes
        .where(
          (recipe) =>
              recipe.name.toLowerCase().contains(query.toLowerCase()) ||
              recipe.ingredients.any(
                (ing) => ing.toLowerCase().contains(query.toLowerCase()),
              ),
        )
        .toList();
  }

  // Smart Filter by Preferences
  List<Recipe> filterByPreferences(String? dietType, String? allergies) {
    // If no preferences set, return all
    if ((dietType == null || dietType.isEmpty) &&
        (allergies == null || allergies == "None")) {
      return _recipes;
    }

    return _recipes.where((recipe) {
      bool matchesDiet = true;
      bool matchesAllergy = true;

      // 1. Diet Check (With Hierarchy)
      if (dietType != null && dietType.isNotEmpty) {
        final rDiet = recipe.dietType.toLowerCase();
        final uDiet = dietType.toLowerCase();

        // Exact match covers most
        if (rDiet == uDiet) {
          matchesDiet = true;
        }
        // Hierarchy Logic
        else if (uDiet == 'vegetarian') {
          // Vegetarians can eat Vegan, High-Protein (if not meat), Keto (if not meat)
          // For safety, we check if recipe is explicitly Vegan
          matchesDiet = rDiet == 'vegan' || rDiet == 'vegetarian';
        } else if (uDiet == 'non-veg') {
          // Non-Veg can eat everything
          matchesDiet = true;
        } else if (uDiet == 'low-carb') {
          // Low-carb users can eat Keto
          matchesDiet = rDiet == 'keto' || rDiet == 'low-carb';
        } else {
          // For specific diets like Keto/Vegan, we need strict match
          matchesDiet = false;
        }
      }

      // 2. Allergy Check (Smart)
      if (allergies != null && allergies.isNotEmpty && allergies != "None") {
        List<String> riskyIngredients = [allergies.toLowerCase()];

        // Expand risky terms
        if (allergies == 'Nuts') {
          riskyIngredients.addAll([
            'almond',
            'cashew',
            'walnut',
            'pecan',
            'peanut',
            'pistachio',
            'nut',
          ]);
        } else if (allergies == 'Gluten') {
          riskyIngredients.addAll([
            'wheat',
            'flour',
            'bread',
            'pasta',
            'barley',
            'rye',
            'oats',
          ]);
        } else if (allergies == 'Dairy') {
          riskyIngredients.addAll([
            'milk',
            'cheese',
            'yogurt',
            'cream',
            'butter',
            'whey',
            'casein',
          ]);
        } else if (allergies == 'Eggs') {
          riskyIngredients.addAll(['egg', 'mayo']);
        }

        for (var ing in recipe.ingredients) {
          for (var risk in riskyIngredients) {
            if (ing.toLowerCase().contains(risk)) {
              matchesAllergy = false;
              break;
            }
          }
          if (!matchesAllergy) break;
        }
      }

      return matchesDiet && matchesAllergy;
    }).toList();
  }

  // Favorites Logic
  List<String> _favoriteIds = [];

  // Update recipe objects based on favorite IDs
  void _syncFavorites() {
    for (var recipe in _recipes) {
      recipe.isFavorite = _favoriteIds.contains(recipe.id);
    }
    notifyListeners();
  }

  // Load Favorites from Firebase
  Future<void> loadFavorites(String uid) async {
    // 1. Get from Firebase (Assuming DatabaseService has getFavorites... wait, let's check)
    // We didn't explicitly make getFavorites in DatabaseService but we can fetch user doc
    // Actually, let's use DatabaseService().getUserProfile to get the list
    /* 
       Note: ideally DatabaseService should expose getFavorites. 
       For now, we will add fetchFavorites logic here or in DB service.
       Let's stick to using what we have or extending DB service slightly.
    */
  }

  // Toggle Favorite
  Future<void> toggleFavorite(String recipeId, String userId) async {
    final recipe = _recipes.firstWhere((r) => r.id == recipeId);

    // Optimistic Update
    recipe.isFavorite = !recipe.isFavorite;
    if (recipe.isFavorite) {
      _favoriteIds.add(recipeId);
    } else {
      _favoriteIds.remove(recipeId);
    }
    notifyListeners();

    // Persist to Firebase
    try {
      await DatabaseService().updateFavorites(userId, _favoriteIds);
    } catch (e) {
      // Revert if failed
      recipe.isFavorite = !recipe.isFavorite;
      if (recipe.isFavorite)
        _favoriteIds.add(recipeId);
      else
        _favoriteIds.remove(recipeId);
      notifyListeners();
      print("Error saving favorite: $e");
    }
  }

  // Set initial favorites (called after loading user)
  void setFavorites(List<String> ids) {
    _favoriteIds = ids;
    _syncFavorites();
  }
}
