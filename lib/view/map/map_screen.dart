import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/google_places_service.dart';
import '../../controllers/map_controller.dart';
import 'dart:math';

class MapScreen extends StatefulWidget {
  static const String routeName = "/map";

  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final MapController _mapControllerClass = MapController();

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

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
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
    if (_draggedMarkerPosition == null) {
      await _mapControllerClass.findNearestDriver(_selectedPosition!);
    }
    print("🚀 Finding driver with location: $_draggedMarkerPosition");

    if (_draggedMarkerPosition == null) {
      print("⏳ Waiting for user to drag the marker...");
      return; // Prevent calling API with null location
    }

    await _mapControllerClass
        .findNearestDriver(_draggedMarkerPosition ?? _selectedPosition!);
  }

  void _adjustMapView() {
    if (_mapController == null ||
        _mapControllerClass.currentPosition == null ||
        _mapControllerClass.driverPosition == null) {
      print("⚠️ Cannot adjust map: Missing locations or controller.");
      return;
    }

    LatLng userLocation = _mapControllerClass.currentPosition!;
    LatLng driverLocation = _mapControllerClass.driverPosition!;

    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        min(userLocation.latitude, driverLocation.latitude),
        min(userLocation.longitude, driverLocation.longitude),
      ),
      northeast: LatLng(
        max(userLocation.latitude, driverLocation.latitude),
        max(userLocation.longitude, driverLocation.longitude),
      ),
    );

    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
          bounds, 100), // 100 = padding for better visibility
    );

    print("✅ Map adjusted to fit user & driver.");
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
                            onPressed: _cancelOrder,
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
