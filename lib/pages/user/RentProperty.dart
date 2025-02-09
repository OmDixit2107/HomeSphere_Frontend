import 'package:flutter/material.dart';

class Rentproperty extends StatelessWidget {
  const Rentproperty({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search properties...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Banner Image
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300], // Placeholder color
                    image: const DecorationImage(
                      image: AssetImage(
                          "assets/images/rent1.jpeg"), // Ensure correct path
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Properties List Title
                const Text(
                  "Available Properties",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Property List (Scrollable Inside a Column)
                ListView.builder(
                  shrinkWrap:
                      true, // Allows ListView to scroll inside SingleChildScrollView
                  physics:
                      const NeverScrollableScrollPhysics(), // Prevents conflict with main scroll
                  itemCount: 10, // Replace with actual API data count
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          color: Colors
                              .grey[300], // Placeholder for property image
                        ),
                        title: Text("Property ${index + 1}"),
                        subtitle: const Text("Property details go here"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                        onTap: () {
                          // Navigate to property details
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
