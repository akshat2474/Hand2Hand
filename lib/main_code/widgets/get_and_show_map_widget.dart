import '/backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:firebase_auth/firebase_auth.dart';

class GetAndShowMapWidget extends StatefulWidget {
  const GetAndShowMapWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<GetAndShowMapWidget> createState() => _GetAndShowMapWidgetState();
}

class _GetAndShowMapWidgetState extends State<GetAndShowMapWidget> {
  ll.LatLng? userLocation;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getLocationAndSetState();
  }

  Future<void> getLocationAndSetState() async {
    try {
      print('🔄 Starting location fetch...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          errorMessage = 'Location services are disabled.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          setState(() {
            errorMessage = 'Location permission not granted.';
          });
          return;
        }
      }

      await Future.delayed(const Duration(seconds: 2));

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {


        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
      }

      setState(() {
        userLocation = ll.LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to get location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Center(
        child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation!,
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: userLocation!,
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
