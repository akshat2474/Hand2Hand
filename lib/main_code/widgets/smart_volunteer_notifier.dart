import '/backend/backend.dart';
import '../../stylings/stylings_theme.dart';
import '../../stylings/stylings_util.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

class SmartVolunteerNotifier extends StatefulWidget {
  const SmartVolunteerNotifier({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<SmartVolunteerNotifier> createState() => _SmartVolunteerNotifierState();
}

class _SmartVolunteerNotifierState extends State<SmartVolunteerNotifier> {
  bool hasNotified = false;
  String statusMessage = "Initializing...";
  Timer? _timer;
  List<DocumentSnapshot> _sortedNGOs = [];
  int _currentNGOIndex = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendNotificationToNearestNGO(UsersRecord currentUser) async {
    try {
      final userLat = FFAppState().latitude;
      final userLng = FFAppState().longitude;
      final userID = FFAppState().userID;

      if (userID.isEmpty) {
        setState(() => statusMessage = "User location or ID not available.");
        return;
      }

      final ngosSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'NGO')
          .get();

      if (ngosSnapshot.docs.isEmpty) {
        setState(() => statusMessage = "No NGOs found.");
        return;
      }

      _sortedNGOs = _sortNGOsByDistance(ngosSnapshot.docs, userLat, userLng);

      if (_sortedNGOs.isEmpty) {
        setState(() => statusMessage = "Couldn't find a suitable NGO.");
        return;
      }

      _notifyNextNGO(currentUser);
    } catch (e) {
      setState(() => statusMessage = "Error: $e");
    }
  }

  List<DocumentSnapshot> _sortNGOsByDistance(
      List<DocumentSnapshot> ngos, double userLat, double userLng) {
    ngos.sort((a, b) {
      final latA = a.get('latitude');
      final lngA = a.get('longitude');
      final latB = b.get('latitude');
      final lngB = b.get('longitude');

      if (latA == null || lngA == null || latB == null || lngB == null) {
        return 0;
      }

      final distanceA = _calculateDistance(userLat, userLng, latA, lngA);
      final distanceB = _calculateDistance(userLat, userLng, latB, lngB);

      return distanceA.compareTo(distanceB);
    });

    return ngos
        .where((ngo) =>
            ngo.get('latitude') != null && ngo.get('longitude') != null)
        .toList();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.0174533; // π / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void _notifyNextNGO(UsersRecord currentUser) async {
    if (_currentNGOIndex >= _sortedNGOs.length) {
      setState(() => statusMessage = "No more NGOs available to notify.");
      return;
    }

    final ngoDoc = _sortedNGOs[_currentNGOIndex];
    final ngoRef = ngoDoc.reference;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.reference.id);

    // Write notification to Firestore
    final notificationRef =
        await FirebaseFirestore.instance.collection('notifications').add({
      'sender': userRef,
      'recipient': ngoRef,
      'status': 'pending',
      'timestamp': Timestamp.now(),
    });

    setState(() => statusMessage =
        "Notification sent to NGO ${_currentNGOIndex + 1}. Waiting for response...");

    // Start timer for 5 minutes
    _timer = Timer(const Duration(minutes: 5),
        () => _checkResponseAndProceed(notificationRef));
  }

  void _checkResponseAndProceed(DocumentReference notificationRef) async {
    final notificationDoc = await notificationRef.get();
    if (notificationDoc.get('status') == 'pending') {
      // No response, move to next NGO
      await notificationRef.update({'status': 'expired'});
      _currentNGOIndex++;
      if (_currentNGOIndex < _sortedNGOs.length) {
        _notifyNextNGO(await UsersRecord.getDocumentOnce(FirebaseFirestore
            .instance
            .collection('users')
            .doc(FFAppState().userID)));
      } else {
        setState(
            () => statusMessage = "No NGOs responded. Please try again later.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(FFAppState().userID);

    return StreamBuilder<DocumentSnapshot>(
      stream: userDocRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;
        final currentUser = UsersRecord.fromSnapshot(data);

        // Notify only once
        if (!hasNotified) {
          _sendNotificationToNearestNGO(currentUser);
          hasNotified = true;
        }

        return Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          ),
        );
      },
    );
  }
}
