import 'package:cloud_firestore/cloud_firestore.dart';

class PantryItemModel {
  final String? id;
  final String name;
  final String quantity;
  final Timestamp? expiryDate;

  PantryItemModel({
    this.id,
    required this.name,
    required this.quantity,
    this.expiryDate,
  });

  factory PantryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PantryItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? '',
      expiryDate: data['expiryDate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate,
    };
  }

  PantryItemModel copyWith({
    String? id,
    String? name,
    String? quantity,
    Timestamp? expiryDate,
  }) {
    return PantryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}
