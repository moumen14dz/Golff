import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf/exceptions/current_location_exception.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';

class Locations with ChangeNotifier {
  final int userId;
  double lon;
  double lat;

  Locations(this.userId);

  Future<void> sendGPSLocation() async {
    try {
      const String url = '$API_URL/sendGPSLocation';
      var position2 = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      Position position = position2;
      lon = position.longitude;
      lat = position.latitude;
      Response response = await post(url, body: {
        'lon': lon.toString(),
        'lat': lat.toString(),
        'userId': userId.toString(),
      });
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
    } catch (error) {
      print(error.toString());
    }
  }

  Future<String> sendMerchantGPSLocation(
      double lon, double lat, merchantId) async {
    try {
      const String url = '$API_URL/updateMerchantLocation';
      Response response = await post(url,
          body: json.encode({
            'lon': lon,
            'lat': lat,
            'merchantId': merchantId,
            'authId': userId,
          }),
          headers: {
            "Accept": "application/json",
            'Content-type': 'application/json',
          });
      if (response.statusCode >= 400) {
        throw CurrentLocationException('Error');
      }
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      return decodedResponseBody['message'];
    } catch (error) {
      print(error.toString());
      throw (error.toString());
    }
  }
}
