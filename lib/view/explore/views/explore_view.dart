import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../../connectivity/connectivity_service.dart';
import '../../profile/views/profile.dart';
import '../../saved_properties/views/saved_properties.dart';
import 'filter_modal.dart';
import 'property_card.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../view_models/property_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../view/property_details/views/property_detail_view.dart';
import 'package:andlet/models/entities/offer_property.dart';
import 'package:andlet/models/entities/user.dart';

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
  int currentPageIndex = 0; // Track selected page index
  bool? userRoommatePreference;
  bool _isConnected = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  final Connectivity _connectivity = Connectivity();
  static final log = Logger('ExploreView');

  double? selectedPrice;
  double? selectedMinutes;
  DateTimeRange? selectedDateRange;
  late Future<void> _loadingFuture;

  @override
  void initState() {
    super.initState();

    // Analytics
    UserActionsViewModel().addUserAction(widget.userEmail, 'peak');

    // Initialize data loading
    _loadingFuture = _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _initializeConnectivity(),
      _fetchUserPreferences(),
      _loadFromCache(),
    ]);
    if (_isConnected) {
      _loadingFuture = _fetchFreshData(); // Fetch fresh data in background
    }
  }

  Future<void> _initializeConnectivity() async {
    log.info('Initializing connectivity check...');
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      log.info('Connectivity changed: $result');
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(ConnectivityResult result) async {
    bool isConnected = result != ConnectivityResult.none &&
        await _connectivityService.isConnected();
    log.info('Updated connectivity status: $isConnected');
    setState(() {
      _isConnected = isConnected;
    });

    if (isConnected) {
      log.info('Online - Refreshing data from Firestore in background');
      _fetchFreshData();
    }
  }

  Future<void> _fetchFreshData() async {
    final propertyViewModel =
        Provider.of<PropertyViewModel>(context, listen: false);
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);

    // Fetch in the background and update UI once complete
    await Future.wait([
      propertyViewModel
          .fetchPropertiesInBatches(), // Fetch properties in batches
      offerViewModel.fetchOffersWithFilters() // Fetch offers with filters
    ]);

    // Clear and refresh cached data
    await propertyViewModel.cacheProperties();
    await offerViewModel.cacheOffers();

    setState(() {}); // Trigger rebuild to reflect fresh data
  }

  Future<void> _loadFromCache() async {
    final propertyViewModel =
        Provider.of<PropertyViewModel>(context, listen: false);
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);

    await Future.wait(
        [propertyViewModel.loadFromCache(), offerViewModel.loadFromCache()]);
    setState(() {}); // Update the UI to reflect cached data
  }

  Future<void> _fetchUserPreferences() async {
    try {
      log.info('Fetching user roommate preferences for ${widget.userEmail}');
      var userPreferences =
          await Provider.of<OfferViewModel>(context, listen: false)
              .fetchUserRoommatePreferences(widget.userEmail);
      setState(() {
        userRoommatePreference = userPreferences;
      });
      log.info('User roommate preference: $userRoommatePreference');
    } catch (e) {
      log.severe('Error fetching user preferences: $e');
    }
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

  void _showOfflineSnackbar() {
    log.warning('User attempted to refresh while offline');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('You are offline. Refresh is disabled.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent),
    );
  }

  void _clearFilters() {
    setState(() {
      selectedPrice = null;
      selectedMinutes = null;
      selectedDateRange = null;
    });
    log.info('Clearing filters');
    _applyFilters(null, null, null);
  }

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

  void _navigateToPropertyDetailView(OfferProperty offerProperty) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final offer = offerProperty.offer;
    final property = offerProperty.property;

    User? agent;
    if (_isConnected) {
      try {
        agent = await userViewModel.fetchUserById(offer.user_id);
      } catch (e) {
        log.warning('Failed to fetch agent data online: $e');
      }
    } else {
      // If offline, retrieve directly from cache
      agent = await userViewModel.fetchUserById(offer.user_id);
    }

    final agentName = agent?.name ?? 'Unknown Agent';
    final agentEmail = agent?.email ?? 'Not Available';
    final agentPhoto = agent?.photo ?? '';

    List<String> localImagePaths =
        property.photos.where((path) => File(path).existsSync()).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailView(
          offerId: offer.offerId,
          title: property.title,
          address: property.address,
          imageUrls: localImagePaths,
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

  void _applyFilters(
      double? price, double? minutes, DateTimeRange? dateRange) async {
    setState(() {
      selectedPrice = price;
      selectedMinutes = minutes;
      selectedDateRange = dateRange;
    });

    log.info(
        'Applying filters: price=$price, minutes=$minutes, dateRange=$dateRange');
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);
    if (_isConnected) {
      await offerViewModel.fetchOffersWithFilters(
        maxPrice: price,
        maxMinutes: minutes,
        dateRange: dateRange,
      );
    } else {
      offerViewModel.applyFiltersOnCachedData(
        maxPrice: price,
        maxMinutes: minutes,
        dateRange: dateRange,
      );
    }
  }

  List<Widget> _pages() => [
        _buildExplorePage(),
        SavedPropertiesView(
          userEmail: widget.userEmail,
          displayName: widget.displayName,
          photoUrl: widget.photoUrl,
        ),
      ];

  Widget _buildExplorePage() {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final propertyViewModel = Provider.of<PropertyViewModel>(context);
    String firstName = widget.displayName.split(' ').first;

    final sortedOffers = _sortOffers(offerViewModel.offersWithProperties);

    return Padding(
      padding: EdgeInsets.all(25.w),
      child: Column(
        children: [
          SizedBox(height: 5.h),
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
          if (!_isConnected)
            Container(
              color: Colors.redAccent,
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8.0),
                  Expanded(
                      child: Text(
                          'No Internet Connection, offers will not be updated',
                          style:
                              TextStyle(color: Colors.white, fontSize: 14.sp))),
                ],
              ),
            ),
          if (!_isConnected) SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
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
                        const Icon(Icons.search, color: Color(0xFF0C356A)),
                        SizedBox(width: 10.w),
                        const Expanded(
                            child: Text('Search for a place...',
                                style: TextStyle(color: Color(0xFF0C356A)))),
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
          if (selectedPrice != null ||
              selectedMinutes != null ||
              selectedDateRange != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (selectedPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                            label: Text('Price: \$${selectedPrice!.toInt()}',
                                style:
                                    const TextStyle(color: Color(0xFF0C356A))),
                            backgroundColor: const Color(0xFFB5D5FF)),
                      ),
                    if (selectedMinutes != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                            label: Text('Minutes: ${selectedMinutes!.toInt()}',
                                style:
                                    const TextStyle(color: Color(0xFF0C356A))),
                            backgroundColor: const Color(0xFFB5D5FF)),
                      ),
                    if (selectedDateRange != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(
                              'Dates: ${DateFormat('MM/dd').format(selectedDateRange!.start)} - ${DateFormat('MM/dd').format(selectedDateRange!.end)}',
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
              onRefresh: _isConnected
                  ? _fetchFreshData
                  : () async => _showOfflineSnackbar(),
              child: (propertyViewModel.isLoading ||
                          offerViewModel.isLoading) &&
                      sortedOffers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : sortedOffers.isEmpty
                      ? const Center(
                          child: Text('No properties match your filters.',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0C356A))))
                      : ListView.builder(
                          itemCount: sortedOffers.length,
                          itemBuilder: (context, index) {
                            final offerWithProperty = sortedOffers[index];
                            final offer = offerWithProperty.offer;
                            final property = offerWithProperty.property;

                            return GestureDetector(
                              onTap: () => _navigateToPropertyDetailView(
                                  offerWithProperty),
                              child: PropertyCard(
                                imageUrls: property.photos, // Local image paths
                                title: property.title,
                                address: property.address,
                                rooms: offer.num_rooms.toString(),
                                baths: offer.num_baths.toString(),
                                roommates: offer.roommates.toString(),
                                price: offer.price_per_month.toString(),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: _pages()[currentPageIndex], // Display selected page
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index; // Update selected index
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
                icon: Icon(Icons.bookmark, color: Color(0xFF0C356A)),
                label: 'Saved',
              ),
            ],
          ),
        );
      },
    );
  }

  List<OfferProperty> _sortOffers(List<OfferProperty> offers) {
    if (userRoommatePreference == null) return offers;

    offers.sort((a, b) {
      if (userRoommatePreference == true) {
        return b.offer.roommates.compareTo(a.offer.roommates);
      } else {
        return a.offer.roommates.compareTo(b.offer.roommates);
      }
    });

    log.info(
        'Offers sorted based on roommate preference: $userRoommatePreference');
    return offers;
  }
}
