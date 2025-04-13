import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _buyProperties = [];
  List<Property> _rentProperties = [];
  List<Property> _filteredBuyProperties = [];
  List<Property> _filteredRentProperties = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoadedProperties = false;

  // Getters
  List<Property> get buyProperties => _filteredBuyProperties.isNotEmpty
      ? _filteredBuyProperties
      : _buyProperties;

  List<Property> get rentProperties => _filteredRentProperties.isNotEmpty
      ? _filteredRentProperties
      : _rentProperties;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load properties of both types (buy and rent)
  Future<void> loadProperties() async {
    // If properties are already loaded, don't load again
    if (_hasLoadedProperties) return;

    _setLoading(true);
    try {
      // Load buy properties
      final buyPropertiesResult =
          await PropertyOwnerApi.getPropertiesByType('buy');
      _buyProperties = buyPropertiesResult ?? [];

      // Load rent properties
      final rentPropertiesResult =
          await PropertyOwnerApi.getPropertiesByType('rent');
      _rentProperties = rentPropertiesResult ?? [];

      _hasLoadedProperties = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Refresh properties
  Future<void> refreshProperties() async {
    _hasLoadedProperties = false;
    _filteredBuyProperties = [];
    _filteredRentProperties = [];
    await loadProperties();
  }

  // Search/filter properties
  void searchProperties(String query) {
    if (query.isEmpty) {
      _filteredBuyProperties = [];
      _filteredRentProperties = [];
    } else {
      final lowerQuery = query.toLowerCase();

      _filteredBuyProperties = _buyProperties.where((property) {
        final titleMatch = property.title.toLowerCase().contains(lowerQuery);
        final descriptionMatch =
            property.description.toLowerCase().contains(lowerQuery);
        final locationMatch =
            property.location.toLowerCase().contains(lowerQuery);
        return titleMatch || descriptionMatch || locationMatch;
      }).toList();

      _filteredRentProperties = _rentProperties.where((property) {
        final titleMatch = property.title.toLowerCase().contains(lowerQuery);
        final descriptionMatch =
            property.description.toLowerCase().contains(lowerQuery);
        final locationMatch =
            property.location.toLowerCase().contains(lowerQuery);
        return titleMatch || descriptionMatch || locationMatch;
      }).toList();
    }

    notifyListeners();
  }

  // Clear search filters
  void clearSearch() {
    _filteredBuyProperties = [];
    _filteredRentProperties = [];
    notifyListeners();
  }

  // Helper method to set loading state with post-frame callback
  void _setLoading(bool loading) {
    _isLoading = loading;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Helper method to set error and notify with post-frame callback
  void _setError(String errorMsg) {
    _error = errorMsg;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
