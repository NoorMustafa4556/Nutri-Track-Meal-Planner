import 'package:flutter/foundation.dart';

class GroceryManager {
  // Ye list poori app mein same rahegi
  static List<Map<String, dynamic>> groceryList = [];

  // List ko update karne ka function
  static void generateList(List<String> newItems) {
    // Purana delete karke naya add karein (ya append karein logic ke hisaab se)
    groceryList.clear();
    for (var item in newItems) {
      groceryList.add({
        'name': item,
        'isChecked': false,
      });
    }
  }

  static void toggleCheck(int index) {
    groceryList[index]['isChecked'] = !groceryList[index]['isChecked'];
  }
}