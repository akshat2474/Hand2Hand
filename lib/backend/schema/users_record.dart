import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '../../stylings/stylings_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "latitude" field.
  double? _latitude;
  double get latitude => _latitude ?? 0.0;
  bool hasLatitude() => _latitude != null;

  // "longitutde" field.
  double? _longitutde;
  double get longitutde => _longitutde ?? 0.0;
  bool hasLongitutde() => _longitutde != null;

  // "city" field.
  String? _city;
  String get city => _city ?? '';
  bool hasCity() => _city != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasBio() => _bio != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "meals" field.
  int? _meals;
  int get meals => _meals ?? 0;
  bool hasMeals() => _meals != null;

  // "funds" field.
  int? _funds;
  int get funds => _funds ?? 0;
  bool hasFunds() => _funds != null;

  // "miscellaneous" field.
  List<String>? _miscellaneous;
  List<String> get miscellaneous => _miscellaneous ?? const [];
  bool hasMiscellaneous() => _miscellaneous != null;

  // "phone" field.
  int? _phone;
  int get phone => _phone ?? 0;
  bool hasPhone() => _phone != null;

  // "total_volunteers" field.
  int? _totalVolunteers;
  int get totalVolunteers => _totalVolunteers ?? 0;
  bool hasTotalVolunteers() => _totalVolunteers != null;

  // "registration_number" field.
  int? _registrationNumber;
  int get registrationNumber => _registrationNumber ?? 0;
  bool hasRegistrationNumber() => _registrationNumber != null;

  // "year_founded" field.
  int? _yearFounded;
  int get yearFounded => _yearFounded ?? 0;
  bool hasYearFounded() => _yearFounded != null;

  // "office_address" field.
  String? _officeAddress;
  String get officeAddress => _officeAddress ?? '';
  bool hasOfficeAddress() => _officeAddress != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _role = snapshotData['role'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _latitude = castToType<double>(snapshotData['latitude']);
    _longitutde = castToType<double>(snapshotData['longitutde']);
    _city = snapshotData['city'] as String?;
    _bio = snapshotData['bio'] as String?;
    _uid = snapshotData['uid'] as String?;
    _meals = castToType<int>(snapshotData['meals']);
    _funds = castToType<int>(snapshotData['funds']);
    _miscellaneous = getDataList(snapshotData['miscellaneous']);
    _phone = castToType<int>(snapshotData['phone']);
    _totalVolunteers = castToType<int>(snapshotData['total_volunteers']);
    _registrationNumber = castToType<int>(snapshotData['registration_number']);
    _yearFounded = castToType<int>(snapshotData['year_founded']);
    _officeAddress = snapshotData['office_address'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  DateTime? createdTime,
  String? phoneNumber,
  String? role,
  String? photoUrl,
  double? latitude,
  double? longitutde,
  String? city,
  String? bio,
  String? uid,
  int? meals,
  int? funds,
  int? phone,
  int? totalVolunteers,
  int? registrationNumber,
  int? yearFounded,
  String? officeAddress,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'role': role,
      'photo_url': photoUrl,
      'latitude': latitude,
      'longitutde': longitutde,
      'city': city,
      'bio': bio,
      'uid': uid,
      'meals': meals,
      'funds': funds,
      'phone': phone,
      'total_volunteers': totalVolunteers,
      'registration_number': registrationNumber,
      'year_founded': yearFounded,
      'office_address': officeAddress,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.role == e2?.role &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.latitude == e2?.latitude &&
        e1?.longitutde == e2?.longitutde &&
        e1?.city == e2?.city &&
        e1?.bio == e2?.bio &&
        e1?.uid == e2?.uid &&
        e1?.meals == e2?.meals &&
        e1?.funds == e2?.funds &&
        listEquality.equals(e1?.miscellaneous, e2?.miscellaneous) &&
        e1?.phone == e2?.phone &&
        e1?.totalVolunteers == e2?.totalVolunteers &&
        e1?.registrationNumber == e2?.registrationNumber &&
        e1?.yearFounded == e2?.yearFounded &&
        e1?.officeAddress == e2?.officeAddress;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.createdTime,
        e?.phoneNumber,
        e?.role,
        e?.photoUrl,
        e?.latitude,
        e?.longitutde,
        e?.city,
        e?.bio,
        e?.uid,
        e?.meals,
        e?.funds,
        e?.miscellaneous,
        e?.phone,
        e?.totalVolunteers,
        e?.registrationNumber,
        e?.yearFounded,
        e?.officeAddress
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
