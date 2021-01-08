import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/customer_services_agent.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class CustomerServicesAgents with ChangeNotifier {
  List<CustomerServicesAgent> _customerServicesAgents = [];

  List<CustomerServicesAgent> get customerServicesAgents {
    return [..._customerServicesAgents];
  }

  Future<void> getCSAgents() async {
    try {
      const String url = '$API_URL/getCSAgents';
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      _customerServicesAgents = decodedResponseBody.map((item) {
        return CustomerServicesAgent(
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
