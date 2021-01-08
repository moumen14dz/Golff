import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/visit.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Visits with ChangeNotifier {
  final int _userId;

  Visits(this._userId);

  List<VisitTypeMenu> _visitsType = [];
  List<VisitResultMenu> _visitsResult = [];

  List<VisitTypeMenu> get visitsType {
    return _visitsType;
  }

  List<VisitResultMenu> get visitsResult {
    return _visitsResult;
  }

  Future<void> getVisitsType() async {
    const String url = '$API_URL/getMerchantsDistVisitTypesLists';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      _visitsType = decodedResponseBody
          .map((item) => VisitTypeMenu(id: item['id'], title: item['title']))
          .toList();
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<void> getVisitsResult() async {
    const String url = '$API_URL/getMerchantsDistVisitResultsList';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      _visitsResult = decodedResponseBody
          .map((item) => VisitResultMenu(id: item['id'], title: item['title']))
          .toList();
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<String> sendVisit(
      {VisitTypeMenu visitTypeMenu,
      VisitResultMenu visitResultMenu,
      int merchantDistId,
      int type,
      String desc}) async {
    const String url = '$API_URL/storeVisitMerchantOrDist';
    try {
      Response response = await post(url, body: {
        'visitTypeId': visitTypeMenu.id.toString(),
        'visitResultId': visitResultMenu.id.toString(),
        'merchantDistId': merchantDistId.toString(),
        'visitDescr': desc,
        'type': type.toString(),
        'userId': _userId.toString(),
      });
      final decodedResponseBody = json.decode(response.body);
      print('decodedResponseBody: $decodedResponseBody');
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      throw error.toString();
    }
  }
}
