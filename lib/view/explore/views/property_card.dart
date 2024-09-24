import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final GeoPoint location;
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
          child: Image.asset(imageUrl, fit: BoxFit.cover, height: 200, width: double.infinity),
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
                    const Icon(Icons.location_on, size: 16, color: Colors.black),
                    const SizedBox(width: 0),
                    Text(
                      '[${location.latitude}, ${location.longitude}]',
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
                        Text(rooms, style: const TextStyle(color: Colors.black)),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.bathtub, size: 16, color: Colors.black),
                        const SizedBox(width: 5),
                        Text(baths, style: const TextStyle(color: Colors.black)),
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
