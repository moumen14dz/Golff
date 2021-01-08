import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/district.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Districts with ChangeNotifier {
  List<District> _districts = [];
  List<District> _tempDistricts;

  List<District> get districts {
    return _districts;
  }

  List<District> get tempDistricts {
    return _tempDistricts;
  }

  Future<void> getDistricts([int govId, bool hasInternet = true]) async {
    try {
      const String url = '$API_URL/districts';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      Response response;
      List<dynamic> decodedResponseBody;
      if (hasInternet) {
        // With internet Connection
        response = await get(url);
        decodedResponseBody = json.decode(response.body) as List<dynamic>;
        await prefs.setString('districtsResponse', response.body);
        _tempDistricts = decodedResponseBody.map((district) {
          return District(
            id: district['id'],
            govId: district['govId'],
            title: district['title'],
          );
        }).toList();
        if (govId != null) {
          _districts = _tempDistricts.where((district) {
            return district.govId == govId;
          }).toList();
        } else {
          _districts = _tempDistricts;
        }

        print('Has Internet Connection');
      } else {
        // Without internet Connection
        decodedResponseBody = json.decode(prefs.getString('districtsResponse'));
        _tempDistricts = decodedResponseBody.map((district) {
          return District(
            id: district['id'],
            govId: district['govId'],
            title: district['title'],
          );
        }).toList();
        if (govId != null) {
          _districts = _tempDistricts.where((district) {
            return district.govId == govId;
          }).toList();
        } else {
          _districts = _tempDistricts;
        }
        print('Without Internet Connection');
      }
      print(decodedResponseBody);

      print('id: ' + _districts.first.id.toString());
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }
}
