import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/order.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Orders with ChangeNotifier {
  final int _userId;

  Orders(this._userId);

  List<Order> _orders = [];

  List<Order> get orders {
    return _orders;
  }

  Future<String> sendOrder({Order order, int merchantDistId, int type}) async {
    const String url = '$API_URL/sendOrderToMerchantOrDist';
    print('Coming type: $type');
    try {
      Response response = await post(url, body: {
        'amount': order.amount.toString(),
        'merchantDistId': merchantDistId.toString(),
        'type': type.toString(),
        'image': order.image,
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
