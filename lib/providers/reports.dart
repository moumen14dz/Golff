import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/utils/constants.dart';
import 'package:http/http.dart';

class Reports with ChangeNotifier {
  final int _authId;

  Reports(this._authId);

  Future<String> sendReport(String title, String description, int id) async {
    const String url = '$API_URL/sendUserReport';
    try {
      Response response = await post(url, body: {
        'title': title,
        'description': description,
        'userId': id.toString(),
        'authId': _authId.toString(),
      });
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody['message']);
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      return 'خطأ فى الإرسال';
    }
  }
}
