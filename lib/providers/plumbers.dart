import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/credit.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/models/plumber_bill.dart';
import 'package:golf/models/plumber_gift.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Plumbers with ChangeNotifier {
  final int _userId;

  Plumbers(this._userId);

  List<Plumber> _plumbers = [];
  List<Credit> _credits = [];
  List<PlumberBill> _plumberBills = [];
  List<PlumberGift> _plumberGifts = [];
  List<int> _plumberGiftsCount = [];

  List<PlumberBill> get plumberBills {
    return _plumberBills;
  }

  List<Plumber> get plumbers {
    return [..._plumbers];
  }

  List<Credit> get credits {
    return _credits;
  }

  List<PlumberGift> get plumberGifts {
    return _plumberGifts;
  }

  List<int> get plumberGiftsCount {
    return _plumberGiftsCount;
  }

  bool hasGifts() {
    return _plumberGifts.isNotEmpty;
  }

  Future<void> getPlumbers(
      [giftsCountEnabled = true, bool hasInternet = true]) async {
    final String url = '$API_URL/getPlumbers/$_userId';
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Response response;
      List<dynamic> decodedResponseBody;

      if (hasInternet) {
        // With internet Connection
        print('Has Internet Connection');
        response = await get(url);
        decodedResponseBody = json.decode(response.body) as List<dynamic>;
        await prefs.setString('plumbersResponse', response.body);
      } else {
        // Without internet Connection
        decodedResponseBody = json.decode(prefs.getString('plumbersResponse'));
        print('Without Internet Connection');
      }
      print(decodedResponseBody.toString());
      _plumbers = decodedResponseBody
          .map((item) => Plumber(
                id: item['id'],
                code: item['code'],
                plumberName: item['plumberName'],
                nationalId: item['nationalId'],
                plumberPhone: item['telephoneNumber'],
                governorate: item['governorate'],
                points: item['points'],
                giftsCount: item['giftsCount'],
              ))
          .toList();
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw (error.toString());
    }
  }

  String findPlumberNameById(int id) {
    return _plumbers.firstWhere((plumber) => plumber.id == id).plumberName;
  }

  String findPlumberPhoneById(int id) {
    return _plumbers.firstWhere((plumber) => plumber.id == id).plumberPhone;
  }

  Future<void> getCredits(int plumberId) async {
    final String url = '$API_URL/getPlumberCredit/$plumberId';
    Response response = await get(url);
    final decodedResponseBody = json.decode(response.body) as List<dynamic>;
    print(decodedResponseBody.toString());
    _credits = decodedResponseBody
        .map((credit) => Credit(
              title: credit['title'],
              value: credit['value'],
            ))
        .toList();
    notifyListeners();
  }

  Future<void> getBills(int plumberId) async {
    final String url = '$API_URL/getPlumberBills/$plumberId';
    Response response = await get(url);
    final decodedResponseBody = json.decode(response.body) as List<dynamic>;
    print(decodedResponseBody.toString());
    _plumberBills = decodedResponseBody
        .map((bill) => PlumberBill(
              id: bill['id'],
              date: bill['date'],
              clientName: bill['clientName'],
              billNumber: bill['billNumber'],
              merchantName: bill['merchantName'],
              reward: bill['reward'],
            ))
        .toList();
    notifyListeners();
  }

  Future<void> getGifts(int plumberId) async {
    final String url = '$API_URL/getSuggestedPlumberGifts/$plumberId';
    try {
      Response response = await get(url);
      final decodedResponseBody = json.decode(response.body) as List<dynamic>;
      print(decodedResponseBody.toString());
      _plumberGifts = decodedResponseBody.map((item) {
        return PlumberGift(
          id: item['id'].toString(),
          giftName: item['GiftName'].toString(),
          giftPoints: item['GiftPoints'].toString(),
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      print(error.toString());
    }
  }

  // Future<void> getGiftsCount([bool hasInternet = true]) async {
  //   String url;
  //   try {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     Response response;
  //     List<dynamic> decodedResponseBody;
  //     if (hasInternet) {
  //       response = await get(url);
  //       decodedResponseBody = json.decode(response.body);
  //
  //       print('online plumber id: ' + i.id.toString());
  //       url = '$API_URL/getSuggestedPlumberGifts/${i.id}';
  //       response = await get(url);
  //       decodedResponseBody = json.decode(response.body);
  //       await prefs.setString('giftsCountResponse${i.id}', response.body);
  //       _plumberGiftsCount.add(decodedResponseBody.length);
  //     } else {
  //       // Without Internet
  //       for (Plumber i in _plumbers) {
  //         print('offline plumber id: ' + i.id.toString());
  //         decodedResponseBody =
  //             json.decode(prefs.getString('giftsCountResponse${i.id}'));
  //         print('gifts count: ' + decodedResponseBody.toString());
  //         _plumberGiftsCount.add(decodedResponseBody.length);
  //       }
  //     }
  //     notifyListeners();
  //   } catch (error) {
  //     print(error.toString());
  //   }
  // }

  Future<String> sendGift({
    int plumberId,
    String notes,
    String image,
    String giftId,
  }) async {
    const String url = '$API_URL/sendPlumberGift';
    try {
      Response response = await post(url, body: {
        'PlumberId': plumberId.toString(),
        'notes': notes,
        'image': image,
        'authId': _userId.toString(),
        'giftId': giftId,
      });
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      notifyListeners();
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      return 'خطأ';
    }
  }

  Future<String> addPlumber({
    Plumber plumber,
    String address,
    int governorateId,
    String nIdImage,
  }) async {
    const String url = '$API_URL/storePlumber';
    try {
      Response response = await post(url, body: {
        'name': plumber.plumberName,
        'phone': plumber.plumberPhone,
        'nId': plumber.nationalId,
        'authId': _userId.toString(),
        'address': address,
        'governorateId': governorateId.toString(),
        'nIdImage': nIdImage,
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
