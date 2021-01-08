import 'package:flutter/foundation.dart';

class CustomerServicesAgent {
  int id;
  String name;
  String governorate;
  String code;
  double lon;
  double lat;
  String phoneNumber;

  CustomerServicesAgent({
    @required this.id,
    @required this.name,
    @required this.governorate,
    @required this.code,
    @required this.lon,
    @required this.lat,
    @required this.phoneNumber,
  });
}
