import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/providers/locations.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/screens/merchant_loc_map.dart';
import 'package:golf/screens/new_gift_screen.dart';
import 'package:golf/screens/new_order_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../new_visit_screen.dart';

class MerchantsPage extends StatefulWidget {
  @override
  _MerchantsPageState createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Merchant> _merchants = [];
  List<Merchant> _filteredMerchants = [];
  bool _isLoading = false;

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();
    _getLastKnownPosition();
    getMerchants();
  }

  Future<void> getMerchants() async {
    try {
      final merchantsData = Provider.of<Merchants>(context, listen: false);
      await merchantsData.getMerchants(false);
      setState(() {
        _merchants = merchantsData.merchants;
      });
    } catch (error) {
      print('merchants page catch error' + error.toString());
    }
  }

  Future<void> _getLastKnownPosition() async {
    // Position position = await Geolocator.getLastKnownPosition();
    // if (position.longitude != null && position.latitude != null) {
    //   print(
    //       'Last know position: ${position.longitude} and ${position.latitude}');
    // }
  }

  Future<void> getCurrentLocation(int merchantId) async {
    try {
      setState(() {
        _isLoading = true;
      });
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final successMessage =
          await Provider.of<Locations>(context, listen: false)
              .sendMerchantGPSLocation(
        position.longitude,
        position.latitude,
        merchantId,
      );
      setState(() {
        _isLoading = false;
      });
      Toast.show(
        successMessage,
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      Toast.show(
        'فشلت عملية تحديد الموقع',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredMerchants.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _merchants.forEach((merchant) {
      if (merchant.shopName.contains(searchText.trim()) ||
          merchant.respName.contains(searchText.trim()) ||
          merchant.code.contains(searchText.trim()) ||
          merchant.telephoneNumber.contains(searchText.trim())) {
        _filteredMerchants.add(merchant);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final merchantsData = Provider.of<Merchants>(context);
    // _merchants = merchantsData.merchants;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'بحث',
              suffixIcon: _searchController.text.isEmpty
                  ? Icon(Icons.search)
                  : IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _filteredMerchants.clear();
                          _searchController.text = '';
                        });
                      },
                    ),
            ),
            onChanged: onSearchTextChanged,
            controller: _searchController,
          ),
        ),
        Expanded(
          child: _filteredMerchants.isEmpty && _searchController.text.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.yellowAccent,
                      ),
                      Text('لم يتم العثور على شئ.'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredMerchants.isEmpty
                      ? _merchants.length
                      : _filteredMerchants.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _filteredMerchants.isEmpty
                                      ? _merchants[i].code
                                      : _filteredMerchants[i].code,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                _filteredMerchants.isEmpty
                                    ? _merchants[i].shopName
                                    : _filteredMerchants[i].shopName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              Text(
                                _filteredMerchants.isEmpty
                                    ? _merchants[i].respName
                                    : _filteredMerchants[i].respName,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                            MerchantLocMap.ROUTE_NAME,
                                            arguments: {
                                              'id': _filteredMerchants.isEmpty
                                                  ? _merchants[i].id
                                                  : _filteredMerchants[i].id,
                                              'title':
                                                  _filteredMerchants.isEmpty
                                                      ? _merchants[i].shopName
                                                      : _filteredMerchants[i]
                                                          .shopName,
                                              'lat': _filteredMerchants.isEmpty
                                                  ? _merchants[i].lat
                                                  : _filteredMerchants[i].lat,
                                              'lon': _filteredMerchants.isEmpty
                                                  ? _merchants[i].lon
                                                  : _filteredMerchants[i].lon,
                                            },
                                          );
                                        },
                                      ),
                                      Text('عنوان'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.call,
                                          color: Colors.green,
                                          size: 32,
                                        ),
                                        onPressed: () => setState(() {
                                          _makePhoneCall(
                                              'tel:${_filteredMerchants.isEmpty ? _merchants[i].telephoneNumber : _filteredMerchants[i].telephoneNumber}');
                                        }),
                                      ),
                                      Text('إتصال'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.payments,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              NewOrdersScreen.ROUTE_NAME,
                                              arguments: {
                                                'id': _filteredMerchants.isEmpty
                                                    ? _merchants[i].id
                                                    : _filteredMerchants[i].id,
                                                'type': 1,
                                              });
                                        },
                                      ),
                                      Text('طلبية'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.wallet_giftcard,
                                          color: Colors.yellow[700],
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              NewGiftScreen.ROUTE_NAME,
                                              arguments: {
                                                'id': _filteredMerchants.isEmpty
                                                    ? _merchants[i].id
                                                    : _filteredMerchants[i].id,
                                                'type': 1,
                                              });
                                        },
                                      ),
                                      Text('هدية'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.tour,
                                          color: Colors.brown,
                                          size: 32,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              NewVisitScreen.ROUTE_NAME,
                                              arguments: {
                                                'id': _filteredMerchants.isEmpty
                                                    ? _merchants[i].id
                                                    : _filteredMerchants[i].id,
                                                'type': 1,
                                              });
                                        },
                                      ),
                                      Text('زيارة'),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                child: RaisedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          int merchantId =
                                              _filteredMerchants.isEmpty
                                                  ? _merchants[i].id
                                                  : _filteredMerchants[i].id;
                                          await getCurrentLocation(merchantId);
                                        },
                                  icon: Icon(Icons.add_location),
                                  label: Text('تحديث الموقع'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
