import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../connectivity/connectivity_service.dart';
import 'filter_modal.dart';
import 'property_card.dart';
import '../../../cas/user_last_contact_landlord.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../view_models/property_view_model.dart';
import '../../../view_models/user_view_model.dart';
import '../../../view/property_details/views/property_detail_view.dart';
import 'package:andlet/models/entities/offer_property.dart';

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
  bool? userRoommatePreference;
  bool _isConnected = true; // Track connectivity status
  bool _hasLoadedFromCache = false; // Flag to indicate if data was loaded from cache
  bool _dataLoadedFromCache = false; // Flag for debugging source of data

  double? selectedPrice;
  double? selectedMinutes;
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    _initializeDataLoad();
    ConnectivityService().onConnectivityChanged.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
        if (_isConnected && !_hasLoadedFromCache) {
          _fetchInitialData();
          _dataLoadedFromCache = false;
        } else if (!_isConnected) {
          _loadFromCache();
          _hasLoadedFromCache = true;
          _dataLoadedFromCache = true;
        }
      });
    });
    fetchUserPreferences();
    NotificationService notificationService = NotificationService();
    notificationService.checkLastContactAction(widget.userEmail);
  }

  void _initializeDataLoad() async {
    _isConnected = await ConnectivityService().isConnected();
    if (_isConnected) {
      _fetchInitialData();
    } else {
      _loadFromCache();
      _hasLoadedFromCache = true;
      _dataLoadedFromCache = true;
    }
  }

  Future<void> _fetchInitialData() async {
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);
    try {
      await offerViewModel.fetchOffersWithFilters();
      await propertyViewModel.fetchProperties();
      _hasLoadedFromCache = false;
      _dataLoadedFromCache = false;
    } catch (e) {
      _hasLoadedFromCache = true;
      _dataLoadedFromCache = true;
    }
  }

  void _loadFromCache() {
    final offerViewModel = Provider.of<OfferViewModel>(context, listen: false);
    final propertyViewModel = Provider.of<PropertyViewModel>(context, listen: false);
    offerViewModel.loadFromCache();
    propertyViewModel.loadFromCache();
  }

  Future<void> _onRefresh() async {
    _isConnected = await ConnectivityService().isConnected();
    if (_isConnected) {
      await _fetchInitialData();
    } else {
      _loadFromCache();
      _dataLoadedFromCache = true;
    }
  }

  Future<void> fetchUserPreferences() async {
    try {
      var userPreferences = await Provider.of<OfferViewModel>(context, listen: false)
          .fetchUserRoommatePreferences(widget.userEmail);
      setState(() {
        userRoommatePreference = userPreferences;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _applyFilters(double? price, double? minutes, DateTimeRange? dateRange) {
    setState(() {
      selectedPrice = price;
      selectedMinutes = minutes;
      selectedDateRange = dateRange;
    });
    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters(
      maxPrice: price,
      maxMinutes: minutes,
      dateRange: dateRange,
    );
  }

  void _clearFilters() {
    setState(() {
      selectedPrice = null;
      selectedMinutes = null;
      selectedDateRange = null;
    });
    Provider.of<OfferViewModel>(context, listen: false).fetchOffersWithFilters();
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
          onApply: (price, minutes, dateRange) {
            _applyFilters(price, minutes, dateRange);
          },
        ),
      ),
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
        padding: EdgeInsets.all(25.w),
        child: Column(
          children: [
            SizedBox(height: 25.h),
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
                      : const AssetImage('lib/assets/personaicono.png')
                  as ImageProvider,
                  radius: 35.r,
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Offline banner and cache loading debug info
            if (!_isConnected)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  color: Colors.redAccent,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.white),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          'No Internet Connection, offers will not be updated',
                          style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_dataLoadedFromCache)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Displaying cached data',
                  style: TextStyle(color: Colors.orange, fontSize: 16.sp),
                ),
              ),

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
                          child: Chip(
                            label: Text(
                              'Price: \$${selectedPrice!.toInt()}',
                              style: const TextStyle(color: Color(0xFF0C356A)),
                            ),
                            backgroundColor: const Color(0xFFB5D5FF),
                          ),
                        ),
                      if (selectedMinutes != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                              'Minutes: ${selectedMinutes!.toInt()}',
                              style: const TextStyle(color: Color(0xFF0C356A)),
                            ),
                            backgroundColor: const Color(0xFFB5D5FF),
                          ),
                        ),
                      if (selectedDateRange != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            label: Text(
                              'Dates: ${DateFormat('MM/dd').format(selectedDateRange!.start)} - ${DateFormat('MM/dd').format(selectedDateRange!.end)}',
                              style: const TextStyle(color: Color(0xFF0C356A)),
                            ),
                            backgroundColor: const Color(0xFFB5D5FF),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 10.h),
            Expanded(
              child: _isConnected
                  ? RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: _buildOfferList(context, sortedOffers))
                  : _buildOfferList(context, sortedOffers),
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

  Widget _buildOfferList(BuildContext context, List<OfferProperty> sortedOffers) {
    final offerViewModel = Provider.of<OfferViewModel>(context);
    final propertyViewModel = Provider.of<PropertyViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    if (offerViewModel.isLoading || propertyViewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0C356A)),
      );
    } else if (sortedOffers.isEmpty) {
      return const Center(
        child: Text(
          'No properties match your filters.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0C356A)),
        ),
      );
    }

    return ListView.builder(
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
      },
    );
  }
}
