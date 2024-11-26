import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logging/logging.dart';

import '../../../view_models/offer_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../models/entities/offer_property.dart';
import '../../../models/entities/user.dart';
import '../../profile/views/profile.dart';
import '../../property_details/views/property_detail_view.dart';
import '../../explore/views/property_card.dart';
import '../../explore/views/filter_modal.dart';

class SavedPropertiesView extends StatefulWidget {
  final String userEmail;
  final String displayName;
  final String photoUrl;

  const SavedPropertiesView({
    super.key,
    required this.userEmail,
    required this.displayName,
    required this.photoUrl,
  });

  @override
  State<SavedPropertiesView> createState() => _SavedPropertiesViewState();
}

class _SavedPropertiesViewState extends State<SavedPropertiesView> {
  static final log = Logger('SavedPropertiesView');
  late Future<void> _loadingFuture;

  double? selectedPrice;
  double? selectedMinutes;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _initializeData();
  }

  /// Initialize data by fetching saved properties
  Future<void> _initializeData() async {
    await Provider.of<OfferViewModel>(context, listen: false)
        .fetchSavedPropertiesForUser(widget.userEmail);
  }

  void _navigateToProfileView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileView(
          displayName: widget.displayName,
          userEmail: widget.userEmail,
          photoUrl: widget.photoUrl,
        ),
      ),
    );
  }

  /// Clear applied filters
  void _clearFilters() {
    setState(() {
      selectedPrice = null;
      selectedMinutes = null;
      selectedDateRange = null;
    });
    log.info('Cleared filters');
    _applyFilters(null, null, null);
  }

  /// Open the filter modal
  void _openFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: FilterModal(
          initialPrice: selectedPrice,
          initialMinutes: selectedMinutes,
          initialDateRange: selectedDateRange,
          onApply: _applyFilters,
        ),
      ),
    );
  }

  /// Apply filters to the saved properties
  void _applyFilters(
      double? price, double? minutes, DateTimeRange? dateRange) async {
    setState(() {
      selectedPrice = price;
      selectedMinutes = minutes;
      selectedDateRange = dateRange;
    });

    log.info(
        'Applied filters: price=$price, minutes=$minutes, dateRange=$dateRange');
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);
    offerViewModel.applyFiltersOnCachedData(
      maxPrice: price,
      maxMinutes: minutes,
      dateRange: dateRange,
    );
  }

  /// Navigate to the property detail view and fetch the agent details dynamically
  void _navigateToPropertyDetailView(OfferProperty offerProperty) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final offer = offerProperty.offer;
    final property = offerProperty.property;

    User? agent;
    try {
      agent = await userViewModel.fetchUserById(offer.user_id);
    } catch (e) {
      log.warning('Failed to fetch agent data: $e');
      agent = null;
    }

    final agentName = agent?.name ?? 'Unknown Agent';
    final agentEmail = agent?.email ?? 'Not Available';
    final agentPhoto = agent?.photo ?? '';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailView(
          offerId: offer.offerId,
          title: property.title,
          address: property.address,
          imageUrls: property.photos,
          rooms: offer.num_rooms.toString(),
          bathrooms: offer.num_baths.toString(),
          roommates: offer.roommates.toString(),
          description: property.description,
          agentName: agentName,
          agentEmail: agentEmail,
          agentPhoto: agentPhoto,
          price: offer.price_per_month.toString(),
          userEmail: widget.userEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final String firstName = widget.displayName.split(' ').first;

    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredSavedProperties =
            offerViewModel.getFilteredSavedProperties(
          minPrice: selectedPrice,
          maxPrice: null, // Example, adjust as needed
          maxMinutes: selectedMinutes,
          dateRange: selectedDateRange,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 30.h),
            child: Column(
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome,',
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0C356A),
                          ),
                        ),
                        Text(
                          firstName,
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 35.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFF9A826),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _navigateToProfileView,
                      child: CircleAvatar(
                        backgroundImage: widget.photoUrl.isNotEmpty
                            ? NetworkImage(widget.photoUrl)
                            : const AssetImage('lib/assets/personaicono.png')
                                as ImageProvider,
                        radius: 35.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                // Search/Filter Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 15.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5D5FF),
                          borderRadius: BorderRadius.circular(10.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10.r,
                              spreadRadius: 2.r,
                            ),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (selectedPrice != null ||
                                selectedMinutes != null ||
                                selectedDateRange != null) {
                              _clearFilters();
                            } else {
                              _openFilterModal();
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Color(0xFF0C356A)),
                              SizedBox(width: 10.w),
                              const Expanded(
                                child: Text(
                                  'Search for a place...',
                                  style: TextStyle(color: Color(0xFF0C356A)),
                                ),
                              ),
                              Icon(
                                (selectedPrice != null ||
                                        selectedMinutes != null ||
                                        selectedDateRange != null)
                                    ? Icons.close
                                    : Icons.menu,
                                color: const Color(0xFF0C356A),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                // "Your Saved Places" Label
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your saved places',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0C356A),
                      ),
                    ),
                  ),
                ),
                // No Saved Properties Section
                if (filteredSavedProperties.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'You have no saved properties.',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C356A),
                        ),
                      ),
                    ),
                  ),

                // Saved Properties List Section
                if (filteredSavedProperties.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredSavedProperties.length,
                      itemBuilder: (context, index) {
                        final offerProperty = filteredSavedProperties[index];
                        final property = offerProperty.property;
                        final offer = offerProperty.offer;

                        return GestureDetector(
                          onTap: () =>
                              _navigateToPropertyDetailView(offerProperty),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PropertyCard(
                                imageUrls: property.photos,
                                title: property.title,
                                address: property.address,
                                rooms: offer.num_rooms.toString(),
                                baths: offer.num_baths.toString(),
                                roommates: offer.roommates.toString(),
                                price: offer.price_per_month.toString(),
                              ),
                              SizedBox(height: 10.h),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
