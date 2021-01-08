import 'package:golf/models/location.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/models/product.dart';

class Bill {
  int id;

  List<Product> products;

  String code;

  String clientName;
  String clientPhone;

  int merchantId;
  String merchantName;
  String merchantPhone;

  int plumberId;
  String plumberName;
  String plumberPhone;

  String address;
  String date;

  String billNumber;

  int governorateId;
  int districtId;

  String governorate;

  String totalAmount;
  String reward;

  double lat;
  double lon;

  int elevatorsCount;
  int bathroomsCount;
  int kitchensCount;

  Location currentLocation;

  bool isSent;

  // TODO: Add video property

  Bill({
    this.id,
    this.clientName,
    this.clientPhone,
    this.merchantId,
    this.merchantName,
    this.merchantPhone,
    this.address,
    this.date,
    this.billNumber,
    this.governorateId,
    this.districtId,
    this.elevatorsCount,
    this.bathroomsCount,
    this.kitchensCount,
    this.currentLocation,
    this.governorate,
    this.code,
    this.totalAmount,
    this.reward,
    this.lat,
    this.lon,
    this.isSent = false,
    this.products,
    this.plumberId,
    this.plumberName,
    this.plumberPhone,
  });
}
