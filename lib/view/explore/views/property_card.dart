import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';

class PropertyCard extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final GeoPoint location;
  final String rooms;
  final String baths;
  final String price;
  final String roommates; // Add roommates field

  const PropertyCard({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.location,
    required this.rooms,
    required this.baths,
    required this.price,
    required this.roommates, // Pass roommates in constructor
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentSlide = 0; // Track current slide
  bool _isAutoPlaying = true; // Track autoplay status

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25), // Rounded corners for the carousel
          child: SizedBox(
            height: 200, // Height for the image carousel
            width: double.infinity,
            child: CarouselSlider.builder(
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index, realIndex) {
                return Image.network(
                  widget.imageUrls[index], // Use the current image URL
                  fit: BoxFit.cover, // Ensure image covers the container without stretching
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red); // Show error icon if image fails to load
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(), // Show loader while image is loading
                    );
                  },
                );
              },
              options: CarouselOptions(
                height: 200.0,
                viewportFraction: 1.0,
                autoPlay: _isAutoPlaying, // Auto play only while _isAutoPlaying is true
                autoPlayInterval: Duration(seconds: Random().nextInt(3) + 4), // Random interval between 4 and 6 seconds
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;

                    // Stop autoplay when the last image is reached
                    if (_currentSlide == widget.imageUrls.length - 1) {
                      _isAutoPlaying = false;
                    }
                  });
                },
              ),
            ),
          ),
        ),
        Card(
          color: Colors.white, // White card background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(top: 0, bottom: 15), // Small space between image and card
          elevation: 0, // Slight elevation to give the card a background effect
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 0),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.black),
                    const SizedBox(width: 0),
                    Text(
                      '[${widget.location.latitude}, ${widget.location.longitude}]',
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
                        Text(widget.rooms, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bathtub, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(widget.baths, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.group, size: 16, color: Colors.black), // Icon for roommates
                        const SizedBox(width: 5),
                        Text(widget.roommates, style: const TextStyle(color: Colors.black)), // Display roommates
                      ],
                    ),
                    Text(
                      '\$${widget.price}',
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
