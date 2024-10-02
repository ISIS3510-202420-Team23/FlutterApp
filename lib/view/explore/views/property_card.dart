import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
          borderRadius: BorderRadius.circular(25),
          child: SizedBox(
            height: 200,
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
                height: 200.0,
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
            borderRadius: BorderRadius.circular(15),
          ),
          margin: const EdgeInsets.only(top: 10, bottom: 15),
          elevation: 0,
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
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.black),
                    const SizedBox(width: 5),
                    Text(
                      widget.address,
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
                        const Icon(Icons.group, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(widget.roommates, style: const TextStyle(color: Colors.black)),
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

