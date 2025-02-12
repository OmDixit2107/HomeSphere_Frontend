import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:http/http.dart' as http;

class PropertyPage extends StatelessWidget {
  final Property property;

  const PropertyPage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            FutureBuilder<http.Response>(
              future: PropertyOwnerApi.getImageByPropertyId(property.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data!.statusCode == 200) {
                  return Image.memory(
                    snapshot.data!.bodyBytes,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                } else {
                  return const Center(
                    child: Icon(Icons.image, size: 250, color: Colors.grey),
                  );
                }
              },
            ),
            const SizedBox(height: 16),

            // Property Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${property.location} - ₹${property.price.toStringAsFixed(2)}",
                    style:
                        const TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    property.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(property.type.toUpperCase()),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      Chip(
                        label: Text(property.status.toUpperCase()),
                        backgroundColor:
                            property.status.toLowerCase() == "available"
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                      ),
                      if (property.emiAvailable)
                        const Chip(
                          label: Text("EMI Available"),
                          backgroundColor: Colors.purpleAccent,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement contact functionality
        },
        child: const Icon(Icons.phone),
      ),
    );
  }
}
