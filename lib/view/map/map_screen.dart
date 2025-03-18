import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/google_places_service.dart';
import '../../controllers/service_request_controller.dart';
import '../../controllers/map_controller.dart';
import '../../models/service_request_commodities_model.dart';
import 'package:lottie/lottie.dart' hide Marker;
import '../history/order_history_screen.dart';
import '../../services/user_session.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = "/map";

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final MapController _mapControllerClass = MapController();
  final ServiceRequestController _serviceRequestController =
      ServiceRequestController();

  int? driverId;
  double? _distance;
  String? userId;
  LatLng? _draggedMarkerPosition;
  Set<Marker> _markers = {};
  Polyline? _routePolyline;
  bool _trafficEnabled = false;
  String _driverAddress = 'Get driver address...';
  GoogleMapController? _controller;
  LatLng? _selectedPosition;
  bool _isMapLoaded = false;
  Timer? _updateTimer;
  final GooglePlacesService _placesService = GooglePlacesService();
  List<Map<String, String>> _searchResults = [];
  TextEditingController _searchController = TextEditingController();
  String _currentAddress = "Loading address...";
  bool _isFetchingAddress = false;

  List<Map<String, String>> wasteItems = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _requestLocationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<Map<String, String>>) {
      setState(() {
        wasteItems = args;
      });
    }
  }

  Future<void> _loadUserId() async {
    String? id = await UserSession().getUserId();
    setState(() {
      userId = id;
    });
  }

  void _onConfirmOrderPressed() async {
    if (_selectedPosition == null ||
        driverId == null ||
        _distance == null ||
        userId == null) {
      print("❌ Error: Missing required information.");
      return;
    }

    // 🔍 Debugging: Print wasteItems before mapping
    print("🗑 Waste Items:");
    for (var item in wasteItems) {
      print("  - $item");
    }

    try {
      // ✅ Extract commodities safely, providing a default quantity
      List<ServiceRequestCommodityModel> commodities = wasteItems.map((item) {
        if (item["commodity_id"] == null || item["weight"] == null) {
          throw Exception("Missing or null values in wasteItems: $item");
        }

        return ServiceRequestCommodityModel(
          serviceRequestId: 0, // Dummy value (set by backend)
          commodityId: int.tryParse(item["commodity_id"].toString()) ?? 0,
          quantity: num.tryParse(item["quantity"]?.toString() ?? "1") ??
              1, // ✅ Default to 1 if missing
          weight: num.tryParse(item["weight"].toString()),
          createdAt: DateTime.now(),
        );
      }).toList();

      // ✅ Debug output after processing
      print("📦 Extracted Commodities:");
      for (var commodity in commodities) {
        print("  - Commodity ID: ${commodity.commodityId}");
        print("    Quantity: ${commodity.quantity}");
        print("    Weight: ${commodity.weight ?? 'N/A'}");
      }

      // ✅ Confirm order
      await _serviceRequestController.confirmOrder(
        userId: userId!,
        driverId: driverId!.toString(),
        commodities: commodities,
        distance: _distance!,
      );

      print("✅ Order submitted successfully.");
      _showSuccessDialog();
      Navigator.pushNamed(context, OrderHistoryScreen.routeName);
    } catch (e) {
      print("❌ Error processing commodities: $e");
    }
  }

  void _showSuccessDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ✅ Animated Success Icon
              Lottie.asset(
                'assets/animations/success.json', // Make sure you have this Lottie animation
                width: 120,
                height: 120,
                repeat: false,
              ),
              SizedBox(height: 20),
              // ✅ Title
              Text(
                "Order Confirmed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              // ✅ Subtitle
              Text(
                "Your order has been successfully submitted. We'll notify you when it's processed.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),
              // ✅ Confirm Button
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close modal
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  "OK",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _getDriverAddress() async {
    String? fetchedAddress =
        await _mapControllerClass.fetchDriverAddress(); // Get address

    if (fetchedAddress != null && fetchedAddress.isNotEmpty) {
      setState(() {
        _driverAddress = fetchedAddress; // Update state and re-render UI
      });
      print("✅ Success: Driver address is $_driverAddress.");
    } else {
      print("❌ Failed to get driver location.");
    }
  }

  Future<void> _findDriver() async {
    if (_selectedPosition == null) {
      print("❌ Error: No location selected.");
      return;
    }

    print("🚀 Finding driver for location: $_selectedPosition");

    await _mapControllerClass.findNearestDriver(_selectedPosition!);

    // ✅ Retrieve and print driver ID after finding nearest driver
    driverId = _mapControllerClass.driverId;
    _distance = _mapControllerClass.distance; // ✅ Assign distance

    if (driverId != null) {
      print("✅ Assigned Driver ID: $driverId");
      print("📏 Distance to Driver: $_distance km"); // ✅ Print distance
    } else {
      print("⚠️ No driver assigned.");
    }
  }

// Function to fetch user's current location
  Future<LatLng?> _getUserCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print("❌ Error getting user location: $e");
      return null;
    }
  }

  void _cancelOrder() {
    setState(() {
      _mapControllerClass.resetMap();
      _trafficEnabled = false;
      _routePolyline = null;
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      print("❌ Location permission denied");
      setState(() => _isMapLoaded = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng userLocation = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = userLocation;
        _isMapLoaded = true;
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(userLocation));
      _fetchAddress(userLocation);
    } catch (e) {
      print("⚠️ Error getting location: $e");
      setState(() => _isMapLoaded = false);
    }
  }

  void _onMarkerDragged(LatLng newPosition) {
    _updateTimer?.cancel();
    setState(() {
      _draggedMarkerPosition = newPosition;
    });
    _updateTimer = Timer(const Duration(seconds: 1), () {
      setState(() {
        _selectedPosition = newPosition;
        print("📍 New Location: $_selectedPosition");
      });

      _fetchAddress(_selectedPosition!);
    });
  }

  Future<void> _fetchAddress(LatLng position) async {
    setState(() {
      _isFetchingAddress = true;
    });

    String address = await _placesService.getAddressFromCoordinates(position);
    setState(() {
      _currentAddress = address;
      _isFetchingAddress = false;
    });
  }

  void _searchPlaces(String query) async {
    if (query.isNotEmpty) {
      try {
        List<Map<String, String>> results =
            await _placesService.getPlaceSuggestions(query);

        setState(() {
          _searchResults = results;
        });
      } catch (e) {
        print("❌ Error fetching suggestions: $e");
      }
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _selectPlace(String placeId) async {
    LatLng? coordinates = await _placesService.getCoordinatesFromPlace(placeId);
    if (coordinates != null) {
      setState(() {
        _selectedPosition = coordinates;
        _searchResults = [];
        _searchController.clear();
      });

      _controller?.animateCamera(CameraUpdate.newLatLng(coordinates));
      _fetchAddress(coordinates);
      print("test lokasi : $coordinates");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: _isMapLoaded && _selectedPosition != null
          ? Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedPosition!,
                    zoom: 14,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId("selected-location"),
                      position: _selectedPosition!,
                      draggable: _mapControllerClass
                          .isSearchEnabled, // Disable dragging if assigned
                      onDragEnd: _onMarkerDragged,
                    ),
                    if (_mapControllerClass.driverPosition != null)
                      Marker(
                        markerId: const MarkerId("driver-location"),
                        position: _mapControllerClass.driverPosition!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueBlue), // Blue icon for driver
                      ),
                  },
                  polylines: _mapControllerClass.routePolyline.isNotEmpty
                      ? {
                          Polyline(
                            polylineId: const PolylineId("route"),
                            points: _mapControllerClass.routePolyline,
                            color: const Color.fromARGB(255, 255, 195,
                                139), // Ensure you import 'package:flutter/material.dart'
                            width: 7,
                          ),
                        }
                      : {},
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),

                if (_mapControllerClass.isSearchEnabled)
                  // Marker Info: "Hold and Drag to Relocate"
                  Positioned(
                    left: MediaQuery.of(context).size.width / 2 - 80,
                    top: MediaQuery.of(context).size.height / 2 - 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Hold and drag to relocate",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),

                if (_mapControllerClass.isSearchEnabled)
                  // Search Bar
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Search for a place...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: _searchPlaces,
                        ),

                        // Autocomplete Suggestions
                        if (_searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 5)
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_searchResults[index]
                                          ["description"] ??
                                      ""),
                                  onTap: () => _selectPlace(
                                      _searchResults[index]["place_id"]!),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),

                // Address Display Above "Continue Order"
                Positioned(
                  bottom: _mapControllerClass.isSearchEnabled ? 80 : 135,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 5)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 5),
                        Expanded(
                          child: _isFetchingAddress
                              ? const Center(
                                  child: SizedBox(
                                    height: 15,
                                    width: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Text(
                                  _currentAddress,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                //  driver Address Display
                if (!_mapControllerClass.isSearchEnabled)
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 5),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _driverAddress,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_mapControllerClass.isSearchEnabled)
                  // Confirm Selection Button
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        if (_mapControllerClass.isSearchEnabled)
                          ElevatedButton(
                            onPressed: () async {
                              await _findDriver();
                              await _getDriverAddress();
                              print("✅ Finding driver & adjusting map...");
                            },
                            child: Text("Find driver"),
                          ),
                      ],
                    ),
                  ),

                if (_mapControllerClass.isDriverAssigned)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _cancelOrder,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text("Cancel Order"),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _onConfirmOrderPressed,
                            child: Text("Continue"),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
