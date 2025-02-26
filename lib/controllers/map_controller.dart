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
  String? _driverAddress; // ✅ Store driver address

  LatLng? get currentPosition => _currentPosition;
  LatLng? get driverPosition => _driverPosition;
  bool get isDriverAssigned => _isDriverAssigned;
  bool get isSearchEnabled => _isSearchEnabled;
  bool get trafficEnabled => _trafficEnabled;
  double get distance => _distance;
  List<LatLng> get routePolyline => _routePolyline;
  String? get driverAddress => _driverAddress;

  /// 🔍 Find the nearest driver based on Google Distance Matrix API
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
      Driver nearestDriver = await _getClosestDriver(drivers);

      _driverPosition = LatLng(
        nearestDriver.latitude,
        nearestDriver.longitude,
      );

      print(
          "🚖 Driver Position: Latitude: ${_driverPosition!.latitude}, Longitude: ${_driverPosition!.longitude}");

      _isDriverAssigned = true;
      _isSearchEnabled = false;
      _trafficEnabled = true;

      // ✅ Fetch driver address in a separate function
      await fetchDriverAddress();

      // Get Route Details (Distance & Polyline)
      final routeDetails = await _placesService.getRouteDetails(
          _currentPosition!, _driverPosition!);
      print("🛣️ Route details: $routeDetails");

      _distance = routeDetails["distance"] ?? 0.0;
      _routePolyline = routeDetails["polyline"] ?? [];
    } else {
      print("⚠️ No available drivers found.");
    }
  }

  /// 🌍 Fetch the driver's address separately
  Future<void> fetchDriverAddress() async {
    if (_driverPosition != null) {
      _driverAddress =
          await _placesService.getAddressFromCoordinates(_driverPosition!);
      print("🏠 Driver Address: $_driverAddress");
    } else {
      print("⚠️ Cannot fetch address, driver position is null.");
    }
  }

  /// Helper function to find the nearest driver using Google Distance Matrix API
  Future<Driver> _getClosestDriver(List<Driver> drivers) async {
    return await _placesService.getNearestDriver(_currentPosition!, drivers);
  }

  /// ❌ Reset map when user cancels order
  void resetMap() {
    _currentPosition = null;
    _driverPosition = null;
    _isDriverAssigned = false;
    _isSearchEnabled = true;
    _trafficEnabled = false;
    _routePolyline = [];
    _distance = 0.0;
    _driverAddress = null; // ✅ Reset driver address
  }
}
