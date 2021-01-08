import 'package:flutter/foundation.dart';

class Merchant {
  int id;
  String code;
  String shopName;
  String merchantName;
  String respName;
  String telephoneNumber;
  double lat;
  double lon;
  String address;
  int categoryId;

  Merchant({
    @required this.id,
    @required this.code,
    @required this.shopName,
    @required this.merchantName,
    @required this.respName,
    @required this.lat,
    @required this.lon,
    @required this.telephoneNumber,
    @required this.categoryId,
    this.address,
  });
}

class MerchantCat {
  final int id;
  final String title;

  MerchantCat({
    this.id,
    this.title,
  });
}

class DistributorType {
  final int id;
  final String title;

  DistributorType({
    this.id,
    this.title,
  });
}
