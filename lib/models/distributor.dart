import 'package:flutter/foundation.dart';

class Distributor {
  var id;
  var code;
  var shopName;
  var distributorName;
  var respName;
  var telephoneNumber;
  var lat;
  var lon;
  var address;
  var categoryId;

  Distributor({
    @required this.id,
    @required this.code,
    @required this.shopName,
    @required this.distributorName,
    @required this.respName,
    @required this.lat,
    @required this.lon,
    @required this.telephoneNumber,
    @required this.address,
    @required this.categoryId,
  });
}

class DistributorCat {
  final int id;
  final String title;

  DistributorCat({
    this.id,
    this.title,
  });
}
