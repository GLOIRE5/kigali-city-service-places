import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/firestore_service.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Listing> _listings = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String? _categoryFilter;
  StreamSubscription? _subscription;

  ListingsProvider() {
    _listenToListings();
  }

  List<Listing> get allListings => _listings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;

  /// Filtered listings based on search and category
  List<Listing> get filteredListings {
    var result = _listings;
    if (_categoryFilter != null && _categoryFilter!.isNotEmpty) {
      result = result.where((l) => l.category == _categoryFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((l) =>
              l.name.toLowerCase().contains(query) ||
              l.address.toLowerCase().contains(query))
          .toList();
    }
    return result;
  }

  /// Listings created by a specific user
  List<Listing> userListings(String uid) {
    return _listings.where((l) => l.createdBy == uid).toList();
  }

  /// Count listings per category
  int countByCategory(String category) {
    return _listings.where((l) => l.category == category).length;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    notifyListeners();
  }

  void _listenToListings() {
    _isLoading = true;
    _subscription = _firestoreService.listingsStream.listen(
      (listings) {
        _listings = listings;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load listings.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> createListing(Listing listing) async {
    try {
      await _firestoreService.createListing(listing);
      return true;
    } catch (e) {
      _error = 'Failed to create listing.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> data) async {
    try {
      await _firestoreService.updateListing(id, data);
      return true;
    } catch (e) {
      _error = 'Failed to update listing.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _firestoreService.deleteListing(id);
      return true;
    } catch (e) {
      _error = 'Failed to delete listing.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
