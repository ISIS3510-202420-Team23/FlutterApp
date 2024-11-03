import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'package:logging/logging.dart';

class PropertyCard extends StatefulWidget {
  final List<String> imageUrls; // List of image paths or URLs
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
  static final log = Logger('PropertyCard');

  @override
  Widget build(BuildContext context) {
    log.info('Building PropertyCard for ${widget.title}');
    log.info('Received image URLs in PropertyCard: ${widget.imageUrls}');

    return Column(
      children: [
        // Image Carousel
        ClipRRect(
          borderRadius: BorderRadius.circular(25.r),
          child: SizedBox(
            height: 200.h,
            width: double.infinity,
            child: widget.imageUrls.isNotEmpty
                ? CarouselSlider.builder(
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index, realIndex) {
                      final imageUrl = widget.imageUrls[index];
                      final isNetworkImage = imageUrl.startsWith('http');
                      log.info('Displaying image from URL or path: $imageUrl');

                      return isNetworkImage
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                log.warning(
                                    'Failed to load network image: $imageUrl');
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                            )
                          : Image.file(
                              File(imageUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                log.warning(
                                    'Failed to load local image file: $imageUrl');
                                return const Icon(Icons.error,
                                    color: Colors.red);
                              },
                            );
                    },
                    options: CarouselOptions(
                      height: 200.h,
                      viewportFraction: 1.0,
                      autoPlay: _isAutoPlaying,
                      autoPlayInterval: const Duration(seconds: 4),
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

        // Property Information Card
        Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          margin: EdgeInsets.only(top: 10.h, bottom: 15.h),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'League Spartan',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.h),

                // Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16.r, color: Colors.black),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        widget.address,
                        style: TextStyle(
                          fontFamily: 'League Spartan',
                          fontSize: 14.sp,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Rooms, Baths, Roommates, and Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bed, size: 16.r, color: Colors.black),
                        SizedBox(width: 5.w),
                        Text(
                          widget.rooms,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Icon(Icons.bathtub, size: 16.r, color: Colors.black),
                        SizedBox(width: 5.w),
                        Text(
                          widget.baths,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Icon(Icons.group, size: 16.r, color: Colors.black),
                        SizedBox(width: 5.w),
                        Text(
                          widget.roommates,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '\$${widget.price}',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
