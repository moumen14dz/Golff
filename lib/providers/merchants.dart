import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Merchants with ChangeNotifier {
  int _userId;

  Merchants(this._userId);

  double lon;
  double lat;
  List<Merchant> _merchants = [];
  List<MerchantCat> _merchantCat = [];
  List<DistributorType> _distributorTypes = [
    DistributorType(id: 0, title: 'بدون موزع'),
  ];

  List<Merchant> get merchants {
    return [..._merchants];
  }

  List<MerchantCat> get merchantCat {
    return _merchantCat;
  }

  List<DistributorType> get distributorTypes {
    return _distributorTypes;
  }

  Future<void> getMerchants([bool hasInternet = true]) async {
    final String url = '$API_URL/getMerchants/$_userId';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Response response;
      List<dynamic> decodedResponseBody;
      if (hasInternet) {
        // With internet Connection
        response = await get(url);
        decodedResponseBody = json.decode(response.body) as List<dynamic>;
        await prefs.setString('merchantsResponse', response.body);
        print('Has Internet Connection');
      } else {
        // Without internet Connection
        decodedResponseBody = json.decode(prefs.getString('merchantsResponse'));
        print('Without Internet Connection');
      }
      print(decodedResponseBody.toString());
      _merchants = decodedResponseBody
          .map((item) => Merchant(
                id: item['id'],
                code: item['code'],
                shopName: item['shopName'],
                merchantName: item['merchantName'],
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
      print('merchants catch error: ' + error.toString());
      throw (error.toString());
    }
  }

  Future<void> getMerchantCat() async {
    const String url = '$API_URL/getMerchantCats';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      _merchantCat = decodedResponseBody
          .map((item) => MerchantCat(
                id: item['id'],
                title: item['title'],
              ))
          .toList();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<void> getDistributorType() async {
    final String url = '$API_URL/getDists/$_userId';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      print('dist response: ' + decodedResponseBody.toString());
      List<DistributorType> tempList = [];
      tempList = decodedResponseBody
          .map((item) => DistributorType(
                id: item['id'],
                title: item['distributorName'],
              ))
          .toList();
      _distributorTypes.addAll(tempList);
      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  Future<String> addMerchant(Merchant merchant, int distId) async {
    const String url = '$API_URL/storeMerchant';
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      lon = position.longitude;
      lat = position.latitude;
      print(lon);
      print(lat);
      Response response = await post(url, body: {
        'shopName': merchant.shopName,
        'merchantName': merchant.merchantName,
        'respName': merchant.respName,
        'telephoneNumber': merchant.telephoneNumber,
        'lat': lat.toString(),
        'lon': lon.toString(),
        'address': merchant.address,
        'categoryId': merchant.categoryId.toString(),
        'distId': distId.toString(),
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

  String findMerchantNameById(int id) {
    try {
      return _merchants
          .firstWhere((merchant) => merchant.id == id)
          .merchantName;
    } catch (error) {
      return '';
    }
  }

  String findMerchantPhoneById(int id) {
    try {
      return _merchants
          .firstWhere((merchant) => merchant.id == id)
          .telephoneNumber;
    } catch (error) {
      return '';
    }
  }
}
