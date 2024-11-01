import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

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
  bool showContactDetails = false; // Track whether to show contact details

  String getFirstAndLastName(String fullName) {
    List<String> nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts.first} ${nameParts.last}';
    } else {
      return fullName; // If there's only one name, return it as is
    }
  }

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
                                      child: item.startsWith('http')
                                          ? Image.network(
                                              item,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            )
                                          : Image.file(
                                              File(item),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                    );
                                  }).toList()
                                : [
                                    Center(
                                      child: Text(
                                        'No images available',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )
                                  ],
                            options: CarouselOptions(
                              height: 400.h,
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
                            bottom: 15.h, // Responsive positioning
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  widget.imageUrls.asMap().entries.map((entry) {
                                return GestureDetector(
                                  child: Container(
                                    width: 10.w, // Responsive width
                                    height: 10.h, // Responsive height
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4.w), // Responsive margin
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
                        padding: EdgeInsets.all(20.w), // Responsive padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h), // Responsive spacing
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 26.sp, // Responsive font size
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h), // Responsive spacing
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 20, color: Colors.black),
                                SizedBox(width: 5.w), // Responsive spacing
                                Expanded(
                                  // Use Expanded to allow the text to wrap
                                  child: Text(
                                    widget.address,
                                    style: TextStyle(
                                      fontFamily: 'League Spartan',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 19.sp, // Responsive font size
                                      color: Colors.black,
                                    ),
                                    maxLines:
                                        2, // Allow the text to wrap into 2 lines if needed
                                    overflow: TextOverflow
                                        .ellipsis, // Handle text overflow
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h), // Responsive spacing
                            Text(
                              'Facilities',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w600,
                                fontSize: 21.sp, // Responsive font size
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.h), // Responsive spacing
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
                            SizedBox(height: 20.h), // Responsive spacing
                            Text(
                              'Description',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 21.sp, // Responsive font size
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.h), // Responsive spacing
                            Text(
                              widget.description?.isNotEmpty ?? false
                                  ? widget.description!
                                  : 'No description provided',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w300,
                                fontSize: 15.sp, // Responsive font size
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.h), // Responsive spacing
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Custom Bottom Navbar with improvements to handle long names
              Container(
                padding: EdgeInsets.all(12.w), // Add padding around the row
                color: const Color(0xFFF9EFD7), // Set background to yellow
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.agentPhoto.isNotEmpty
                              ? NetworkImage(widget.agentPhoto)
                              : const AssetImage('lib/assets/personaicono.png')
                                  as ImageProvider,
                          radius: 25.r, // Responsive avatar size
                        ),
                        SizedBox(width: 10.w), // Space between avatar and text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getFirstAndLastName(widget.agentName),
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp, // Responsive font size
                                color: const Color(0xFF0C356A),
                              ),
                              overflow: TextOverflow.ellipsis, // Avoid overflow
                              maxLines: 1, // Limit to one line
                            ),
                            Text(
                              'Property agent',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 15.sp, // Responsive font size
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // The contact button aligned to the right
                    Padding(
                      padding: EdgeInsets.only(right: 15.w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0C356A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            showContactDetails = !showContactDetails;
                          });
                        },
                        child: Text(
                          'Contact',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showContactDetails)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  color: const Color(0xFFF9EFD7), // Light yellow background
                  width: MediaQuery.of(context).size.width, // Ensure full width
                  padding: EdgeInsets.all(10.w), // Responsive padding
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Ensures the column doesn't take infinite height
                    children: [
                      // Displaying only the email, without the extra 'Contact Agent' button
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.9, // Set the width relative to screen
                        child: GestureDetector(
                          onTap: () => _openEmailClient(
                            widget.agentEmail, // Email address of the agent
                            widget.title, // Property title
                            getFirstAndLastName(widget.agentName), // Agent name
                          ),
                          child: Text(
                            'Email: ${widget.agentEmail}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'League Spartan',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp, // Responsive font size
                              color: const Color(0xFF0C356A),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Positioned(
            top: 50.h, // Responsive positioning
            left: 20.w, // Responsive positioning
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
      width: 110.w, // Responsive width
      padding: EdgeInsets.all(10.w), // Responsive padding
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8.r), // Responsive border radius
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24.r, color: Colors.black), // Responsive icon size
          SizedBox(height: 8.h), // Responsive spacing
          Text(
            label,
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 14.sp, // Responsive font size
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to open the email client
  Future<void> _openEmailClient(
      String email, String propertyTitle, String agentName) async {
    final String subject = "Interested in $propertyTitle property";
    final String body =
        "Hello $agentName,\n\nI would like to know more about the availability of the offer $propertyTitle that you published on Andlet.";

    final String encodedSubject = Uri.encodeComponent(subject);
    final String encodedBody = Uri.encodeComponent(body);

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$encodedSubject&body=$encodedBody',
    );

    final BuildContext currentContext =
        context; // Save context before async call

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
