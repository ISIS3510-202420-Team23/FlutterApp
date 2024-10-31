import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../connectivity/connectivity_service.dart';
import 'filter_modal.dart';
import 'property_card.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../view_models/property_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../view/property_details/views/property_detail_view.dart';
import 'package:andlet/models/entities/offer_property.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:andlet/models/entities/user.dart';
import 'package:logging/logging.dart';

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
  bool? userRoommatePreference;
  bool _isConnected = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  final Connectivity _connectivity = Connectivity();
  static final log = Logger('ExploreView');

  // State variables to store selected filters
  double? selectedPrice;
  double? selectedMinutes;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _fetchUserPreferences();
  }

  void _initializeConnectivity() {
    log.info('Initializing connectivity check...');
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      log.info('Connectivity changed: $result');
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) async {
    bool isConnected = result != ConnectivityResult.none && await _connectivityService.isConnected();
    log.info('Updated connectivity status: $isConnected');
    setState(() {
      _isConnected = isConnected;
    });

    if (_isConnected) {
      log.info('Online - Fetching initial data from Firestore');
      await _fetchInitialData();
    } else {
      log.warning('Offline - Loading cached data');
      Provider.of<OfferViewModel>(context, listen: false).loadFromCache();
      Provider.of<PropertyViewModel>(context, listen: false).loadFromCache();
    }
  }

  // Fetch initial data from Firestore
  Future<void> _fetchInitialData() async {
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);

    log.info('Fetching offers and properties from Firestore');
    await offerViewModel.fetchOffersWithFilters();
    await propertyViewModel.fetchProperties();
  }

  // Fetch user preferences for roommates from Firestore
  Future<void> _fetchUserPreferences() async {
    try {
      log.info('Fetching user roommate preferences for ${widget.userEmail}');
      var userPreferences = await Provider.of<OfferViewModel>(context, listen: false)
          .fetchUserRoommatePreferences(widget.userEmail);
      setState(() {
        userRoommatePreference = userPreferences;
      });
      log.info('User roommate preference: $userRoommatePreference');
    } catch (e) {
      log.severe('Error fetching user preferences: $e');
    }
  }

  // Apply filters on offers
  void _applyFilters(double? price, double? minutes, DateTimeRange? dateRange) {
    setState(() {
      selectedPrice = price;
      selectedMinutes = minutes;
      selectedDateRange = dateRange;
    });

    log.info('Applying filters: price=$price, minutes=$minutes, dateRange=$dateRange');
    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters(
      maxPrice: price,
      maxMinutes: minutes,
      dateRange: dateRange,
    );
  }

  // Clear all filters and refresh offers
  void _clearFilters() {
    setState(() {
      selectedPrice = null;
      selectedMinutes = null;
      selectedDateRange = null;
    });
    log.info('Clearing filters');
    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters();
  }

  // Open the FilterModal
  void _openFilterModal() {
    AnalyticsEngine.logFilterButtonPressed();
    UserActionsViewModel().addUserAction(widget.userEmail, 'filter');
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

  // Sort offers based on roommate preference
  List<OfferProperty> _sortOffers(List<OfferProperty> offers) {
    if (userRoommatePreference == null) return offers;

    offers.sort((a, b) {
      if (userRoommatePreference == true) {
        return b.offer.roommates.compareTo(a.offer.roommates);
      } else {
        return a.offer.roommates.compareTo(b.offer.roommates);
      }
    });

    log.info('Offers sorted based on roommate preference: $userRoommatePreference');
    return offers;
  }

  @override
  Widget build(BuildContext context) {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final propertyViewModel = Provider.of<PropertyViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    String firstName = widget.displayName.split(' ').first;
    final sortedOffers = _sortOffers(offerViewModel.offersWithProperties);

    log.info('Building ExploreView - Connected: $_isConnected');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            SizedBox(height: 2.h),
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
                CircleAvatar(
                  backgroundImage: widget.photoUrl.isNotEmpty
                      ? NetworkImage(widget.photoUrl)
                      : const AssetImage('lib/assets/personaicono.png') as ImageProvider,
                  radius: 35.r,
                ),
              ],
            ),
            SizedBox(height: 20.h),
            if (!_isConnected)
              Container(
                color: Colors.redAccent,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8.0),
                    Expanded(child: Text('No Internet Connection, offers will not be updated', style: TextStyle(color: Colors.white, fontSize: 14.sp))),
                  ],
                ),
              ),
            if (!_isConnected)
              SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
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
                        if (selectedPrice != null || selectedMinutes != null || selectedDateRange != null) {
                          _clearFilters();
                        } else {
                          _openFilterModal();
                        }
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF0C356A)),
                          SizedBox(width: 10.w),
                          const Expanded(child: Text('Search for a place...', style: TextStyle(color: Color(0xFF0C356A)))),
                          Icon(
                            (selectedPrice != null || selectedMinutes != null || selectedDateRange != null) ? Icons.close : Icons.menu,
                            color: const Color(0xFF0C356A),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (selectedPrice != null || selectedMinutes != null || selectedDateRange != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (selectedPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(label: Text('Price: \$${selectedPrice!.toInt()}', style: const TextStyle(color: Color(0xFF0C356A))), backgroundColor: const Color(0xFFB5D5FF)),
                        ),
                      if (selectedMinutes != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(label: Text('Minutes: ${selectedMinutes!.toInt()}', style: const TextStyle(color: Color(0xFF0C356A))), backgroundColor: const Color(0xFFB5D5FF)),
                        ),
                      if (selectedDateRange != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text('Dates: ${DateFormat('MM/dd').format(selectedDateRange!.start)} - ${DateFormat('MM/dd').format(selectedDateRange!.end)}',
                                style: const TextStyle(color: Color(0xFF0C356A))),
                            backgroundColor: const Color(0xFFB5D5FF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 10.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _isConnected ? _fetchInitialData : () async => _showOfflineSnackbar(),
                child: sortedOffers.isEmpty
                    ? const Center(child: Text('No properties match your filters.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0C356A))))
                    : ListView(
                  children: sortedOffers.map((offerWithProperty) {
                    final offer = offerWithProperty.offer;
                    final property = offerWithProperty.property;

                    return FutureBuilder<List<String>>(
                      future: propertyViewModel.getImageUrls(property.photos), // get image URLs asynchronously
                      builder: (context, imageSnapshot) {
                        if (imageSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (imageSnapshot.hasError || imageSnapshot.data == null) {
                          return const Center(child: Text('Error loading images'));
                        }

                        final imageUrls = imageSnapshot.data ?? [];

                        // If offline, skip fetching agent data and use only cached info
                        if (!_isConnected) {
                          return PropertyCard(
                            imageUrls: imageUrls,
                            title: property.title,
                            address: property.address,
                            rooms: offer.num_rooms.toString(),
                            baths: offer.num_baths.toString(),
                            roommates: offer.roommates.toString(),
                            price: offer.price_per_month.toString(),
                          );
                        }

                        // If online, fetch agent data as well
                        return FutureBuilder<User?>(
                          future: userViewModel.fetchUserById(offer.user_id),
                          builder: (context, agentSnapshot) {
                            if (agentSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (agentSnapshot.hasError || agentSnapshot.data == null) {
                              return const Center(child: Text('Error loading agent data'));
                            }

                            final agent = agentSnapshot.data!;
                            final agentName = agent.name.isNotEmpty ? agent.name : 'Unknown Agent';
                            final agentPhoto = agent.photo.isNotEmpty ? agent.photo : '';
                            final agentEmail = agent.email.isNotEmpty ? agent.email : 'Not Available';

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h),
                              child: GestureDetector(
                                onTap: () async {
                                  bool hasRoommates = offer.roommates > 0;
                                  await Provider.of<OfferViewModel>(context, listen: false)
                                      .incrementUserViewCounter(widget.userEmail, hasRoommates);

                                  AnalyticsEngine.logViewPropertyDetails(property.id);
                                  OfferViewModel().incrementOfferViewCounter(offer.offerId);

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
                  }).toList(),
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

  // Show snackbar for offline refresh restriction
  void _showOfflineSnackbar() {
    log.warning('User attempted to refresh while offline');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are offline. Refresh is disabled.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.redAccent),
    );
  }
}
