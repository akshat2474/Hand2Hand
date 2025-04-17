import '/backend/backend.dart'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class NGONotificationInbox extends StatefulWidget {
  const NGONotificationInbox({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NGONotificationInbox> createState() => _NGONotificationInboxState();
}

class _NGONotificationInboxState extends State<NGONotificationInbox> {
  Future<void> updateStatus(DocumentSnapshot notifDoc, String newStatus) async {
    try {
      final notifRef = notifDoc.reference;
      final notifData = notifDoc.data() as Map<String, dynamic>;

      await notifRef.update({'status': newStatus});

      if (newStatus == 'declined') {
        await notifyNextNGO(notifData);
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  Future<void> notifyNextNGO(Map<String, dynamic> notifData) async {
    try {
      final List<dynamic> notifiedNGOs = notifData['notifiedNGOs'] ?? [];
      final DocumentReference senderRef = notifData['sender'];

      final senderDoc = await senderRef.get();
      final sender = senderDoc.data() as Map<String, dynamic>;
      final double lat1 = sender['latitude'];
      final double lon1 = sender['longitude'];

      final allNGOsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'NGO')
          .get();

      final ngos = allNGOsSnapshot.docs.where((doc) {
        return !notifiedNGOs.contains(doc.reference);
      }).toList();

      ngos.sort((a, b) {
        final latA = a['latitude'];
        final lonA = a['longitude'];
        final latB = b['latitude'];
        final lonB = b['longitude'];

        final distA = _haversine(lat1, lon1, latA, lonA);
        final distB = _haversine(lat1, lon1, latB, lonB);

        return distA.compareTo(distB);
      });

      if (ngos.isNotEmpty) {
        final nextNGORef = ngos.first.reference;

        await FirebaseFirestore.instance.collection('notifications').add({
          'sender': senderRef,
          'recipient': nextNGORef,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(),
          'notifiedNGOs': [...notifiedNGOs, nextNGORef],
        });
      }
    } catch (e) {
      print('Error notifying next NGO: $e');
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in kilometers
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('User not logged in.'));
    }

    final currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(uid);

    return Container(
      width: widget.width,
      height: widget.height,
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipient', isEqualTo: currentUserRef)
            .where('status', isEqualTo: 'pending')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No new requests.'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: const Text('Volunteer Request'),
                  subtitle: Text(
                      'Received: ${_formatTimestamp(notif['timestamp'] as Timestamp)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => updateStatus(notif, 'accepted'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => updateStatus(notif, 'declined'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
