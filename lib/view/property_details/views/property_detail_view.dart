import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:andlet/view/property_details/views/custom_bottom_nav_bar.dart';

import '../../../analytics/analytics_engine.dart';

class PropertyDetailView extends StatefulWidget {
  final String title;
  final String address;
  final List<String> imageUrls;
  final String rooms;
  final String bathrooms;
  final String roommates;
  final String? description;
  final String agentName;
  final String agentEmail;
  final String agentPhoto;
  final String price;
  final String userEmail;

  const PropertyDetailView({
    super.key,
    required this.title,
    required this.address,
    required this.imageUrls,
    required this.rooms,
    required this.bathrooms,
    required this.roommates,
    required this.description,
    required this.agentName,
    required this.agentEmail,
    required this.agentPhoto,
    required this.price,
    required this.userEmail,
  });

  @override
  PropertyDetailViewState createState() => PropertyDetailViewState();
}

class PropertyDetailViewState extends State<PropertyDetailView> {
  int _currentPage = 0; // Track current carousel page

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
                          // Carousel for images, with check for empty list
                          CarouselSlider(
                            items: widget.imageUrls.isNotEmpty
                                ? widget.imageUrls.map((item) {
                                    return ClipRRect(
                                      child: Image.network(
                                        item,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const Center(
                                      child: Text(
                                        'No images available',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ], // Fallback when the image list is empty
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
                              children:
                                  widget.imageUrls.asMap().entries.map((entry) {
                                return GestureDetector(
                                  child: Container(
                                    width: 10.0,
                                    height: 10.0,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
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
                                const Icon(Icons.location_on_outlined,
                                    size: 20, color: Colors.black),
                                const SizedBox(width: 5),
                                Text(
                                  widget.address,
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
                                _buildFacilityWidget(
                                    Icons.bed, '${widget.rooms} Bedroom'),
                                _buildFacilityWidget(Icons.bathtub,
                                    '${widget.bathrooms} Bathroom'),
                                _buildFacilityWidget(Icons.group,
                                    '${widget.roommates} Roommates'),
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
                              widget.description?.isNotEmpty ?? false
                                  ? widget.description!
                                  : 'No description provided',
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
                agentPhoto: widget.agentPhoto,
                agentEmail: widget.agentEmail,
                price: widget.price,
                onContactPressed: () {
                  AnalyticsEngine.logContactButtonPressed();
                  UserActionsViewModel()
                      .addUserAction(widget.userEmail, 'contact');
                  setState(() {
                    showContactDetails = !showContactDetails;
                  });
                },
              ),
              if (showContactDetails)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: const Color(0xFFF9EFD7), // Light yellow background
                  width: MediaQuery.of(context)
                      .size
                      .width, // Ensures it stretches across the screen width
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    // Centers the text inside the container
                    child: Text(
                      'Email: ${widget.agentEmail}', // Correctly referencing agentEmail
                      textAlign: TextAlign.center, // Centers the text itself
                      style: const TextStyle(
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
