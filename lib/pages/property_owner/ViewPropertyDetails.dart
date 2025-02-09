import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:http/http.dart' as http;

class ViewPropertyDetails extends StatefulWidget {
  final int propertyId; // Property ID to fetch details

  const ViewPropertyDetails({super.key, required this.propertyId});

  @override
  State<ViewPropertyDetails> createState() => _ViewPropertyDetailsState();
}

class _ViewPropertyDetailsState extends State<ViewPropertyDetails> {
  late Future<Property?> _propertyFuture;

  @override
  void initState() {
    super.initState();
    _propertyFuture = PropertyOwnerApi.getPropertyById(widget.propertyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Property Details")),
      body: FutureBuilder<Property?>(
        future: _propertyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null) {
            return const Center(child: Text("Property not found"));
          }

          Property property = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fetch and display property image
                FutureBuilder<http.Response>(
                  future: PropertyOwnerApi.getImageByPropertyId(property.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    } else if (snapshot.hasData &&
                        snapshot.data!.statusCode == 200) {
                      return Image.memory(
                        snapshot.data!.bodyBytes,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      );
                    } else {
                      return const Icon(Icons.image,
                          size: 50, color: Colors.grey);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Property Title & Price
                Text(
                  property.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹ ${property.price.toString()}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 10),

                // Property Details
                PropertyDetailRow(
                    icon: Icons.location_on,
                    label: "Location",
                    value: property.location),
                PropertyDetailRow(
                    icon: Icons.apartment, label: "Type", value: property.type),
                PropertyDetailRow(
                    icon: Icons.check_circle,
                    label: "Status",
                    value: property.status),
                PropertyDetailRow(
                  icon: Icons.payment,
                  label: "EMI Available",
                  value: property.emiAvailable ? "Yes" : "No",
                ),
                const SizedBox(height: 16),

                // Property Description
                const Text(
                  "Description:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  property.description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Inquiry
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Inquire",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle Offer
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                        child: const Text("Make an Offer",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget for displaying property details row
class PropertyDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const PropertyDetailRow(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.blue),
          const SizedBox(width: 8),
          Text("$label: ",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
