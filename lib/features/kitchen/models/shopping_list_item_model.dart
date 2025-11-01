import 'package:cloud_firestore/cloud_firestore.dart';

// Based on /households/{householdId}/shoppingListItems/{itemId}
class ShoppingListItemModel {
  final String? id;
  final String name;
  final String? quantity;
  final bool isChecked;
  final String addedBy; // UID of user who added it

  ShoppingListItemModel({
    this.id,
    required this.name,
    this.quantity,
    this.isChecked = false,
    required this.addedBy,
  });

  // Factory constructor to create from a Firestore DocumentSnapshot
  factory ShoppingListItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShoppingListItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'],
      isChecked: data['isChecked'] ?? false,
      addedBy: data['addedBy'] ?? '',
    );
  }

  // Method to convert to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'isChecked': isChecked,
      'addedBy': addedBy,
    };
  }

  // Helper method for updating
  ShoppingListItemModel copyWith({
    String? id,
    String? name,
    String? quantity,
    bool? isChecked,
    String? addedBy,
  }) {
    return ShoppingListItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      addedBy: addedBy ?? this.addedBy,
    );
  }
}
