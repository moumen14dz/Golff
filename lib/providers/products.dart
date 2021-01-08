import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:geolocator/geolocator.dart';
import 'package:golf/db_helper/DBHelper.dart';
import 'package:golf/exceptions/products_exception.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/models/product.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Products with ChangeNotifier {
  final int userId;

  int eachCouponCount;
  double newRest;
  List<dynamic> rest = [];

  bool _disposed = false;

  List<Map<String, dynamic>> _notSentBills = [];

  Products({
    this.userId,
  });

  double lon;
  double lat;

  int billId = 0;
  String _billSuccessMessage = '';
  List<dynamic> _billSuccessReward = [];

  List<int> _couponsCount = [];

  // Key: coupon ID, Value: List of products that have the same coupon ID
  Map<int, List<Product>> _coupons = {};

  List<Category> _categories = [];

  String get billSuccessMessage {
    return _billSuccessMessage;
  }

  List<dynamic> get billSuccessReward {
    return _billSuccessReward;
  }

  List<int> get couponsCount {
    return _couponsCount;
  }

  List<Category> get categories {
    return _categories;
  }

  Map<int, List<Product>> get coupons {
    return _coupons;
  }

  List<Map<String, dynamic>> get notSentBills {
    return _notSentBills;
  }

  // @override
  // void dispose() {
  //   _disposed = true;
  //   super.dispose();
  // }
  //
  // @override
  // void notifyListeners() {
  //   if (!_disposed) {
  //     super.notifyListeners();
  //   }
  // }

  Future<void> getCategories([bool hasInternet = true]) async {
    try {
      final String url = '$API_URL/getProducts';
      SharedPreferences prefs = await SharedPreferences.getInstance();
      Response response;
      List<dynamic> decodedResponseBody;
      if (hasInternet) {
        // With internet Connection
        response = await get(url);
        decodedResponseBody = json.decode(response.body) as List<dynamic>;
        await prefs.setString('categoriesResponse', response.body);
        print('Has Internet Connection');
      } else {
        // Without internet Connection
        decodedResponseBody =
            json.decode(prefs.getString('categoriesResponse'));
        print('Without Internet Connection');
      }
      print(decodedResponseBody.toString());
      _categories = decodedResponseBody
          .map((item) => Category(
                id: item['id'],
                name: item['CatName'].toString(),
                products: (item['items'] as List<dynamic>)
                    .map((product) => Product(
                          id: product['id'],
                          name: product['ProductName'].toString(),
                          mainPrice: product['mainPrice'].toString(),
                          points: product['points'],
                          coupon: Coupon(
                            id: product['couponId'],
                            price: product['couponPrice'].toString(),
                            name: product['couponName'].toString(),
                            color: product['couponColor'].toString(),
                          ),
                        ))
                    .toList(),
              ))
          .toList();
      print('notifier categories: ' + _categories.toString());
      notifyListeners();
    } catch (error) {
      print('products error: ' + error.toString());
      throw (error.toString());
    }
  }

  void addCoupons(List<Category> cat) {
    _coupons.clear();
    cat.forEach((category) {
      category.products.forEach((product) {
        if (product.amount != 0) {
          if (!_coupons.containsKey(product.coupon.id)) {
            _coupons.putIfAbsent(product.coupon.id, () => [product]);
          } else {
            _coupons.update(product.coupon.id, (value) => [...value, product]);
          }
        }
      });
    });
    _categories = cat;
    notifyListeners();
  }

  Future<void> sendBill(
      Map<String, dynamic> formData, List<String> images, List<File> videos,
      [bool hasInternet = true]) async {
    List<Product> selectedProducts = [];

    _categories.forEach((cat) {
      cat.products.forEach((prod) {
        if (prod.amount != 0) {
          selectedProducts.add(prod);
        }
      });
    });
    try {
      const String url = '$API_URL/postBill';
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      lon = position.longitude;
      lat = position.latitude;
      print(lon);
      print(lat);
      if (hasInternet) {
        // With internet Connection
        print('Has Internet Connection');
        Response response = await post(
          url,
          body: {
            'authId': userId.toString(),
            'clientName': formData['clientName'],
            'clientPhone': formData['clientPhone'],
            'merchantId': (formData['merchant'] as Merchant).id.toString(),
            'plumberId': (formData['plumber'] as Plumber).id.toString(),
            'govId': formData['governorateId'].toString(),
            'districtId': formData['districtId'].toString(),
            'billNumber': formData['billNumber'].toString(),
            'address': formData['address'],
            'bathCount': formData['bathrooms'].toString(),
            'kitchenCount': formData['kitchens'].toString(),
            'elevatorCount': formData['elevators'].toString(),
            'lon': lon.toString(),
            'lat': lat.toString(),
            'products': selectedProducts
                .map((product) => {
                      'id': product.id.toString(),
                      'amount': product.amount.toString(),
                    })
                .toList()
                .toString(),
          },
          headers: {"Accept": "application/json"},
        );
        final decodedResponseBody = json.decode(response.body);
        if (response.statusCode >= 400) {
          print(decodedResponseBody.toString());
          throw ProductsException(decodedResponseBody['message']);
        }
        print('bill sent successfully: ' + decodedResponseBody.toString());
        _billSuccessMessage = decodedResponseBody['message'];
        _billSuccessReward = decodedResponseBody['reward'];
        billId = decodedResponseBody['bill_id'];
        await saveRestPrefs();
        await sendMediaBill(
          billId,
          images,
          videos,
        );
      } else {
        // Without internet Connection
        print('Without Internet Connection');
        Map<String, dynamic> notSentBill = {
          'authId': userId.toString(),
          'clientName': formData['clientName'],
          'clientPhone': formData['clientPhone'],
          'merchantId': (formData['merchant'] as Merchant).id.toString(),
          'plumberId': (formData['plumber'] as Plumber).id.toString(),
          'govId': formData['governorateId'].toString(),
          'districtId': formData['districtId'].toString(),
          'billNumber': formData['billNumber'].toString(),
          'address': formData['address'],
          'bathCount': formData['bathrooms'].toString(),
          'kitchenCount': formData['kitchens'].toString(),
          'elevatorCount': formData['elevators'].toString(),
          'lon': lon.toString(),
          'lat': lat.toString(),
          'products': selectedProducts
              .map((product) => {
                    'id': product.id.toString(),
                    'amount': product.amount.toString(),
                  })
              .toList()
              .toString(),
        };
        DBHelper.insertDBData(DBHelper.BILL_TABLE_NAME, {
          DBHelper.BILL_CONTENT_COL: json.encode(notSentBill),
          DBHelper.BILL_IMAGES_COL: json.encode(images),
          DBHelper.BILL_VIDEOS_COL:
              json.encode(videos.map((file) => file.path).toList()),
        });
        await saveRestPrefs();
      }
      notifyListeners();
    } catch (error) {
      print('send bill catch error: ' + error.toString());
      throw error.toString();
    }
  }

  Future<void> sendMediaBill(
      int billId, List<dynamic> images, List<dynamic> videoPaths) async {
    try {
      const String url = '$API_URL/sendBillDocs';
      Response response = await post(url, body: {
        'bill_id': billId.toString(),
        'images': images
            .map((img) => {
                  'img64': img.toString(),
                })
            .toList()
            .toString(),
        'videos': videoPaths
            .map((vid) => {
                  'vidFilePath': vid.toString(),
                })
            .toList()
            .toString(),
      });
      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody);
    } catch (error) {
      print('sendMediaBill catch error: ' + error.toString());
    }
  }

  Future<void> sendSavedBills(
    Map<String, dynamic> data,
    int id,
    List<dynamic> encodedImages,
    List<dynamic> videoPaths,
    int index,
  ) async {
    try {
      List<Product> selectedProducts = [];

      _categories.forEach((cat) {
        cat.products.forEach((prod) {
          if (prod.amount != 0) {
            selectedProducts.add(prod);
          }
        });
      });
      const String url = '$API_URL/postBill';
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      lon = position.longitude;
      lat = position.latitude;
      print(lon);
      print(lat);
      Response response = await post(url, body: data);
      final decodedResponseBody = json.decode(response.body);
      _billSuccessMessage = decodedResponseBody['message'];
      _billSuccessReward = decodedResponseBody['reward'];
      billId = decodedResponseBody['bill_id'];
      print('saved bill: ' + decodedResponseBody.toString());
      await sendMediaBill(billId, encodedImages, videoPaths);
      await DBHelper.deleteRow(DBHelper.BILL_TABLE_NAME, id);
      notifyListeners();
    } catch (error) {
      print('send Saved Bills catch error: ' + error.toString());
      throw (error.toString());
    }
  }

  Future<void> getNotSentBills() async {
    try {
      _notSentBills = await DBHelper.getDBData(DBHelper.BILL_TABLE_NAME);
      print('got bills: ' + _notSentBills.toString());
      notifyListeners();
    } catch (error) {
      throw error.toString();
    }
  }

  String findCouponNameById(int id) {
    String couponName;
    _categories.forEach((cat) {
      cat.products.forEach((prod) {
        if (prod.coupon.id == id) {
          couponName = prod.coupon.name;
        }
      });
    });
    return couponName;
  }

  Future<void> couponsCountData(int couponId, double totalPrice) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double restAmount = 0;
    double couponPrice = 0;
    rest = json.decode(prefs.getString(PREFS_REST_LIST_KEY));
    Map<String, dynamic> restItem =
        rest.firstWhere((element) => element['copounId'] == couponId);
    restAmount = double.parse(restItem['rest']);
    couponPrice = double.parse(restItem['couponPrice']);
    print('zeft coupons count');
    if (couponPrice <= 0) {
      print('couponPrice <= 0');
      eachCouponCount = 0;
      return;
    } else {
      double totalCouponsCount =
          (restAmount + totalPrice) / couponPrice; // Total Value 54.32
      eachCouponCount = totalCouponsCount.toInt(); // left side value 54
      int couponsCountRemainder = int.tryParse(
          totalCouponsCount.toString().split('.')[1]); // right side value 32
      double rightValueDecimal =
          double.parse('0.$couponsCountRemainder'); // 0.32
      newRest = rightValueDecimal.toDouble() *
          couponPrice; // New Rest Value 0.32 * Coupon Price
      rest.forEach((restItem) {
        if (restItem['copounId'] == couponId) {
          restItem['rest'] = newRest.toString();
          print('new rest: ' + newRest.toString());
        }
      });
      print('new calculated rest: ' + rest.toString());
      await prefs.setString('tempRest', json.encode(rest));
    }
  }

  Future<void> saveRestPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    rest = json.decode(prefs.getString('tempRest'));
    await prefs.setString(PREFS_REST_LIST_KEY, json.encode(rest));
  }
}
