import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderEmail;
  final String receiverID;
  final String senderID;
  final String message;
  final Timestamp timestamp;

  Message(
      {required this.senderEmail,
      required this.receiverID,
      required this.senderID,
      required this.message,
      required this.timestamp});

// convert to a map

  Map<String, dynamic> toMap() {
    return {
      "senderEmail": senderEmail,
      "receiverID": receiverID,
      "senderID": senderID,
      "message": message,
      "timestamp": timestamp,
    };
  }
}
