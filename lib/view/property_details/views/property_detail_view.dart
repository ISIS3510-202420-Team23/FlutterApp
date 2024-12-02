import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../../analytics/analytics_engine.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../connectivity/connectivity_service.dart';

class PropertyDetailView extends StatefulWidget {
  final String title;
  final String address;
  final int offerId;
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
    required this.offerId,
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
  bool isSaved = false; // Track if the property is saved
  bool _isConnected = true; // Track connectivity status
  final ConnectivityService _connectivityService = ConnectivityService();
  final Connectivity _connectivity = Connectivity();
  static final log = Logger('PropertyDetailView');

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _checkIfSaved(widget.userEmail, widget.offerId); // Check saved state
  }

  /// Initialize connectivity monitoring
  void _initializeConnectivity() async {
    final initialStatus = await _connectivity.checkConnectivity();
    _updateConnectionStatus(initialStatus);

    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectivityResult result) async {
    bool isConnected = result != ConnectivityResult.none &&
        await _connectivityService.isConnected();

    setState(() {
      _isConnected = isConnected;
    });

    log.info('Connectivity status updated: $_isConnected');
  }

  /// Check if the property is saved
  Future<void> _checkIfSaved(String userEmail, int offerId) async {
    final savedOffers = Provider.of<OfferViewModel>(context, listen: false)
        .savedOfferProperties;
    setState(() {
      isSaved = savedOffers.any((offer) => offer.offer.offerId == offerId);
    });
  }

  /// Save or unsave the property
  Future<void> _toggleSaveOffer(String userEmail, int offerId) async {
    if (!_isConnected) {
      _showOfflineSnackbar();
      return;
    }

    try {
      final offerViewModel =
      Provider.of<OfferViewModel>(context, listen: false);

      if (isSaved) {
        // Unsave logic
        await offerViewModel.unsaveOffer(userEmail, offerId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer unsaved successfully!')),
        );
      } else {
        // Save logic
        await offerViewModel.saveOffer(userEmail, offerId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer saved successfully!')),
        );
      }

      // Toggle the isSaved state
      setState(() {
        isSaved = !isSaved;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle save state: $e')),
      );
    }
  }

  /// Show a snackbar when attempting to save while offline
  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Save property is not available while offline.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

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
                          // Carousel for images
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
                            bottom: 15.h,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  widget.imageUrls.asMap().entries.map((entry) {
                                return GestureDetector(
                                  child: Container(
                                    width: 10.w,
                                    height: 10.h,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
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
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 20, color: Colors.black),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                    widget.address,
                                    style: TextStyle(
                                      fontFamily: 'League Spartan',
                                      fontWeight: FontWeight.w300,
                                      fontSize: 19.sp,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Facilities',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w600,
                                fontSize: 21.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.h),
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
                            SizedBox(height: 20.h),
                            Text(
                              'Description',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 21.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Text(
                              widget.description?.isNotEmpty ?? false
                                  ? widget.description!
                                  : 'No description provided',
                              style: TextStyle(
                                fontFamily: 'League Spartan',
                                fontWeight: FontWeight.w300,
                                fontSize: 15.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom agent info and contact button
              _buildBottomAgentSection(),
              if (showContactDetails) _buildContactDetails(),
            ],
          ),
          // Back and Save Buttons
          Positioned(
            top: 50.h,
            left: 20.w,
            child: _buildBackButton(),
          ),
          Positioned(
            top: 50.h,
            right: 20.w,
            child: _buildSaveButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return CircleAvatar(
      backgroundColor: const Color(0xFF0C356A),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return CircleAvatar(
      backgroundColor: _isConnected ? const Color(0xFF0C356A) : Colors.grey,
      child: IconButton(
        icon: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.white,
        ),
        onPressed: _isConnected
            ? () => _toggleSaveOffer(widget.userEmail, widget.offerId)
            : _showOfflineSnackbar,
      ),
    );
  }

  Widget _buildFacilityWidget(IconData icon, String label) {
    return Container(
      width: 110.w,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24.r, color: Colors.black),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'League Spartan',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAgentSection() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: const Color(0xFFF9EFD7),
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
                radius: 25.r,
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFirstAndLastName(widget.agentName),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                      color: const Color(0xFF0C356A),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Property agent',
                    style: TextStyle(
                      fontFamily: 'League Spartan',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                AnalyticsEngine.logContactButtonPressed();
              },
              child: Text(
                'Contact',
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetails() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: const Color(0xFFF9EFD7),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _openEmailClient(
              widget.agentEmail,
              widget.title,
              getFirstAndLastName(widget.agentName),
            ),
            child: Text(
              'Email: ${widget.agentEmail}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                color: const Color(0xFF0C356A),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEmailClient(
      String email, String propertyTitle, String agentName) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=${Uri.encodeComponent("Interested in $propertyTitle property")}&body=${Uri.encodeComponent("Hello $agentName,\n\nI would like to know more about the availability of the offer $propertyTitle that you published on Andlet.")}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
