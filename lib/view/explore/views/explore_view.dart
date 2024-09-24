import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import '../../../view_models/property_view_model.dart';
import 'filter_modal.dart';
import 'property_card.dart';
import 'package:andlet/view/property_details/views/property_detail_view.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch properties once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
    });
  }


  @override
  Widget build(BuildContext context) {
    final propertyViewModel =
        Provider.of<PropertyViewModel>(context); // Access the PropertyViewModel

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
              // Search Bar with OnTap to show modal
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Ensure full screen
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => SizedBox(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, left: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Color(0xFF0C356A)), // X button
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close modal
                                  },
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                          const FilterModal(),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10), // Increased padding
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
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF0C356A)),
                      SizedBox(width: 10),
                      Text(
                        'Search for a place...',
                        style: TextStyle(color: Color(0xFF0C356A)),
                      ),
                    ],
                  ),
                ),
              ),
              // Check if data is still loading
              propertyViewModel.isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Show loader
                  : propertyViewModel.properties.isEmpty
                      ? const Center(child: Text('No properties available'))
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: propertyViewModel.properties.length,
                          itemBuilder: (context, index) {
                            final property =
                                propertyViewModel.properties[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to PropertyDetailView on tap
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailView(
                                        title: property.title,
                                        location: property.location,
                                        rooms: '4', // Set dynamically
                                        bathrooms: '1', // Set dynamically
                                        roommates: '3', // Set dynamically
                                        description: property.description,
                                        agentName: 'Paula Daza',
                                        price:
                                            '1.500.000,00', // Set dynamically
                                      ),
                                    ),
                                  );
                                },
                                child: PropertyCard(
                                  imageUrl:
                                      'lib/assets/apartment_image.jpg', // Placeholder image
                                  title: property.title,
                                  location: property.location,
                                  rooms: '4', // Placeholder value
                                  baths: '1', // Placeholder value
                                  price: '1.500.000,00', // Placeholder value
                                ),
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
