import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  // Get current position
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable it
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // Convert Position to LatLng for Google Maps
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  // Convert LatLng to GeoPoint for Firestore
  GeoPoint latLngToGeoPoint(LatLng latLng) {
    return GeoPoint(latLng.latitude, latLng.longitude);
  }

  // Convert GeoPoint to LatLng for Google Maps
  LatLng geoPointToLatLng(GeoPoint geoPoint) {
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  // Calculate distance between two positions in kilometers
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    return Geolocator.distanceBetween(
          point1.latitude,
          point1.longitude,
          point2.latitude,
          point2.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  // Get nearby shops based on current location
  List<T> getNearbyItems<T>(
    List<T> items,
    GeoPoint currentLocation,
    double maxDistanceKm,
    GeoPoint Function(T) getItemLocation,
  ) {
    return items.where((item) {
      GeoPoint itemLocation = getItemLocation(item);
      double distance = calculateDistance(currentLocation, itemLocation);
      return distance <= maxDistanceKm;
    }).toList();
  }
}
