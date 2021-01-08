import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/sales_agent.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class SalesAgents with ChangeNotifier {
  List<SalesAgent> _salesAgents = [];

  List<SalesAgent> get salesAgents {
    return [..._salesAgents];
  }

  Future<void> getSalesAgents() async {
    try {
      const String url = '$API_URL/getSalesAgents';
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      _salesAgents = decodedResponseBody.map((item) {
        return SalesAgent(
          id: item['id'],
          name: item['name'],
          governorate: item['governorate'],
          code: item['code'],
          lon: item['lon'],
          lat: item['lat'],
          phoneNumber: item['phoneNumber'],
        );
      }).toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }
}
