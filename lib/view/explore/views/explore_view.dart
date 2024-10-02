import 'package:andlet/analytics/analytics_engine.dart';
import 'package:andlet/view_models/user_action_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../cas/user_lastContact_landloard.dart';
import '../../../view_models/offer_view_model.dart';
import '../../../view_models/property_view_model.dart';
import '../../../view_models/user_view_model.dart'; // Import UserViewModel
import 'filter_modal.dart';
import 'property_card.dart';

import 'package:andlet/view/property_details/views/property_detail_view.dart';

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

    // Fetch offers and properties once the widget is mounted without any filters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OfferViewModel>(context, listen: false)
          .fetchOffersWithFilters();
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
      fetchUserPreferences(); // Fetch user preferences
      NotificationService notificationService = NotificationService();
      notificationService.checkLastContactAction(widget.userEmail);
    });
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

  // Sort offers based on roommate preference
  List<OfferWithProperty> _sortOffers(List<OfferWithProperty> offers) {
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
    final userViewModel = Provider.of<UserViewModel>(
        context); // Use UserViewModel to fetch agent data
    String firstName = widget.displayName.split(' ').first;
    final sortedOffers = _sortOffers(offerViewModel.offersWithProperties);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome,',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0C356A),
                      ),
                    ),
                    Text(
                      firstName,
                      style: const TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 40,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF9A826),
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundImage: widget.photoUrl.isNotEmpty
                      ? NetworkImage(widget.photoUrl)
                      : const AssetImage('lib/assets/personaicono.jpg')
                          as ImageProvider,
                  radius: 30,
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                AnalyticsEngine
                    .logFilterButtonPressed(); // Log filter button pressed event
                UserActionsViewModel().addUserAction(widget.userEmail,
                    'filter'); // Log filter button pressed event
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
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
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB5D5FF),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF0C356A)),
                    SizedBox(width: 10),
                    Text(
                      'Search for a place...',
                      style: TextStyle(color: Color(0xFF0C356A)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            offerViewModel.isLoading || propertyViewModel.isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0C356A),
                      ),
                    ),
                  )
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0C356A),
                ),
              ),
            ) : sortedOffers.isEmpty
                ? const Expanded(
              child: Center(
                child: Text(
                  'No properties match your filters.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C356A),
                  ),
                ),
              ),
            )
                : Expanded(
                    child: ListView.builder(
                      itemCount:
                          _sortOffers(offerViewModel.offersWithProperties)
                              .length,
                      itemBuilder: (context, index) {
                        final offerWithProperty = _sortOffers(
                            offerViewModel.offersWithProperties)[index];
                        final offer = offerWithProperty.offer;
                        final property = offerWithProperty.property;

                        return FutureBuilder<List<String>>(
                          future:
                              propertyViewModel.getImageUrls(property.photos),
                          builder: (context, imageSnapshot) {
                            if (imageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (imageSnapshot.hasError) {
                              return const Center(
                                  child: Text('Error loading images'));
                            }

                            final imageUrls = imageSnapshot.data ?? [];

                            return FutureBuilder<Map<String, dynamic>>(
                              future: userViewModel.fetchUserById(offer
                                  .user_id), // Fetch the user (agent) by user_id
                              builder: (context, agentSnapshot) {
                                if (agentSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (agentSnapshot.hasError ||
                                    !agentSnapshot.hasData) {
                                  return const Center(
                                      child: Text('Error loading agent data'));
                                }

                                final agentData = agentSnapshot.data!;
                                final agentName = agentData['name'];
                                final agentPhoto = agentData['photo'];
                                final agentEmail = agentData['email'];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      // Increment the view counter
                                      bool hasRoommates = offer.roommates > 0;
                                      await Provider.of<OfferViewModel>(context,
                                              listen: false)
                                          .incrementUserViewCounter(
                                              widget.userEmail, hasRoommates);

                                      AnalyticsEngine.logViewPropertyDetails(
                                          property
                                              .id); // Log view property details event
                                      OfferViewModel()
                                          .incrementOfferViewCounter(offer
                                              .offerId); // Log view property details event

                                      // Navigate to property details with agent info
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PropertyDetailView(
                                            title: property.title,
                                            address: property.address,
                                            imageUrls: imageUrls,
                                            rooms: offer.num_rooms.toString(),
                                            bathrooms:
                                                offer.num_baths.toString(),
                                            roommates:
                                                offer.roommates.toString(),
                                            description: property.description,
                                            agentName: agentName,
                                            agentEmail: agentEmail,
                                            agentPhoto: agentPhoto,
                                            price: offer.price_per_month
                                                .toString(),
                                            userEmail: widget.userEmail,
                                          ),
                                        ),
                                      );
                                    },
                                    child: PropertyCard(
                                      imageUrls:
                                          imageUrls, // Image URLs fetched from the property
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
