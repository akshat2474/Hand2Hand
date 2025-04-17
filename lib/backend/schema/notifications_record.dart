import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '../../stylings/stylings_util.dart';

class NotificationsRecord extends FirestoreRecord {
  NotificationsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "recipientID" field.
  String? _recipientID;
  String get recipientID => _recipientID ?? '';
  bool hasRecipientID() => _recipientID != null;

  // "recipientName" field.
  String? _recipientName;
  String get recipientName => _recipientName ?? '';
  bool hasRecipientName() => _recipientName != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  bool hasMessage() => _message != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "senderID" field.
  String? _senderID;
  String get senderID => _senderID ?? '';
  bool hasSenderID() => _senderID != null;

  // "senderName" field.
  String? _senderName;
  String get senderName => _senderName ?? '';
  bool hasSenderName() => _senderName != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "isRead" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "notifiedNGOs" field.
  List<String>? _notifiedNGOs;
  List<String> get notifiedNGOs => _notifiedNGOs ?? const [];
  bool hasNotifiedNGOs() => _notifiedNGOs != null;

  void _initializeFields() {
    _recipientID = snapshotData['recipientID'] as String?;
    _recipientName = snapshotData['recipientName'] as String?;
    _message = snapshotData['message'] as String?;
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _senderID = snapshotData['senderID'] as String?;
    _senderName = snapshotData['senderName'] as String?;
    _type = snapshotData['type'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _isRead = snapshotData['isRead'] as bool?;
    _status = snapshotData['status'] as String?;
    _notifiedNGOs = getDataList(snapshotData['notifiedNGOs']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('notifications');

  static Stream<NotificationsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NotificationsRecord.fromSnapshot(s));

  static Future<NotificationsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NotificationsRecord.fromSnapshot(s));

  static NotificationsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      NotificationsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static NotificationsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      NotificationsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NotificationsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNotificationsRecordData({
  String? recipientID,
  String? recipientName,
  String? message,
  DateTime? timestamp,
  String? senderID,
  String? senderName,
  String? type,
  LatLng? location,
  bool? isRead,
  String? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'recipientID': recipientID,
      'recipientName': recipientName,
      'message': message,
      'timestamp': timestamp,
      'senderID': senderID,
      'senderName': senderName,
      'type': type,
      'location': location,
      'isRead': isRead,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class NotificationsRecordDocumentEquality
    implements Equality<NotificationsRecord> {
  const NotificationsRecordDocumentEquality();

  @override
  bool equals(NotificationsRecord? e1, NotificationsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.recipientID == e2?.recipientID &&
        e1?.recipientName == e2?.recipientName &&
        e1?.message == e2?.message &&
        e1?.timestamp == e2?.timestamp &&
        e1?.senderID == e2?.senderID &&
        e1?.senderName == e2?.senderName &&
        e1?.type == e2?.type &&
        e1?.location == e2?.location &&
        e1?.isRead == e2?.isRead &&
        e1?.status == e2?.status &&
        listEquality.equals(e1?.notifiedNGOs, e2?.notifiedNGOs);
  }

  @override
  int hash(NotificationsRecord? e) => const ListEquality().hash([
        e?.recipientID,
        e?.recipientName,
        e?.message,
        e?.timestamp,
        e?.senderID,
        e?.senderName,
        e?.type,
        e?.location,
        e?.isRead,
        e?.status,
        e?.notifiedNGOs
      ]);

  @override
  bool isValidKey(Object? o) => o is NotificationsRecord;
}
