class Recipe {
  final String id;
  final String name;
  final String image;
  final String time;
  final int calories;
  final int protein; // grams
  final int carbs; // grams
  final int fats; // grams
  final double rating;
  final String dietType; // Veg, Keto, High-Protein etc.
  final List<String> ingredients;
  final List<String> steps;
  bool isFavorite; // Ye change ho sakta hai isliye final nahi hai

  Recipe({
    required this.id,
    required this.name,
    required this.image,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.rating,
    required this.dietType,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false, // Default false rahega
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      time: json['time'],
      calories: json['calories'],
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      rating: (json['rating'] as num).toDouble(),
      dietType: json['dietType'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
