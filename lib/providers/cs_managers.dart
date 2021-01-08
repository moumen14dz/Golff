import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/manager.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class CSManagers with ChangeNotifier {
  List<Manager> _csManagers = [
    // Manager(
    //   id: 0,
    //   code: '0001',
    //   name: 'احمد محمد',
    //   governorate: 'محافظة القاهرة',
    //   phoneNumber: '+201023843232',
    //   lat: 0,
    //   lon: 0,
    // ),
    // Manager(
    //   id: 1,
    //   code: '0002',
    //   name: 'احمد محمود',
    //   governorate: 'محافظة الجيزة',
    //   phoneNumber: '+201023843232',
    //   lat: 0,
    //   lon: 0,
    // ),
    // Manager(
    //   id: 2,
    //   code: '0003',
    //   name: 'احمد محمد',
    //   governorate: 'محافظة الغردقة',
    //   phoneNumber: '+201023843232',
    //   lat: 0,
    //   lon: 0,
    // ),
  ];

  Future<void> getCSManagers() async {
    try {
      const String url = '$API_URL/getCSManagers';
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      _csManagers = decodedResponseBody.map((item) {
        return Manager(
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

  List<Manager> get csManagers {
    return [..._csManagers];
  }
}
