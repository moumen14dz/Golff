import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf/models/distributor.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Distributors with ChangeNotifier {
  int _userId;
  double lon;
  double lat;

  Distributors(this._userId);

  List<Distributor> _distributors = [];
  List<DistributorCat> _distributorCat = [];

  List<Distributor> get distributors {
    return [..._distributors];
  }

  List<DistributorCat> get distributorCat {
    return _distributorCat;
  }

  Future<void> getDistributors() async {
    final String url = '$API_URL/getDists/$_userId';
    try {
      Response response = await get(url);
      final decodedResponseBody = json.decode(response.body) as List<dynamic>;
      print('distributors response: ' + decodedResponseBody.toString());
      _distributors = decodedResponseBody
          .map((item) => Distributor(
                id: item['id'],
                code: item['code'],
                shopName: item['shopName'],
                distributorName: item['distributorName'],
                respName: item['respName'],
                lat: item['lat'],
                lon: item['lon'],
                telephoneNumber: item['telephoneNumber'],
                categoryId: item['categoryId'],
                address: item['address'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> getDistributorCat() async {
    const String url = '$API_URL/getDistCats';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      _distributorCat = decodedResponseBody
          .map((item) => DistributorCat(
                id: item['id'],
                title: item['title'],
              ))
          .toList();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<String> addDistributor(Distributor distributor, int distId) async {
    const String url = '$API_URL/storeDist';
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      lon = position.longitude;
      lat = position.latitude;
      print(lon);
      print(lat);
      Response response = await post(url, body: {
        'shopName': distributor.shopName,
        'distName': distributor.distributorName,
        'respName': distributor.respName,
        'telephoneNumber': distributor.telephoneNumber,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'address': distributor.address,
        'categoryId': distId.toString(),
      });
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody);

      notifyListeners();
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }
}
