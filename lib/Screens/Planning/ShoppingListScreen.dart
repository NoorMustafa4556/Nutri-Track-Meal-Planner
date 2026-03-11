import 'package:flutter/material.dart';
import '../../Data/MealPlanManager.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<String> groceryList = [];
  Map<String, bool> checkedItems = {};

  @override
  void initState() {
    super.initState();
    // Shuru mein list khali rakhein ya purani load karein (Option apki marzi)
    // Filhal hum empty rakhte hain taake user khud generate kare
  }

  // --- LOGIC: Popup dikhana aur Din select karna ---
  void _showGenerateDialog() {
    // 1. Sirf wo din dhundo jahan khana plan kiya hua hai
    final plannedDays =
        MealPlanManager.weeklyPlan.keys
            .where((day) => MealPlanManager.weeklyPlan[day] != null)
            .toList();

    if (plannedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No meals planned yet! Go to Planner first."),
        ),
      );
      return;
    }

    // By default saare din select karlo
    List<String> selectedDays = List.from(plannedDays);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Select Days to Shop For"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    // --- Select All Option ---
                    CheckboxListTile(
                      activeColor: const Color(0xFF4CAF50),
                      title: const Text(
                        "Select All",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: selectedDays.length == plannedDays.length,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            selectedDays = List.from(plannedDays);
                          } else {
                            selectedDays.clear();
                          }
                        });
                      },
                    ),
                    const Divider(),

                    // --- Individual Days ---
                    ...plannedDays.map((day) {
                      return CheckboxListTile(
                        activeColor: const Color(0xFF4CAF50),
                        title: Text(day),
                        value: selectedDays.contains(day),
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              selectedDays.add(day);
                            } else {
                              selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                  onPressed: () {
                    _generateListFromSelection(selectedDays);
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    "Generate List",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- LOGIC: List banana ---
  void _generateListFromSelection(List<String> selectedDays) {
    Set<String> uniqueIngredients =
        {}; // Set use kiya taake duplicates na aayein

    for (var day in selectedDays) {
      var recipe = MealPlanManager.weeklyPlan[day];
      if (recipe != null) {
        // Agar recipe mein ingredients hain to add karo
        if (recipe.ingredients.isNotEmpty) {
          uniqueIngredients.addAll(recipe.ingredients);
        } else {
          // Fallback agar dummy data mein ingredients nahi hain
          uniqueIngredients.add("${recipe.name} Ingredients");
        }
      }
    }

    setState(() {
      groceryList = uniqueIngredients.toList();
      // Naye items ke liye checkbox reset karo
      checkedItems.clear();
      for (var item in groceryList) {
        checkedItems[item] = false;
      }
    });
  }

  void _showAddCustomItemDialog() {
    String newItem = "";
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Add Custom Item"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: "e.g. Milk"),
              onChanged: (val) => newItem = val,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (newItem.trim().isNotEmpty) {
                    setState(() {
                      groceryList.add(newItem.trim());
                      checkedItems[newItem.trim()] = false;
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("Grocery List"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white), // Add Button
            tooltip: "Add Item",
            onPressed: _showAddCustomItemDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                groceryList.clear();
                checkedItems.clear();
              });
            },
          ),
        ],
      ),

      // ✅ Generate Button Yahan Add Kiya Hai
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGenerateDialog,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text("Generate", style: TextStyle(color: Colors.white)),
      ),

      body:
          groceryList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Your list is empty!",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Tap 'Generate' to create a list from Planner",
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 80,
                ), // Bottom padding button ke liye
                itemCount: groceryList.length,
                itemBuilder: (context, index) {
                  String item = groceryList[index];
                  // Checkbox safe access
                  bool isChecked = checkedItems[item] ?? false;

                  return Card(
                    color: Theme.of(context).cardColor,
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      activeColor: const Color(0xFF4CAF50),
                      checkColor: Colors.white,
                      title: Text(
                        item,
                        style: TextStyle(
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          color:
                              isChecked
                                  ? Colors.grey
                                  : Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                        ),
                      ),
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          checkedItems[item] = value!;
                        });
                      },
                    ),
                  );
                },
              ),
    );
  }
}
