import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/pages/property_owner/PropertyPage.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:homesphere/services/functions/ImageSlider.dart';
import 'package:homesphere/utils/consts.dart';
import 'package:http/http.dart' as http;

class BuyProperty extends StatefulWidget {
  const BuyProperty({super.key});

  @override
  State<BuyProperty> createState() => _BuyPropertyState();
}

class _BuyPropertyState extends State<BuyProperty> {
  late Future<List<Property>> _propertiesFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Property> _filteredProperties = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    _propertiesFuture = PropertyOwnerApi.getPropertiesByType("buy");
    setState(() {});
  }

  void _filterProperties(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    if (query.isEmpty) {
      _loadProperties();
      return;
    }

    _propertiesFuture.then((properties) {
      setState(() {
        _filteredProperties = properties.where((property) {
          final description = property.description.toLowerCase();
          final title = property.title.toLowerCase();
          final location = property.location.toLowerCase();
          final searchQuery = query.toLowerCase();

          return description.contains(searchQuery) ||
              title.contains(searchQuery) ||
              location.contains(searchQuery);
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search properties by description...",
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterProperties('');
                                  },
                                )
                              : null,
                        ),
                        onChanged: _filterProperties,
                      ),
                    ),
                  ],
                ),
              ),

              // Image Slider
              ImageSlider(images: consts.sliderBuyImages),
              const SizedBox(height: 16),

              // Properties List Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _isSearching
                      ? "Search Results (${_filteredProperties.length})"
                      : "Available Properties",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Properties List
              FutureBuilder<List<Property>>(
                future: _propertiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerLoading();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No properties found."),
                    );
                  }

                  final properties =
                      _isSearching ? _filteredProperties : snapshot.data!;

                  if (_isSearching && _filteredProperties.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No properties found matching your search",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: properties.length,
                    itemBuilder: (context, index) {
                      return _buildPropertyCard(properties[index]);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Property property) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: FutureBuilder<http.Response>(
          future: PropertyOwnerApi.getImageByPropertyId(property.id!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Icon(Icons.error, color: Colors.red);
            } else if (snapshot.hasData && snapshot.data!.statusCode == 200) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  snapshot.data!.bodyBytes,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const Icon(Icons.image, size: 60, color: Colors.grey);
            }
          },
        ),
        title: Text(
          property.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${property.location} - ₹${property.price}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyPage(property: property),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
