import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/providers/PropertyProvider.dart';
import 'package:homesphere/pages/property_owner/PropertyPage.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:homesphere/services/functions/ImageSlider.dart';
import 'package:homesphere/utils/consts.dart';
import 'package:http/http.dart' as http;

class RentProperty extends StatefulWidget {
  const RentProperty({super.key});

  @override
  State<RentProperty> createState() => _RentPropertyState();
}

class _RentPropertyState extends State<RentProperty> {
  final TextEditingController _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid calling provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    await propertyProvider.loadProperties();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _handleSearch(String query) {
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.searchProperties(query);
  }

  void _clearSearch() {
    _searchController.clear();
    final propertyProvider =
        Provider.of<PropertyProvider>(context, listen: false);
    propertyProvider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
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
                        hintText:
                            "Search properties by description, title, or location...",
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: _clearSearch,
                              )
                            : null,
                      ),
                      onChanged: _handleSearch,
                    ),
                  ),
                ],
              ),
            ),

            // Image Slider
            ImageSlider(images: consts.sliderRentImages),
            const SizedBox(height: 8),

            // Properties List
            Expanded(
              child: !_isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<PropertyProvider>(
                      builder: (context, propertyProvider, child) {
                        if (propertyProvider.isLoading) {
                          return _buildShimmerLoading();
                        }

                        if (propertyProvider.error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Error: ${propertyProvider.error}",
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _initializeData,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        final properties = propertyProvider.rentProperties;

                        if (properties.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _searchController.text.isNotEmpty
                                      ? Icons.search_off
                                      : Icons.home,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? "No properties found matching your search"
                                      : "No properties available for rent",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Properties List Title
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _searchController.text.isNotEmpty
                                    ? "Search Results (${properties.length})"
                                    : "Properties for Rent (${properties.length})",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () =>
                                    propertyProvider.refreshProperties(),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: properties.length,
                                  itemBuilder: (context, index) {
                                    return _buildPropertyCard(
                                        properties[index]);
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
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
        leading: property.id == null
            ? const Icon(Icons.image, size: 60, color: Colors.grey)
            : FutureBuilder<http.Response>(
                future: PropertyOwnerApi.getImageByPropertyId(property.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error, color: Colors.red);
                  } else if (snapshot.hasData &&
                      snapshot.data!.statusCode == 200) {
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
                    return const Icon(Icons.image,
                        size: 60, color: Colors.grey);
                  }
                },
              ),
        title: Text(
          property.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${property.location} - ₹${property.price}/month"),
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 150,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
