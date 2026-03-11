import 'dart:convert';
import 'package:flutter/services.dart';
import '../Models/RecipeModel.dart';

class RecipeService {
  Future<List<Recipe>> loadRecipes() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/recipes.json',
      );
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print("Error loading recipes: $e");
      return [];
    }
  }
}
