import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Services/AuthService.dart';
import '../../Services/DatabaseService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedDiet;
  String? selectedAllergy;
  final _caloriesController = TextEditingController();
  bool _isLoading = false;

  final List<String> diets = [
    'Vegetarian',
    'Non-Veg',
    'Keto',
    'Vegan',
    'Low-Carb',
    'High-Protein',
  ];
  final List<String> allergies = ['None', 'Nuts', 'Dairy', 'Gluten', 'Eggs'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final data = await DatabaseService().getUserProfile(user.uid);

      if (data != null) {
        if (mounted) {
          setState(() {
            // Robust Diet Matching
            String? fetchedDiet = data['dietType']?.toString().trim();
            if (fetchedDiet != null) {
              try {
                selectedDiet = diets.firstWhere(
                  (d) => d.toLowerCase() == fetchedDiet.toLowerCase(),
                );
              } catch (e) {
                selectedDiet = diets.first;
              }
            } else {
              selectedDiet = diets.first;
            }

            // Robust Allergy Matching
            String? fetchedAllergy = data['allergies']?.toString().trim();
            if (fetchedAllergy != null) {
              try {
                selectedAllergy = allergies.firstWhere(
                  (a) => a.toLowerCase() == fetchedAllergy.toLowerCase(),
                );
              } catch (e) {
                selectedAllergy = "None";
              }
            } else {
              selectedAllergy = "None";
            }

            _caloriesController.text = data['calories'] ?? '';
          });
        }
      }
    }
    setState(() => _isLoading = false);
  }

  void _saveProfile() async {
    if (selectedDiet == null || selectedAllergy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select diet and allergies")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user != null) {
        await DatabaseService().saveUserProfile(user.uid, {
          'dietType': selectedDiet,
          'allergies': selectedAllergy,
          'calories': _caloriesController.text.trim(),
          'email': user.email,
        });

        if (mounted) {
          await showDialog(
            context: context,
            builder:
                (ctx) => AlertDialog(
                  title: const Text("Success"),
                  content: const Text("Profile Saved Successfully!"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User not found. Please login again."),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text("Error"),
                content: Text("Failed to save profile: $e"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("OK"),
                  ),
                ],
              ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Complete Profile",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // Added scroll for smaller screens
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.settings_accessibility,
              size: 80,
              color: Color(0xFF4CAF50),
            ),
            const SizedBox(height: 20),
            const Text(
              "Help us tailor recipes for you!",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Diet Dropdown
            DropdownButtonFormField<String>(
              value: selectedDiet, // Fix: Bind variable to showing value
              decoration: const InputDecoration(
                labelText: "Dietary Preference",
                prefixIcon: Icon(Icons.restaurant),
              ),
              items:
                  diets.map((String diet) {
                    return DropdownMenuItem(value: diet, child: Text(diet));
                  }).toList(),
              onChanged: (val) => setState(() => selectedDiet = val),
            ),
            const SizedBox(height: 20),

            // Allergy Dropdown
            DropdownButtonFormField<String>(
              value: selectedAllergy, // Fix: Bind variable to showing value
              decoration: const InputDecoration(
                labelText: "Allergies",
                prefixIcon: Icon(Icons.warning_amber_rounded),
              ),
              items:
                  allergies.map((String allergy) {
                    return DropdownMenuItem(
                      value: allergy,
                      child: Text(allergy),
                    );
                  }).toList(),
              onChanged: (val) => setState(() => selectedAllergy = val),
            ),
            const SizedBox(height: 20),

            // Calorie Goal Input
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Daily Calorie Goal (Optional)",
                hintText: "e.g. 2000",
                prefixIcon: Icon(Icons.local_fire_department),
              ),
            ),

            const SizedBox(height: 50), // Spacer replacement

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "FINISH SETUP",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
