import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:andlet/view/property_details/views/custom_bottom_nav_bar.dart';

final List<String> imageUrls = [
  'lib/assets/apartment_image.jpg',
  // Add more image URLs if needed
];

class PropertyDetailView extends StatefulWidget {
  final String title;
  final String location;
  final String rooms;
  final String bathrooms;
  final String roommates;
  final String description;
  final String agentName;
  final String price;

  const PropertyDetailView({
    super.key,
    required this.title,
    required this.location,
    required this.rooms,
    required this.bathrooms,
    required this.roommates,
    required this.description,
    required this.agentName,
    required this.price,
  });

  @override
  _PropertyDetailViewState createState() => _PropertyDetailViewState();
}

class _PropertyDetailViewState extends State<PropertyDetailView> {
  int _currentPage = 0; // Track current carousel page
  final CarouselController _carouselController = CarouselController();

  // Track whether to show the contact details
  bool showContactDetails = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          // Carousel for images
                          CarouselSlider(
                            items: imageUrls.map((item) {
                              return ClipRRect(
                                child: Image.asset(
                                  item,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height: 400.0,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 5),
                              enlargeCenterPage: true,
                              aspectRatio: 16 / 9,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 15,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: imageUrls.asMap().entries.map((entry) {
                                return GestureDetector(
                                  child: Container(
                                    width: 10.0,
                                    height: 10.0,
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == entry.key
                                          ? Colors.white
                                          : Colors.white54,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 20, color: Colors.black),
                                const SizedBox(width: 5),
                                Text(
                                  widget.location,
                                  style: const TextStyle(
                                    fontFamily: 'League Spartan',
                                    fontWeight: FontWeight.w300,
                                    fontSize: 19,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Facilities',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w600,
                                fontSize: 21,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFacilityWidget(Icons.bed, '${widget.rooms} Bedroom'),
                                _buildFacilityWidget(Icons.bathtub, '${widget.bathrooms} Bathroom'),
                                _buildFacilityWidget(Icons.group, '${widget.roommates} Roommates'),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.description,
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w300,
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Custom Bottom Navbar
              CustomBottomNavbar(
                agentName: widget.agentName,
                price: widget.price,
                onContactPressed: () {
                  setState(() {
                    showContactDetails = !showContactDetails;
                  });
                },
              ),
              if (showContactDetails)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: const Color(0xFFF9EFD7), // Light yellow background
                  width: MediaQuery.of(context).size.width, // Ensures it stretches across the screen width
                  padding: const EdgeInsets.all(10.0),
                  child: const Center( // Centers the text inside the container
                    child: Text(
                      'Email: paula.daza@example.com',
                      textAlign: TextAlign.center, // Centers the text itself
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF0C356A),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Positioned Back Button (Static)
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: const Color(0xFF0C356A),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for building facility widgets
  Widget _buildFacilityWidget(IconData icon, String label) {
    return Container(
      width: 110.0,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
