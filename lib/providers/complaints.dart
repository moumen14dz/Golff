import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/complaint.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Complaints with ChangeNotifier {
  final int _userId;

  Complaints(this._userId);

  List<Complaint> _complaints = [];
  List<ComplaintMessage> _complaintMessages = [];
  List<User> _users = [];

  List<Complaint> get complaints {
    return _complaints;
  }

  List<User> get users {
    return _users;
  }

  List<ComplaintMessage> get complaintMessages {
    return _complaintMessages;
  }

  Future<void> getComplaints() async {
    try {
      Response response = await get(
        '$API_URL/getComplaintsRequests/$_userId',
        headers: {"Accept": "application/json"},
      );
      List<dynamic> decodedResponseBody = json.decode(response.body);
      print('Complaints: ' + decodedResponseBody.toString());
      _complaints = decodedResponseBody
          .map((complaint) => Complaint(
                id: complaint['id'],
                title: complaint['title'],
                createdBy: complaint['createdBy'],
                createdTo: complaint['createdTo'],
                type: complaint['type'],
                date: complaint['date'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }

  Future<void> getUsers() async {
    try {
      Response response = await get(
        '$API_URL/getComplaintsRequestUsers',
        headers: {"Accept": "application/json"},
      );
      List<dynamic> decodedResponseBody = json.decode(response.body);
      print('users: ' + decodedResponseBody.toString());
      _users = decodedResponseBody
          .map((user) => User(
                id: user['id'],
                name: user['name'],
                phone: user['phone'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }

  Future<void> getComplaintMessages() async {
    try {
      Response response = await get(
        '$API_URL/getComplaintsRequestsMessages/$_userId',
        headers: {"Accept": "application/json"},
      );
      List<dynamic> decodedResponseBody = json.decode(response.body);
      print('complaint messages: ' + decodedResponseBody.toString());
      _complaintMessages = decodedResponseBody
          .map((message) => ComplaintMessage(
                id: message['id'],
                createdBy: message['createdBy'],
                text: message['text'],
                date: message['date'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }

  Future<String> sendComplaint(
      String title, int requestType, int userId, String message) async {
    try {
      Response response = await post(
        '$API_URL/storeNewComplaintsRequests',
        body: json.encode({
          'title': title,
          'authId': _userId,
          'requestType': requestType,
          'toUserId': userId,
          'message': message,
        }),
        headers: {
          "Accept": "application/json",
          'Content-type': 'application/json',
        },
      );
      Map<String, dynamic> decodedResponseBody = json.decode(response.body);
      print('sent complaints: ' + decodedResponseBody.toString());
      notifyListeners();
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }

  Future<String> sendComplaintMessage(int complaintId, String message) async {
    try {
      Response response = await post(
        '$API_URL/ReplyOnComplaintRequest',
        body: json.encode({
          'complaintRequestId': complaintId,
          'message': message,
          'authId': _userId,
        }),
        headers: {
          "Accept": "application/json",
          'Content-type': 'application/json',
        },
      );
      Map<String, dynamic> decodedResponseBody = json.decode(response.body);
      print('sent message: ' + decodedResponseBody.toString());
      notifyListeners();
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }
}
