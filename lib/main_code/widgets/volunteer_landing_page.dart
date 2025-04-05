import '/backend/backend.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

class VolunteerLandingPage extends StatefulWidget {
  const VolunteerLandingPage({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<VolunteerLandingPage> createState() => _VolunteerLandingPageState();
}

class _VolunteerLandingPageState extends State<VolunteerLandingPage> {
  late Future<DocumentSnapshot> _userDataFuture;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _userDataFuture =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
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
          return const Center(child: Text('User data not found'));
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;
        String username = userData['display_name'] ?? 'User';

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
                        builder: (context) => const ProfilePage(),
                      ),
                    );
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
            title: HeadingTitleName(username: username),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    children: [
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.width * 0.45,
                          child: const DonateNowCard(
                            displayText: 'Change The World With Your Help',
                            displayTextButton: 'Donate Now',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        '🏆 Top Donors',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Most Money', style: TextStyle(fontSize: 17)),
                const SizedBox(height: 5),
                const ListViewDonorsTop(donorsWhat: 'funds'),
                const SizedBox(height: 20),
                const Text('Most Meals', style: TextStyle(fontSize: 17)),
                const SizedBox(height: 5),
                const ListViewDonorsTop(donorsWhat: 'meals'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListViewDonorsTop extends StatelessWidget {
  const ListViewDonorsTop({super.key, required this.donorsWhat});

  final String donorsWhat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy(donorsWhat, descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No donors found'));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var donor = snapshot.data!.docs[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.4,
                margin: const EdgeInsets.only(left: 20, right: 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage(
                          "assets/images/app_icon.png"),
                      radius: 35,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      donor['display_name'] ?? 'Anonymous',
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      donorsWhat == 'funds'
                          ? "₹${donor['funds'] ?? 0}"
                          : "${donor['meals'] ?? 0} meals",
                      style: const TextStyle(color: Colors.green, fontSize: 17),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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

class DonateNowCard extends StatelessWidget {
  const DonateNowCard({
    super.key,
    required this.displayText,
    required this.displayTextButton,
  });

  final String displayText;
  final String displayTextButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/card_backdrop.png',
                fit: BoxFit.fill,
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
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 38,
                  right: 38,
                  top: 20,
                  bottom: 5,
                ),
                child: Text(
                  displayText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const DonateWhat()));
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(displayTextButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DonateWhat extends StatefulWidget {
  const DonateWhat({super.key});

  @override
  State<DonateWhat> createState() => _DonateWhatState();
}

class _DonateWhatState extends State<DonateWhat> {
  final List<Map<String, dynamic>> options = [
    {
      "name": "Money",
      "image": "assets/images/image.jpg",
      "nameOfWidget": const DonateMoneyPage()
    },
    {
      "name": "Food",
      "image": "assets/images/image1.jpg",
      "nameOfWidget": const FoodDonationPage()
    },
    {
      "name": "Miscellaneous",
      "image": "assets/images/image2.jpg",
      "nameOfWidget": const MiscellaneousDonationPage()
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate What?", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 118, 233, 122),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Choose what to donate:',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  options[index]['nameOfWidget']),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color.fromARGB(79, 145, 165, 142),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              child: Image.asset(
                                options[index]['image'],
                                fit: BoxFit.cover,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Text(
                                    options[index]['name']!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                options[index]['nameOfWidget']),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: const Text("Select"),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodDonationPage extends StatefulWidget {
  const FoodDonationPage({super.key});

  @override
  State<FoodDonationPage> createState() => _FoodDonationPageState();
}

class _FoodDonationPageState extends State<FoodDonationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedFoodType;

  final List<String> foodTypes = [
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Cooked Meals',
    'Canned Goods',
    'Others',
  ];

  void submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          int quantity = int.parse(quantityController.text);

          // Create a new document in the 'donations' collection
          DocumentReference donationRef =
              await FirebaseFirestore.instance.collection('donations').add({
            'userId': user.uid,
            'foodType': selectedFoodType,
            'quantity': quantity,
            'description': descriptionController.text,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'pending',
          });

          // Find nearest NGO and send notification
          await sendNotificationToNearestNGO(user, donationRef);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DonationStatusPage(donationRef: donationRef)));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit donation: $e')),
          );
        }
      }
    }
  }

  Future<void> sendNotificationToNearestNGO(
    User user, DocumentReference donationRef) async {
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    QuerySnapshot ngoSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'NGO')
        .get();

    List<DocumentSnapshot> sortedNGOs = ngoSnapshot.docs.toList()
      ..sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          a['latitude'],
          a['longitude'],
        );
        double distanceB = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          b['latitude'],
          b['longitude'],
        );
        return distanceA.compareTo(distanceB);
      });

    if (sortedNGOs.isNotEmpty) {
      DocumentSnapshot nearestNGO = sortedNGOs.first;

      // Create notification
      DocumentReference notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'recipientID': nearestNGO.id, // NGO UID as string
        'recipientName': nearestNGO['display_name'],
        'message': 'Donation: $selectedFoodType (${quantityController.text})',
        'timestamp': FieldValue.serverTimestamp(),
        'senderID': user.uid,
        'senderName': (await FirebaseFirestore.instance.collection('users').doc(user.uid).get()).get('display_name'),
        'type': 'food_donation',
        'location': GeoPoint(position.latitude, position.longitude),
        'isRead': false,
        'status': 'pending',
        'donationRef': donationRef,
      });

      print('Notification created with ID: ${notificationRef.id}');
    } else {
      print('No NGOs found nearby.');
    }
  } catch (e) {
    print('Error sending notification: $e');
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate Food')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedFoodType,
                hint: const Text('Select food type'),
                items: foodTypes.map((food) {
                  return DropdownMenuItem(value: food, child: Text(food));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFoodType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a food type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Quantity (number of meals)'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter quantity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.text,
                decoration:
                    const InputDecoration(labelText: 'Brief Description (optional)'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: submitDonation,
                  child: const Text('Donate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MiscellaneousDonationPage extends StatefulWidget {
  const MiscellaneousDonationPage({super.key});

  @override
  State<MiscellaneousDonationPage> createState() =>
      _MiscellaneousDonationPageState();
}

class _MiscellaneousDonationPageState extends State<MiscellaneousDonationPage> {
  final _formKey = GlobalKey<FormState>();
  String? selectedItem;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> donationItems = [
    'Clothes',
    'Shoes',
    'Blankets',
    'Books',
    'Toys',
    'School Supplies',
    'Electronics',
    'Furniture',
    'Others',
  ];

  void submitDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          int quantity = int.parse(quantityController.text);

          // Create a new document in the 'donations' collection
          DocumentReference donationRef =
              await FirebaseFirestore.instance.collection('donations').add({
            'userId': user.uid,
            'itemType': selectedItem,
            'quantity': quantity,
            'description': descriptionController.text,
            'timestamp': FieldValue.serverTimestamp(),
            'status': 'pending',
          });

          // Find nearest NGO and send notification
          await sendNotificationToNearestNGO(user, donationRef);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DonationStatusPage(donationRef: donationRef)));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit donation: $e')),
          );
        }
      }
    }
  }

  Future<void> sendNotificationToNearestNGO(
      User user, DocumentReference donationRef) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      QuerySnapshot ngoSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'NGO')
          .get();

      List<DocumentSnapshot> sortedNGOs = ngoSnapshot.docs.toList()
        ..sort((a, b) {
          double distanceA = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            a['latitude'],
            a['longitude'],
          );
          double distanceB = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            b['latitude'],
            b['longitude'],
          );
          return distanceA.compareTo(distanceB);
        });

      if (sortedNGOs.isNotEmpty) {
        DocumentSnapshot nearestNGO = sortedNGOs.first;
        await FirebaseFirestore.instance.collection('notifications').add({
          'recipientID': nearestNGO.id,
          'recipientName': nearestNGO['display_name'],
          'message':
              '${user.displayName} wants to donate: $selectedItem (${quantityController.text})',
          'timestamp': FieldValue.serverTimestamp(),
          'senderID': user.uid,
          'senderName': user.displayName??"Anonymous",
          'type': 'misc_donation',
          'location': GeoPoint(position.latitude, position.longitude),
          'isRead': false,
          'status': 'pending',
          'donationRef': donationRef,
        });
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate Items')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: selectedItem,
                hint: const Text('Select item to donate'),
                items: donationItems.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an item' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter quantity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Brief Description'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: submitDonation,
                  child: const Text('Donate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonateMoneyPage extends StatefulWidget {
  const DonateMoneyPage({super.key});

  @override
  State<DonateMoneyPage> createState() => _DonateMoneyPageState();
}

class _DonateMoneyPageState extends State<DonateMoneyPage> {
  final TextEditingController amountController = TextEditingController();

  void openGooglePay(String amount) async {
    String upiUrl =
        "upi://pay?pa=dummynumber@upi&pn=DummyName&am=$amount&cu=INR&tn=Donation";
    if (await canLaunch(upiUrl)) {
      await launch(upiUrl);
    } else {
      throw 'Could not launch Google Pay';
    }
  }

  void submitDonation() async {
    if (amountController.text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          int amount = int.parse(amountController.text);

          // Create a new document in the 'donations' collection
          await FirebaseFirestore.instance.collection('donations').add({
            'userId': user.uid,
            'amount': amount,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Update the user's donation amount
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(user.uid);
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(userRef);
            if (!snapshot.exists) {
              throw Exception("User does not exist!");
            }
            Map<String, dynamic> userData =
                snapshot.data() as Map<String, dynamic>;
            int currentFunds = userData['funds'] ?? 0;
            transaction.update(userRef, {'funds': currentFunds + amount});
          });

          // Open Google Pay
          openGooglePay(amount.toString());

          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const ThankyouPage()));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit donation: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate Money", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the amount you want to donate",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text(
                    "₹ ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter amount",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Donate"),
            ),
          ],
        ),
      ),
    );
  }
}

class DonationStatusPage extends StatelessWidget {
  final DocumentReference donationRef;

  const DonationStatusPage({super.key, required this.donationRef});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Status')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: donationRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Donation not found'));
          }

          Map<String, dynamic> donationData =
              snapshot.data!.data() as Map<String, dynamic>;
          String status = donationData['status'];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Donation Status: $status',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (status == 'accepted')
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NGODirectionsMap(
                            donationRef: donationRef,
                          ),
                        ),
                      );
                    },
                    child: const Text('View Directions to NGO'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NGODirectionsMap extends StatefulWidget {
  final DocumentReference donationRef;

  const NGODirectionsMap({super.key, required this.donationRef});

  @override
  _NGODirectionsMapState createState() => _NGODirectionsMapState();
}

class _NGODirectionsMapState extends State<NGODirectionsMap> {
  ll.LatLng? userLocation;
  ll.LatLng? ngoLocation;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    getLocationsAndSetState();
  }

  Future<void> getLocationsAndSetState() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLocation = ll.LatLng(position.latitude, position.longitude);
      });

      DocumentSnapshot donationSnapshot = await widget.donationRef.get();
      Map<String, dynamic> donationData =
          donationSnapshot.data() as Map<String, dynamic>;
      String ngoId = donationData['acceptedByNGO'];

      DocumentSnapshot ngoSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(ngoId).get();
      Map<String, dynamic> ngoData = ngoSnapshot.data() as Map<String, dynamic>;

      setState(() {
        ngoLocation = ll.LatLng(ngoData['latitude'], ngoData['longitude']);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error getting locations: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Directions to NGO')),
        body: Center(
          child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    if (userLocation == null || ngoLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Directions to NGO')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Directions to NGO')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation!,
          initialZoom: 13,
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
                width: 80,
                height: 80,
                child: const Icon(Icons.location_pin, color: Colors.blue, size: 40),
              ),
              Marker(
                point: ngoLocation!,
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [userLocation!, ngoLocation!],
                strokeWidth: 4,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ThankyouPage extends StatelessWidget {
  const ThankyouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text("Donation Submitted"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Thank you for your generosity!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const DonateWhat()));
                },
                child: const Text("Donate More"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User data not found'));
        }

        Map<String, dynamic> userData =
            snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                      "assets/images/app_icon.png"),
                ),
                const SizedBox(height: 10),
                Text(
                  userData['display_name'] ?? 'User',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(userData['email'] ?? '',
                    style: const TextStyle(color: Colors.grey)),
                Text(userData['city'] ?? '',
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                YourImpact(
                  heroText: '${userData['meals'] ?? 0} Meals',
                  headingText: 'Meals Donated',
                  detailsWidget: const DonateWhat(),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                YourImpact(
                  heroText: '₹${userData['funds'] ?? 0}',
                  headingText: 'Funds Donated',
                  detailsWidget: const DonateWhat(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Miscellaneous Donations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (userData['miscellaneous'] as List<dynamic>? ?? [])
                      .map((item) => Chip(label: Text(item.toString())))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
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
                image: AssetImage(
                    "assets/images/image_ngo.png"),
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
