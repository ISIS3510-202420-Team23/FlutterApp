import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:flutter_screenutil/flutter_screenutil.dart'; // For responsive design
import 'package:provider/provider.dart';
import 'filter_modal.dart';
import 'property_card.dart';
import '../../../cas/user_last_contact_landlord.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../view_models/property_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../view/property_details/views/property_detail_view.dart';

class ExploreView extends StatefulWidget {
  final String displayName;
  final String photoUrl;
  final String userEmail;

  const ExploreView({
    super.key,
    required this.displayName,
    required this.photoUrl,
    required this.userEmail,
  });

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  int currentPageIndex = 0;
  bool showShakeAlert = false;
  bool? userRoommatePreference; // Roommate preference

  // State variables to store selected filters
  double? selectedPrice;
  double? selectedMinutes;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();

    // Initial data fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
      fetchUserPreferences(); // Fetch user preferences
      NotificationService notificationService = NotificationService();
      notificationService.checkLastContactAction(widget.userEmail);
    });
  }

  // Fetch initial data
  Future<void> _fetchInitialData() async {
    await Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters();
    await Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
  }

  // Refresh function to be called on pull-to-refresh
  Future<void> _onRefresh() async {
    await _fetchInitialData();
  }

  // Fetch user preferences for roommates from Firestore
  Future<void> fetchUserPreferences() async {
    try {
      var userPreferences =
          await Provider.of<OfferViewModel>(context, listen: false)
              .fetchUserRoommatePreferences(widget.userEmail);
      setState(() {
        userRoommatePreference =
            userPreferences; // true for prefers roommates, false for no roommates
      });
    } catch (e) {
      // ('Error fetching user preferences: $e');
    }
  }

  // Apply filters on offers
  void _applyFilters(double? price, double? minutes, DateTimeRange? dateRange) {
    setState(() {
      selectedPrice = price;
      selectedMinutes = minutes;
      selectedDateRange = dateRange;
    });

    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters(
        maxPrice: price, maxMinutes: minutes, dateRange: dateRange);
  }

  // Clear all filters and refresh offers
  void _clearFilters() {
    setState(() {
      selectedPrice = null;
      selectedMinutes = null;
      selectedDateRange = null;
    });
    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters();
  }

  // Function to open the FilterModal
  void _openFilterModal() {
    AnalyticsEngine.logFilterButtonPressed();
    UserActionsViewModel().addUserAction(widget.userEmail, 'filter');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.r), // Responsive border radius
        ),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: FilterModal(
          initialPrice: selectedPrice,
          initialMinutes: selectedMinutes,
          initialDateRange: selectedDateRange,
          onApply: (price, minutes, dateRange) {
            _applyFilters(price, minutes, dateRange);
          },
        ),
      ),
    );
  }

  // Sort offers based on roommate preference
  List<OfferProperty> _sortOffers(List<OfferProperty> offers) {
    if (userRoommatePreference == null) {
      return offers; // No preference, return as is
    }

    offers.sort((a, b) {
      if (userRoommatePreference == true) {
        return b.offer.roommates.compareTo(a.offer.roommates);
      } else {
        return a.offer.roommates.compareTo(b.offer.roommates);
      }
    });

    return offers;
  }

  @override
  Widget build(BuildContext context) {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final propertyViewModel = Provider.of<PropertyViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    String firstName = widget.displayName.split(' ').first;
    final sortedOffers = _sortOffers(offerViewModel.offersWithProperties);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(25.w), // Responsive padding
        child: Column(
          children: [
            SizedBox(height: 25.h), // Responsive height
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
                        fontSize: 35.sp, // Responsive font size
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C356A),
                      ),
                    ),
                    Text(
                      firstName,
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 35.sp, // Responsive font size
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF9A826),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundImage: widget.photoUrl.isNotEmpty
                      ? NetworkImage(widget.photoUrl)
                      : const AssetImage('lib/assets/personaicono.png')
                          as ImageProvider,
                  radius: 35.r, // Responsive radius
                ),
              ],
            ),
            SizedBox(height: 20.h), // Responsive height
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.w, vertical: 10.h), // Responsive padding
                    decoration: BoxDecoration(
                      color: const Color(0xFFB5D5FF),
                      borderRadius: BorderRadius.circular(10.r), // Responsive border radius
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
                        if (selectedPrice != null || selectedMinutes != null || selectedDateRange != null) {
                          _clearFilters();
                        } else {
                          _openFilterModal();
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF0C356A)),
                          SizedBox(width: 10.w), // Responsive spacing
                          const Expanded(
                            child: Text(
                              'Search for a place...',
                              style: TextStyle(color: Color(0xFF0C356A)),
                            ),
                          ),
                          Icon(
                            (selectedPrice != null || selectedMinutes != null || selectedDateRange != null)
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

            // Display active filters without option to delete
            if (selectedPrice != null || selectedMinutes != null || selectedDateRange != null)
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 5.h), // Minimized vertical padding
                child: SingleChildScrollView(
                  scrollDirection:
                      Axis.horizontal, // Enable horizontal scrolling
                  child: Row(
                    children: [
                      if (selectedPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0), // Add some spacing between chips
                          child: Chip(
                            label: Text(
                              'Price: \$${selectedPrice!.toInt()}',
                              style: const TextStyle(
                                  color:
                                      Color(0xFF0C356A)), // Custom font color
                            ),
                            backgroundColor: const Color(0xFFB5D5FF), // Light blue color
                          ),
                        ),
                      if (selectedMinutes != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0), // Add some spacing between chips
                          child: Chip(
                            label: Text(
                              'Minutes: ${selectedMinutes!.toInt()}',
                              style: const TextStyle(
                                  color:
                                      Color(0xFF0C356A)), // Custom font color
                            ),
                            backgroundColor: const Color(0xFFB5D5FF), // Light blue color
                          ),
                        ),
                      if (selectedDateRange != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 8.0), // Add some spacing between chips
                          child: Chip(
                            label: Text(
                              'Dates: ${DateFormat('MM/dd').format(selectedDateRange!.start)} - ${DateFormat('MM/dd').format(selectedDateRange!.end)}',
                              style: const TextStyle(
                                  color:
                                      Color(0xFF0C356A)), // Custom font color
                            ),
                            backgroundColor: const Color(0xFFB5D5FF), // Light blue color
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            SizedBox(height: 10.h), // Responsive spacing
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: offerViewModel.isLoading || propertyViewModel.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF0C356A),
                  ),
                )
                    : sortedOffers.isEmpty
                    ? const Center(
                  child: Text(
                    'No properties match your filters.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0C356A),
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: sortedOffers.length,
                  itemBuilder: (context, index) {
                    final offerWithProperty = sortedOffers[index];
                    final offer = offerWithProperty.offer;
                    final property = offerWithProperty.property;

                    return FutureBuilder<List<String>>(
                      future: propertyViewModel.getImageUrls(property.photos),
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (imageSnapshot.hasError) {
                          return const Center(child: Text('Error loading images'));
                        }

                        final imageUrls = imageSnapshot.data ?? [];

                        return FutureBuilder<Map<String, dynamic>>(
                          future: userViewModel.fetchUserById(offer.user_id),
                          builder: (context, agentSnapshot) {
                            if (agentSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (agentSnapshot.hasError || !agentSnapshot.hasData) {
                              return const Center(child: Text('Error loading agent data'));
                            }

                            final agentData = agentSnapshot.data!;
                            final agentName = agentData['name'];
                            final agentPhoto = agentData['photo'];
                            final agentEmail = agentData['email'];

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: GestureDetector(
                                onTap: () async {
                                  // Increment the view counter
                                  bool hasRoommates = offer.roommates > 0;
                                  await Provider.of<OfferViewModel>(context, listen: false)
                                      .incrementUserViewCounter(widget.userEmail, hasRoommates);

                                  AnalyticsEngine.logViewPropertyDetails(property.id);
                                  OfferViewModel().incrementOfferViewCounter(offer.offerId);

                                  // Navigate to property details with agent info
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PropertyDetailView(
                                        title: property.title,
                                        address: property.address,
                                        imageUrls: imageUrls,
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
                                },
                                child: PropertyCard(
                                  imageUrls: imageUrls,
                                  title: property.title,
                                  address: property.address,
                                  rooms: offer.num_rooms.toString(),
                                  baths: offer.num_baths.toString(),
                                  roommates: offer.roommates.toString(),
                                  price: offer.price_per_month.toString(),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: const Color(0xFFB5D5FF),
        backgroundColor: Colors.white,
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore, color: Color(0xFF0C356A)),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.home, color: Color(0xFF0C356A)),
            label: 'Home',
          ),
        ],
      ),
    );
  }
}
