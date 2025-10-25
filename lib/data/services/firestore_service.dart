import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Database Service
/// Handles all Cloud Firestore CRUD operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a document in a collection
  Future<String> create(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  /// Set a document with specific ID (overwrites if exists)
  Future<void> set(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to set document: $e');
    }
  }

  /// Update a document
  Future<void> update(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  /// Delete a document
  Future<void> delete(String collection, String documentId) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  /// Get a single document
  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document: $e');
    }
  }

  /// Get all documents in a collection
  Stream<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Query documents with where clause
  Stream<QuerySnapshot> queryCollection(
    String collection, {
    required String field,
    required dynamic isEqualTo,
  }) {
    return _firestore
        .collection(collection)
        .where(field, isEqualTo: isEqualTo)
        .snapshots();
  }

  /// Query with multiple conditions
  Stream<QuerySnapshot> queryWithConditions(
    String collection,
    Map<String, dynamic> conditions, {
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query query = _firestore.collection(collection);

    // Apply where conditions
    conditions.forEach((field, value) {
      query = query.where(field, isEqualTo: value);
    });

    // Apply ordering
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots();
  }

  /// Batch write operations (for multiple operations at once)
  Future<void> batchWrite(
    List<Map<String, dynamic>> operations,
  ) async {
    try {
      final batch = _firestore.batch();

      for (var operation in operations) {
        final ref = _firestore
            .collection(operation['collection'])
            .doc(operation['documentId']);

        switch (operation['type']) {
          case 'set':
            batch.set(ref, operation['data']);
            break;
          case 'update':
            batch.update(ref, operation['data']);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch write: $e');
    }
  }
}


