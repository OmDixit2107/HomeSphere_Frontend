import 'package:flutter/material.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/pages/chat/ChatScreen.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:homesphere/services/api/UserAPI.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyPage extends StatelessWidget {
  final Property property;

  const PropertyPage({super.key, required this.property});

  void _shareProperty() {
    final String shareText = '''
Check out this property on HomeSphere!

${property.title}
Location: ${property.location}
Price: ₹${property.price}
${property.description}
''';
    Share.share(shareText);
  }

  Future<void> _contactOwner() async {
    // Replace with actual phone number from your property model
    const phoneNumber = "tel:+1234567890";
    if (await url_launcher.canLaunchUrl(Uri.parse(phoneNumber))) {
      await url_launcher.launchUrl(Uri.parse(phoneNumber));
    }
  }

  void _openChat(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? email =
        prefs.getString('email'); // Retrieve email from shared preferences

    if (email != null) {
      int? currentUserId = await UserApi.getUserIdByEmail(email);

      if (currentUserId != null && property.id != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              property: property,
              currentUserId: currentUserId.toString(),
              propertyOwnerId: property.id.toString(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load user information')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FutureBuilder<http.Response>(
                future: PropertyOwnerApi.getImageByPropertyId(property.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData &&
                      snapshot.data!.statusCode == 200) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          snapshot.data!.bodyBytes,
                          fit: BoxFit.cover,
                        ),
                        // Gradient overlay for better text visibility
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image,
                          size: 100, color: Colors.grey),
                    );
                  }
                },
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareProperty,
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Implement favorite functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to favorites')),
                  );
                },
              ),
            ],
          ),

          // Property Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.grey, size: 20),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property.location,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${property.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            property.type == "rent" ? "per month" : "",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Property Tags
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPropertyTag(
                        property.type.toUpperCase(),
                        Colors.blue.shade100,
                        Icons.home,
                      ),
                      _buildPropertyTag(
                        property.status.toUpperCase(),
                        property.status.toLowerCase() == "available"
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        Icons.check_circle,
                      ),
                      if (property.emiAvailable)
                        _buildPropertyTag(
                          "EMI Available",
                          Colors.purple.shade100,
                          Icons.account_balance_wallet,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amenities Section (Placeholder - you can add actual amenities)
                  const Text(
                    "Amenities",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAmenitiesList(),
                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _contactOwner,
                  icon: const Icon(Icons.phone),
                  label: const Text("Call"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openChat(context),
                  icon: const Icon(Icons.chat),
                  label: const Text("Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildAmenitiesList() {
    // Placeholder amenities - you can make these dynamic based on your property model
    final amenities = [
      {'icon': Icons.local_parking, 'name': 'Parking'},
      {'icon': Icons.security, 'name': 'Security'},
      {'icon': Icons.wifi, 'name': 'Wi-Fi'},
      {'icon': Icons.ac_unit, 'name': 'Air Conditioning'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            Icon(amenities[index]['icon'] as IconData, color: Colors.grey),
            const SizedBox(width: 8),
            Text(amenities[index]['name'] as String),
          ],
        );
      },
    );
  }
}
