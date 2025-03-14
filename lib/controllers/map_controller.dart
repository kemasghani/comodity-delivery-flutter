import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/google_places_service.dart';
import '../services/driver_service.dart';
import '../models/driver_model.dart';

class MapController {
  final GooglePlacesService _placesService = GooglePlacesService();
  final DriverService _driverService = DriverService();

  LatLng? _currentPosition;
  LatLng? _driverPosition;
  bool _isDriverAssigned = false;
  bool _isSearchEnabled = true;
  bool _trafficEnabled = false;
  double _distance = 0.0;
  List<LatLng> _routePolyline = [];
  String? _driverAddress;
  int? _driverId;

  LatLng? get currentPosition => _currentPosition;
  LatLng? get driverPosition => _driverPosition;
  bool get isDriverAssigned => _isDriverAssigned;
  bool get isSearchEnabled => _isSearchEnabled;
  bool get trafficEnabled => _trafficEnabled;
  double get distance => _distance;
  List<LatLng> get routePolyline => _routePolyline;
  String? get driverAddress => _driverAddress;
  int? get driverId => _driverId; // ✅ Getter for driver ID

  void setUserPosition(LatLng newPosition) {
    _currentPosition = newPosition;
    print("✅ User position updated: $newPosition");
  }

  void setDriverPosition(LatLng newPosition) {
    _driverPosition = newPosition;
    print("✅ Driver position updated: $newPosition");
  }

  /// 🔍 Find the nearest driver and store the driver ID
  Future<void> findNearestDriver(LatLng userPosition) async {
    _currentPosition = userPosition;

    if (_currentPosition == null) {
      print("❌ Error: User position is not available.");
      return;
    }

    print(
        "📍 User Position: Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}");

    final drivers = await _driverService.getAvailableDrivers();
    if (drivers.isNotEmpty) {
      var result = await _getClosestDriver(drivers);

      Driver nearestDriver = result["driver"];
      double distance = result["distance"];

      _driverPosition = LatLng(nearestDriver.latitude, nearestDriver.longitude);
      _driverId = nearestDriver.id; // ✅ Assign driver ID
      _distance = distance; // ✅ Assign distance

      print("🚖 Assigned Driver ID: $_driverId");
      print(
          "🚖 Driver Position: Latitude: ${_driverPosition!.latitude}, Longitude: ${_driverPosition!.longitude}");
      print("📏 Distance to Driver: $_distance km");

      _isDriverAssigned = true;
      _isSearchEnabled = false;
      _trafficEnabled = true;

      // ✅ Fetch driver address
      await fetchDriverAddress();

      // Get Route Details (Distance & Polyline)
      final routeDetails = await _placesService.getRouteDetails(
          _currentPosition!, _driverPosition!);
      print("🛣️ Route details: $routeDetails");

      _routePolyline = routeDetails["polyline"] ?? [];
    } else {
      print("⚠️ No available drivers found.");
    }
  }

  /// 🌍 Fetch the driver's address separately
  Future<String?> fetchDriverAddress() async {
    if (_driverPosition == null) {
      print("❌ No driver position available.");
      return null;
    }

    // Fetch address using Google Places API (or Geocoding API)
    String? address =
        await _placesService.getAddressFromCoordinates(_driverPosition!);

    // Store value
    _driverAddress = address;
    print("📍 Driver Address: $_driverAddress");

    return _driverAddress;
  }

  /// 🏁 Find the nearest driver and distance using Google Distance Matrix API
  Future<Map<String, dynamic>> _getClosestDriver(List<Driver> drivers) async {
    var nearestDriverData =
        await _placesService.getNearestDriver(_currentPosition!, drivers);

    if (nearestDriverData == null) {
      throw Exception("No available drivers found.");
    }

    return {
      "driver": nearestDriverData["driver"] as Driver, // ✅ Nearest driver
      "distance": nearestDriverData["distance"] as double, // ✅ Distance in km
    };
  }

  /// ❌ Reset map when user cancels order
  void resetMap() {
    _currentPosition = null;
    _driverPosition = null;
    _driverId = null; // ✅ Reset driver ID
    _isDriverAssigned = false;
    _isSearchEnabled = true;
    _trafficEnabled = false;
    _routePolyline = [];
    _distance = 0.0;
    _driverAddress = null;
  }
}
