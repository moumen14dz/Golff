import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/governorate.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Governorates with ChangeNotifier {
  List<Governorate> _governorates = [];

  List<Governorate> get governorates {
    return _governorates;
  }

  Future<void> getGovernorates([bool hasInternet = true]) async {
    const String url = '$API_URL/governorates';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Response response;
      List<dynamic> decodedResponseBody;
      if (hasInternet) {
        // With internet Connection
        response = await get(url);
        decodedResponseBody = json.decode(response.body) as List<dynamic>;
        await prefs.setString('governoratesResponse', response.body);
        print('Has Internet Connection');
      } else {
        // Without internet Connection
        decodedResponseBody =
            json.decode(prefs.getString('governoratesResponse'));
        print('Without Internet Connection Governorate');
      }
      _governorates = decodedResponseBody
          .map((item) => Governorate(
                id: item['id'],
                name: item['title'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print('Catch error: ' + error.toString());
      throw (error.toString());
    }
  }
}
