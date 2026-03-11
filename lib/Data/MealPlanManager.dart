import '../Models/RecipeModel.dart';

// Global Variable to store the Weekly Plan (Temporary until Firebase)
class MealPlanManager {
  static Map<String, Recipe?> weeklyPlan = {
    "Monday": null,
    "Tuesday": null,
    "Wednesday": null,
    "Thursday": null,
    "Friday": null,
    "Saturday": null,
    "Sunday": null,
  };

  // Generate Shopping List from Weekly Plan
  static List<String> generateShoppingList() {
    Set<String> uniqueIngredients = {}; // Set automatically removes duplicates

    weeklyPlan.forEach((day, recipe) {
      if (recipe != null) {
        uniqueIngredients.addAll(recipe.ingredients);
      }
    });

    return uniqueIngredients.toList();
  }
}