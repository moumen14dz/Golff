import 'package:flutter/foundation.dart';

class Category {
  int id;
  String name;
  List<Product> products;

  Category({
    this.id,
    this.name,
    this.products,
  });
}

class Product {
  int id;
  String name;
  String mainPrice;
  Coupon coupon;
  var points;
  int amount;

  Product({
    this.name,
    this.id,
    this.coupon,
    this.mainPrice,
    this.points,
    this.amount = 0,
  });
}

class Coupon {
  int id;
  String name;
  String price;
  String color;

  Coupon({
    @required this.id,
    @required this.name,
    @required this.price,
    @required this.color,
  });
}
