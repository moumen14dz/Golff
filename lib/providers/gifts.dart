import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/gift.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Gifts with ChangeNotifier {
  final int _userID;

  Gifts(this._userID);

  List<Gift> _gifts = [];

  List<Gift> get gifts {
    return _gifts;
  }

  Future<void> getGifts() async {
    const String url = '$API_URL/getMerchantsDistGiftsList';
    try {
      Response response = await get(url);
      final List<dynamic> decodedResponseBody = json.decode(response.body);
      _gifts = decodedResponseBody
          .map((item) => Gift(id: item['id'], title: item['title']))
          .toList();
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  Future<String> sendGift({
    int giftId,
    int merchantDistId,
    int type,
    String notes,
  }) async {
    const String url = '$API_URL/sendGiftToMerchantOrDist';
    Response response = await post(url, body: {
      'giftId': giftId.toString(),
      'merchantDistId': merchantDistId.toString(),
      'type': type.toString(),
      'notes': notes,
      'userId': _userID.toString(),
    });
    print('response success: ${json.decode(response.body)}');
    return json.decode(response.body)['message'];
  }
}
