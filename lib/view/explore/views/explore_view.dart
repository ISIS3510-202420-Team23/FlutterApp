import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/entities/property.dart';
import '../../../view_models/offer_view_model.dart'; // Offers ViewModel
import '../../../view_models/property_view_model.dart'; // Property ViewModel
import 'filter_modal.dart';
import 'property_card.dart';
import 'package:andlet/view/property_details/views/property_detail_view.dart';

class ExploreView extends StatefulWidget {
  final String displayName; // User's Google display name
  final String photoUrl;    // User's Google profile photo URL

  const ExploreView({
    super.key,
    required this.displayName,
    required this.photoUrl,
  });

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch offers once the widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferViewModel>(context, listen: false).fetchOffers();
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties(); // Fetch properties as well
    });
  }

  @override
  Widget build(BuildContext context) {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final propertyViewModel = Provider.of<PropertyViewModel>(context); // Access PropertyViewModel

    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(  // Change here
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome,',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C356A),
                      ),
                    ),
                    Text(
                      widget.displayName,  // Display user's Google name
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF9A826),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundImage: widget.photoUrl.isNotEmpty
                      ? NetworkImage(widget.photoUrl)  // Display user's Google profile picture
                      : const AssetImage('lib/assets/dani.jpg') as ImageProvider, // Fallback image
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                                icon: const Icon(Icons.close, color: Color(0xFF0C356A)), // X button
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Increased padding
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
            const SizedBox(height: 10), // Adjust spacing
            offerViewModel.isLoading || propertyViewModel.isLoading
                ? const Expanded( // Use Expanded to fill available space
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0C356A),
                ),
              ),
            )
                : Expanded(  // Wrap ListView.builder inside Expanded
              child: ListView.builder(
                itemCount: offerViewModel.offers.length,
                itemBuilder: (context, index) {
                  final offer = offerViewModel.offers[index];

                  return FutureBuilder<Property?>(
                    future: propertyViewModel.getPropertyById(offer.property_id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading property'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('Property not found for this offer'));
                      }

                      final property = snapshot.data!;

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
                                  location: property.location, // Show location
                                  rooms: offer.num_rooms.toString(),
                                  bathrooms: offer.num_baths.toString(),
                                  roommates: offer.roommates.toString(),
                                  description: property.description,
                                  agentName: 'Paula Daza',
                                  price: offer.price_per_month.toString(), // Price from offer
                                ),
                              ),
                            );
                          },
                          child: PropertyCard(
                            imageUrl: 'lib/assets/apartment_image.jpg', // Placeholder image
                            title: property.title,
                            location: property.location, // Show location
                            rooms: offer.num_rooms.toString(),
                            baths: offer.num_baths.toString(),
                            price: offer.price_per_month.toString(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
