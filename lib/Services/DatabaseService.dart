import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save User Profile (Diet, Allergies, Calories)
  Future<void> saveUserProfile(
    String uid,
    Map<String, dynamic> userData,
  ) async {
    try {
      print("Saving User Profile for $uid: $userData");
      await _db
          .collection('users')
          .doc(uid)
          .set(userData, SetOptions(merge: true));
      print("User Profile Saved Successfully");
    } catch (e) {
      print("Error saving profile: $e");
      throw e;
    }
  }

  // Get User Profile
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      print("Fetching User Profile for $uid");
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        print("User Profile Data: ${doc.data()}");
        return doc.data() as Map<String, dynamic>;
      }
      print("User Profile Document does not exist");
      return null;
    } catch (e) {
      print("Error getting profile: $e");
      return null;
    }
  }

  // Save Weekly Plan (Day -> RecipeID)
  Future<void> saveWeeklyPlan(String uid, Map<String, String?> plan) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('plans')
          .doc('current')
          .set({'weekPlan': plan, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print("Error saving plan: $e");
    }
  }

  // Get Weekly Plan
  Future<Map<String, dynamic>?> getWeeklyPlan(String uid) async {
    try {
      DocumentSnapshot doc =
          await _db
              .collection('users')
              .doc(uid)
              .collection('plans')
              .doc('current')
              .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting plan: $e");
      return null;
    }
  }

  // Save Favorites (List of IDs)
  Future<void> updateFavorites(String uid, List<String> recipeIds) async {
    try {
      print("Updating favorites for $uid: $recipeIds");
      await _db.collection('users').doc(uid).update({'favorites': recipeIds});
    } catch (e) {
      print("Error updating favorites, trying set: $e");
      // If doc doesn't exist or field missing
      await _db.collection('users').doc(uid).set({
        'favorites': recipeIds,
      }, SetOptions(merge: true));
    }
  }
}
