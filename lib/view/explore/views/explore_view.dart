import 'package:flutter/material.dart';

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    'Welcome,', // First part of the greeting
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0C356A),
                    ),
                  ),
                ],
              ),
              const Text(
                'Daniel', // Second part of the greeting
                style: TextStyle(
                  fontFamily: 'League Spartan',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF9A826),
                ),
              ),
              const Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  backgroundImage: AssetImage('lib/assets/profile_picture.png'), // Profile image
                  radius: 20,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Find your perfect place to stay!',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  color: Color(0xFF0C356A),
                ),
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for a place...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
              // Explore List (Example of Properties)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 2, // You can make this dynamic based on property listings
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: PropertyCard(
                      imageUrl: 'lib/assets/apartment_image.jpg', // Replace with actual image URL
                      title: 'Apartment - T2 - 1102',
                      location: 'Ac. 19 #2a - 10, Bogotá',
                      rooms: '4',
                      baths: '1',
                      price: '1.500.000,00',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Navigate to explore more properties
            },
            icon: const Icon(Icons.explore),
            label: const Text('Explore'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              backgroundColor: const Color(0xFF0C356A), // Dark Blue colo
              elevation: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final String rooms;
  final String baths;
  final String price;

  const PropertyCard({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rooms,
    required this.baths,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(imageUrl, fit: BoxFit.cover, height: 200, width: double.infinity),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.black),
                    const SizedBox(width: 5),
                    Text(
                      location,
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bed, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(rooms, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bathtub, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(baths, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0C356A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
