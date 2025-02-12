import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/pages/property_owner/EditProperty.dart';
import 'package:homesphere/pages/property_owner/PropertyPage.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:http/http.dart' as http;

class ManageListingsScreen extends StatefulWidget {
  final int userId; // Pass the user ID to fetch listings

  const ManageListingsScreen({super.key, required this.userId});

  @override
  _ManageListingsScreenState createState() => _ManageListingsScreenState();
}

class _ManageListingsScreenState extends State<ManageListingsScreen> {
  late Future<List<Property>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _propertiesFuture = PropertyOwnerApi.getPropertiesByUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Listings")),
      body: FutureBuilder<List<Property>>(
        future: _propertiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No listings found."));
          }

          List<Property> properties = snapshot.data!;
          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              Property property = properties[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: FutureBuilder<http.Response>(
                    future: PropertyOwnerApi.getImageByPropertyId(property.id!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error, color: Colors.red);
                      } else if (snapshot.hasData &&
                          snapshot.data!.statusCode == 200) {
                        return Image.memory(
                          snapshot.data!.bodyBytes,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        );
                      } else {
                        return const Icon(Icons.image,
                            size: 50, color: Colors.grey);
                      }
                    },
                  ),
                  title: Text(property.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${property.location} - ₹${property.price}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // Navigate to edit property screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EditProperty(propertyId: property.id!);
                          },
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PropertyPage(property: property);
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
