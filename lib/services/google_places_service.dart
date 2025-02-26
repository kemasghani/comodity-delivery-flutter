import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver_model.dart';

class GooglePlacesService {
  final String _apiKey = "AIzaSyBEfLs7xWM8RFVNsWIrbkaGF8lD2WvU6n0";

  Future<Driver> getNearestDriver(LatLng userPosition, List<Driver> drivers) async {
    String destinations = drivers
        .map((d) => "${d.latitude},${d.longitude}")
        .join("|");

    final String url =
        "https://maps.googleapis.com/maps/api/distancematrix/json?"
        "origins=${userPosition.latitude},${userPosition.longitude}"
        "&destinations=$destinations"
        "&key=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        List<dynamic> rows = data["rows"];
        if (rows.isNotEmpty && rows[0]["elements"].isNotEmpty) {
          List<dynamic> elements = rows[0]["elements"];

          // Find the driver with the shortest distance
          int minIndex = 0;
          int minDistance = elements[0]["distance"]["value"];

          for (int i = 1; i < elements.length; i++) {
            int distance = elements[i]["distance"]["value"];
            if (distance < minDistance) {
              minDistance = distance;
              minIndex = i;
            }
          }

          return drivers[minIndex]; // Return the closest driver
        }
      }
    } catch (e) {
      print("⚠️ Error finding nearest driver: $e");
    }

    return drivers.first; // Fallback: Return the first driver if API fails
  }

  /// 🚗 Get Route Details (with updated user position)
  Future<Map<String, dynamic>> getRouteDetails(LatLng start, LatLng end) async {
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?"
        "origin=${start.latitude},${start.longitude}"
        "&destination=${end.latitude},${end.longitude}"
        "&departure_time=now&traffic_model=best_guess"
        "&key=$_apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["routes"].isNotEmpty) {
        final route = data["routes"][0];
        final legs = route["legs"][0];
        final distance =
            legs["distance"]["value"] / 1000; // Convert meters to km

        // Extract polyline points
        String encodedPolyline = route["overview_polyline"]["points"];
        List<LatLng> polylinePoints = _decodePolyline(encodedPolyline);

        return {
          "distance": distance,
          "polyline": polylinePoints,
        };
      }
    }

    throw Exception("Failed to fetch route details from Google Maps API");
  }

  /// 🔄 Decode Google Maps Polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
  /// ✅ Convert LatLng to Address (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(LatLng position) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        return data["results"][0]["formatted_address"];
      } else {
        return "Unknown location";
      }
    } catch (e) {
      print("⚠️ Error fetching address: $e");
      return "Error retrieving address";
    }
  }

  /// ✅ Get Place Suggestions (Autocomplete API)
  Future<List<Map<String, String>>> getPlaceSuggestions(String query) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        return List<Map<String, String>>.from(
          data["predictions"].map((place) => {
                "place_id": place["place_id"] as String,
                "description": place["description"] as String,
              }),
        );
      }
      return [];
    } catch (e) {
      print("⚠️ Error fetching suggestions: $e");
      return [];
    }
  }

  /// ✅ Convert Place ID to LatLng
  Future<LatLng?> getCoordinatesFromPlace(String placeId) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$_apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        final location = data["results"][0]["geometry"]["location"];
        return LatLng(location["lat"], location["lng"]);
      }
      return null;
    } catch (e) {
      print("⚠️ Error fetching coordinates: $e");
      return null;
    }
  }
}
