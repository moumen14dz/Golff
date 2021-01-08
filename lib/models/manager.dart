import 'package:flutter/foundation.dart';

class Manager {
  final int id;
  final String name;
  final String governorate;
  final String code;
  final double lon;
  final double lat;
  final String phoneNumber;

  Manager({
    this.id,
    this.name,
    this.governorate,
    this.code,
    this.lon,
    this.lat,
    this.phoneNumber,
  });
}
