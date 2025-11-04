import 'package:cloud_firestore/cloud_firestore.dart';

class VaultItemModel {
  final String? id;
  final String name;
  final String type; // e.g., "Warranty", "Document"
  final String? fileName;
  final String? fileUrl; // For photo of receipt
  final Timestamp? purchaseDate;
  final Timestamp? expiryDate;
  final String? autoTaskId;

  VaultItemModel({
    this.id,
    required this.name,
    required this.type,
    this.fileName,
    this.fileUrl,
    this.purchaseDate,
    this.expiryDate,
    this.autoTaskId,
  });

  factory VaultItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VaultItemModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Document',
      fileName: data['fileName'],
      fileUrl: data['fileUrl'],
      purchaseDate: data['purchaseDate'],
      expiryDate: data['expiryDate'],
      autoTaskId: data['autoTaskId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'purchaseDate': purchaseDate,
      'expiryDate': expiryDate,
      'autoTaskId': autoTaskId,
    };
  }
}
