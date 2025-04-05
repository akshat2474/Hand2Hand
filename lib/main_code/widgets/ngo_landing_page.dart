import '/backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'dart:async';

final List<Map<String, dynamic>> mealsData = [
  {'donor': 'Alice Johnson', 'count': 200, 'date': 'March 20, 2025'},
  {'donor': 'Bob Williams', 'count': 150, 'date': 'March 18, 2025'},
  {'donor': 'Charlie Brown', 'count': 250, 'date': 'March 15, 2025'},
  {'donor': 'David Lee', 'count': 350, 'date': 'March 10, 2025'},
];

final List<Map<String, String>> transactions = [
  {'donor': 'John Doe', 'amount': '5000', 'date': 'March 20, 2025'},
  {'donor': 'Anonymous', 'amount': '12000', 'date': 'March 18, 2025'},
  {'donor': 'Emma Watson', 'amount': '8000', 'date': 'March 15, 2025'},
  {'donor': 'Anonymous', 'amount': '10000', 'date': 'March 15, 2025'},
  {'donor': 'Anonymous', 'amount': '7000', 'date': 'March 15, 2025'},
  {'donor': 'David Warner', 'amount': '20000', 'date': 'March 15, 2025'},
  {'donor': 'Michael Smith', 'amount': '3000', 'date': 'March 10, 2025'},
];



class NgoLandingPage extends StatefulWidget {
  const NgoLandingPage({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<NgoLandingPage> createState() => _NgoLandingPageState();
}

class _NgoLandingPageState extends State<NgoLandingPage> {
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
  }

  Future<DocumentSnapshot> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    } else {
      throw Exception('User not logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final ngoname = userData['display_name'] ?? 'NGO';
        final meals = userData['meals'] ?? 0;
        final funds = userData['funds'] ?? 0;

        return Scaffold(
          drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NGOProfilePage(userData: userData)));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_pin, size: 40),
                      SizedBox(width: 8),
                      Text('Your Profile', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            title: HeadingTitleName(username: ngoname),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NGONotificationInbox(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    const Text(
                      '🌍 Your Impact',
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.005),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              YourImpact(
                heroText: '$meals Meals Donated',
                headingText: 'Meals Provided',
                detailsWidget: TransactionMeals(meals: meals),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.015),
              YourImpact(
                heroText: '₹$funds Secured',
                headingText: 'Funds Raised',
                detailsWidget: TransactionPage(funds: funds),
              )
            ],
          ),
        );
      },
    );
  }
}

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

      if (newStatus == 'accepted') {
        // Update the donation status
        final donationRef = notifData['donationRef'] as DocumentReference;
        await donationRef.update({
          'status': 'accepted',
          'acceptedByNGO': FirebaseAuth.instance.currentUser!.uid
        });

        // Notify the volunteer
        await FirebaseFirestore.instance.collection('notifications').add({
          'recipientID': notifData['senderID'],
          'recipientName': notifData['senderName'],
          'message': 'Your donation request has been accepted',
          'timestamp': FieldValue.serverTimestamp(),
          'senderID': FirebaseAuth.instance.currentUser!.uid,
          'senderName': (await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get())
              .get('display_name'),
          'type': 'donation_accepted',
          'status': 'pending',
          'donationRef': donationRef,
        });
      } else if (newStatus == 'declined') {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Container(
        width: widget.width,
        height: widget.height,
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .where('recipientID',
                  isEqualTo: FirebaseAuth.instance.currentUser!
                      .uid) // Match recipientID with NGO's UID
              .where('status',
                  isEqualTo: 'pending') // Only fetch pending notifications
              .orderBy('timestamp', descending: true) // Order by most recent
              .snapshots(),
          builder: (context, snapshot) {
            // Debugging logs
            print(
                'Logged-in user UID: ${FirebaseAuth.instance.currentUser!.uid}');
            print('Snapshot has data: ${snapshot.hasData}');
            print(
                'Number of notifications fetched: ${snapshot.data?.docs.length ?? 0}');

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
                    title: Text(notif['message'] ?? 'Volunteer Request'),
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
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class HeadingTitleName extends StatelessWidget {
  const HeadingTitleName({super.key, required this.username});
  final String username;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: RichText(
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Hello ",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            TextSpan(
              text: '$username!',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NGOProfilePage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const NGOProfilePage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final String ngoName = userData['display_name'] ?? 'NGO';
    final String city = userData['city'] ?? 'Unknown City';
    final String email = userData['email'] ?? 'Unknown Email';
    final String phone = userData['phone_number'] ?? 'Unknown Phone';
    final int totalVolunteers = userData['total_volunteers'] ?? 0;
    final String registrationNumber =
        userData['registration_number']?.toString() ?? 'Unknown';
    final String yearFounded =
        userData['year_founded']?.toString() ?? 'Unknown';
    final String officeAddress =
        userData['office_address'] ?? 'Unknown Address';

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/app_logo.png'),
            ),
            const SizedBox(height: 16),
            Text(ngoName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(city, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const Divider(height: 32, thickness: 1),
            _buildInfoTile(Icons.email, "Email", email),
            _buildInfoTile(Icons.phone, "Phone", phone),
            _buildInfoTile(
                Icons.people, "Total Volunteers", "$totalVolunteers"),
            _buildInfoTile(Icons.confirmation_number, "Registration Number",
                registrationNumber),
            _buildInfoTile(Icons.calendar_today, "Year Founded", yearFounded),
            _buildInfoTile(Icons.location_on, "Office Address", officeAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class YourImpact extends StatelessWidget {
  const YourImpact({
    super.key,
    required this.heroText,
    required this.headingText,
    required this.detailsWidget,
  });

  final String heroText;
  final String headingText;
  final Widget detailsWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(
                image: AssetImage('assets/images/image_ngo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black.withAlpha(140),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    headingText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    heroText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => detailsWidget),
                      );
                    },
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionMeals extends StatelessWidget {
  final int meals;

  const TransactionMeals({super.key, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals Donated',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Meals Donated',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('$meals Meals',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: mealsData.length,
                itemBuilder: (context, index) {
                  final meal = mealsData[index];
                  return Card(
                    color: Colors.green[800],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(meal['donor'] ?? 'Anonymous',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(meal['date'] ?? 'Unknown Date',
                          style: const TextStyle(color: Colors.white70)),
                      trailing: Text('${meal['count']} Meals',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionPage extends StatelessWidget {
  final int funds;

  const TransactionPage({super.key, required this.funds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Funds Received',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('₹$funds',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: transactions.isNotEmpty
                  ? ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return Card(
                          color: Colors.green[800],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(transaction['donor'] ?? 'Unknown Donor',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                transaction['date'] ?? 'Unknown Date',
                                style: const TextStyle(color: Colors.white70)),
                            trailing: Text('₹${transaction['amount'] ?? '0'}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('No transactions yet',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
