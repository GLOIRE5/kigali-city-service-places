import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listingsRef => _firestore.collection('listings');

  /// Real-time stream of all listings
  Stream<List<Listing>> get listingsStream {
    return _listingsRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Listing.fromDocument(doc)).toList());
  }

  /// Create a new listing
  Future<DocumentReference> createListing(Listing listing) async {
    return await _listingsRef.add(listing.toMap());
  }

  /// Update an existing listing
  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await _listingsRef.doc(id).update(data);
  }

  /// Delete a listing
  Future<void> deleteListing(String id) async {
    await _listingsRef.doc(id).delete();
  }

  /// Get a single listing by ID
  Future<Listing?> getListing(String id) async {
    final doc = await _listingsRef.doc(id).get();
    if (doc.exists) {
      return Listing.fromDocument(doc);
    }
    return null;
  }
}
