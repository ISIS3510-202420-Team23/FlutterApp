import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import for responsiveness
import 'dart:math';

class PropertyCard extends StatefulWidget {
  final List<String> imageUrls;
  final String title;
  final String address;
  final String rooms;
  final String baths;
  final String price;
  final String roommates;

  const PropertyCard({
    super.key,
    required this.imageUrls,
    required this.title,
    required this.address,
    required this.rooms,
    required this.baths,
    required this.price,
    required this.roommates,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentSlide = 0;
  bool _isAutoPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(25.r), // Responsive corner radius
          child: SizedBox(
            height: 200.h, // Responsive height
            width: double.infinity,
            child: widget.imageUrls.isNotEmpty
                ? CarouselSlider.builder(
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index, realIndex) {
                return Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, color: Colors.red);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
              options: CarouselOptions(
                height: 200.h, // Responsive height for carousel
                viewportFraction: 1.0,
                autoPlay: _isAutoPlaying,
                autoPlayInterval: Duration(seconds: Random().nextInt(3) + 4),
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentSlide = index;
                    if (_currentSlide == widget.imageUrls.length - 1) {
                      _isAutoPlaying = false;
                    }
                  });
                },
              ),
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  'No images available',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r), // Responsive border radius
          ),
          margin: EdgeInsets.only(top: 10.h, bottom: 15.h), // Responsive margins
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(15.w), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with wrapping and responsiveness
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 18.sp, // Responsive font size
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2, // Allowing max 2 lines
                  overflow: TextOverflow.ellipsis, // Ellipsis for overflow text
                ),
                SizedBox(height: 5.h), // Responsive spacing
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16.r, color: Colors.black),
                    SizedBox(width: 5.w), // Responsive spacing
                    Expanded(
                      child: Text(
                        widget.address,
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 14.sp, // Responsive font size
                          color: Colors.black,
                        ),
                        maxLines: 2, // Allowing max 2 lines for address
                        overflow: TextOverflow.ellipsis, // Ellipsis for overflow text
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h), // Responsive spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align elements between left and right
                  children: [
                    Row(
                      children: [
                        // Room Icon + Text
                        Icon(Icons.bed, size: 16.r, color: Colors.black), // Responsive icon size
                        SizedBox(width: 5.w), // Responsive spacing
                        Text(
                          widget.rooms,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp, // Responsive font size
                          ),
                        ),
                        SizedBox(width: 15.w), // Adjusted spacing between icons
                        // Bath Icon + Text
                        Icon(Icons.bathtub, size: 16.r, color: Colors.black),
                        SizedBox(width: 5.w),
                        Text(
                          widget.baths,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp, // Responsive font size
                          ),
                        ),
                        SizedBox(width: 15.w), // Adjusted spacing between icons
                        // Roommate Icon + Text
                        Icon(Icons.group, size: 16.r, color: Colors.black),
                        SizedBox(width: 5.w),
                        Text(
                          widget.roommates,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp, // Responsive font size
                          ),
                        ),
                      ],
                    ),
                    // Price Text aligned to the right
                    Text(
                      '\$${widget.price}',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 16.sp, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // Handle long numbers
                      textAlign: TextAlign.right,
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
