import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/bill.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Bills with ChangeNotifier {
  int _userId;

  Bills(this._userId);

  List<Bill> _bills = [];

  List<Bill> get bills {
    return [..._bills];
  }

  Future<void> getBills() async {
    try {
      final String url = '$API_URL/getbills/$_userId';
      Response response = await get(url);
      final decodedResponseBody = json.decode(response.body) as List<dynamic>;
      print(decodedResponseBody.toString());
      _bills = decodedResponseBody
          .map((bill) => Bill(
                id: bill['id'],
                code: bill['code'],
                date: bill['date'],
                merchantName: bill['merchantName'],
                merchantPhone: bill['merchantPhone'],
                plumberName: bill['plumberName'],
                plumberPhone: bill['plumberPhone'],
                address: bill['address'],
                governorate: bill['governorate'],
                lat: bill['lat'],
                lon: bill['lon'],
                totalAmount: bill['totalAmount'],
                reward: bill['reward'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }
}
