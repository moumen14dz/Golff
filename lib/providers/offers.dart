import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/models/offer.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Offers with ChangeNotifier {
  List<Offer> _offers = [
    // Offer(
    //   type: 0,
    //   body: 'خصم 10 بالمئة على مبيعات البولى',
    //   startDate: '1/8/2019',
    //   endDate: '10/8/2019',
    // ),
    // Offer(
    //   type: 1,
    //   body: 'تحقيق 100 بالمئة من المبيعات تحقيق 100 بالمئة من المبيعات',
    //   startDate: '1/8/2019',
    //   endDate: '10/8/2019',
    // ),
    // Offer(
    //   type: 0,
    //   body: 'تحتسب 110 بالمئة من العمولة',
    //   startDate: '1/8/2019',
    //   endDate: '10/8/2019',
    // ),
  ];

  List<Offer> get offers {
    return [..._offers];
  }

  Future<void> getOffers() async {
    const String url = '$API_URL/getOffers';
    Response response = await get(url);
    final decodedResponseBody = json.decode(response.body) as List<dynamic>;
    print(decodedResponseBody.toString());
    _offers = decodedResponseBody
        .map((item) => Offer(
            type: item['type'],
            body: item['body'],
            startDate: item['startDate'],
            endDate: item['endDate']))
        .toList();
    notifyListeners();
  }
}
