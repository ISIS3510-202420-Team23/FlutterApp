import 'package:flutter/material.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome,',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0C356A),
                        ),
                      ),
                      Text(
                        'Daniel',
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF9A826),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundImage:
                        AssetImage('lib/assets/dani.jpg'), // Profile image
                    radius: 30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5D5FF),
                  borderRadius: BorderRadius.circular(10),
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
                    hintStyle: TextStyle(color: Color(0xFF0C356A)),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Color(0xFF0C356A)),
                  ),
                ),
              ),

              // Explore List (Example of Properties)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    4, // You can make this dynamic based on property listings
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    child: PropertyCard(
                      imageUrl:
                          'lib/assets/apartment_image.jpg', // Replace with actual image URL
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
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color(0xFFB5D5FF),
        backgroundColor: Colors.white,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore, color: Color(0xFF0C356A)),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.home, color: Color(0xFF0C356A)),
            label: 'Home',
          ),
        ],
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
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rooms,
    required this.baths,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25), // Rounded image
          child: Image.asset(imageUrl,
              fit: BoxFit.cover, height: 200, width: double.infinity),
        ),
        Card(
          color: Colors.white, // White card background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(
              top: 0, bottom: 15), // Small space between image and card
          elevation: 0, // Slight elevation to give the card a background effect
          child: Padding(
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
                const SizedBox(height: 0),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 0),
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
                const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bed, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(rooms,
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bathtub,
                            size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(baths,
                            style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Text(
                      '\$$price',
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
