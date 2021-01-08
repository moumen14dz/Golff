import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/distributor.dart';
import 'package:golf/providers/distributors.dart';
import 'package:golf/screens/home_screen_body/serials_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../merchant_loc_map.dart';
import '../new_gift_screen.dart';
import '../new_order_screen.dart';
import '../new_visit_screen.dart';

class DistributorsPage extends StatefulWidget {
  @override
  _DistributorsPageState createState() => _DistributorsPageState();
}

class _DistributorsPageState extends State<DistributorsPage> {
  TextEditingController _searchController = TextEditingController();
  List<Distributor> _distributors = [];
  List<Distributor> _filteredDistributors = [];

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredDistributors.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _distributors.forEach((distributor) {
      if (distributor.shopName.contains(searchText.trim()) ||
          distributor.respName.contains(searchText.trim()) ||
          distributor.code.contains(searchText.trim()) ||
          distributor.telephoneNumber.contains(searchText.trim())) {
        _filteredDistributors.add(distributor);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
                          _filteredDistributors.clear();
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
          child: FutureBuilder(
            future: Provider.of<Distributors>(context, listen: false)
                .getDistributors(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<Distributors>(
                    builder: (context, distributorsData, ch) {
                      _distributors = distributorsData.distributors;
                      if (_filteredDistributors.isEmpty) {
                        if (_searchController.text.isNotEmpty) {
                          return Center(
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
                          );
                        }
                        return ListView.builder(
                          itemCount: distributorsData.distributors.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                distributorsData
                                                    .distributors[i].shopName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                distributorsData
                                                    .distributors[i].respName,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              distributorsData
                                                  .distributors[i].code,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    MerchantLocMap.ROUTE_NAME,
                                                    arguments: {
                                                      'id': distributorsData
                                                          .distributors[i].id,
                                                      'title': distributorsData
                                                          .distributors[i]
                                                          .shopName,
                                                      'lat': distributorsData
                                                          .distributors[i].lat,
                                                      'lon': distributorsData
                                                          .distributors[i].lon,
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
                                                      'tel:${distributorsData.distributors[i].telephoneNumber}');
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewOrdersScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id': distributorsData
                                                            .distributors[i].id,
                                                        'type': 2,
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewGiftScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id': distributorsData
                                                            .distributors[i].id,
                                                        'type': 2,
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewVisitScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id': distributorsData
                                                            .distributors[i].id,
                                                        'type': 2,
                                                      });
                                                },
                                              ),
                                              Text('زيارة'),
                                            ],
                                          ),
                                          // Column(
                                          //   children: [
                                          //     IconButton(
                                          //       icon: Icon(
                                          //         Icons.qr_code,
                                          //         color: Colors.red,
                                          //         size: 32,
                                          //       ),
                                          //       onPressed: () {
                                          //         Navigator.of(context)
                                          //             .pushNamed(SerialsScreen
                                          //                 .ROUTE_NAME);
                                          //       },
                                          //     ),
                                          //     Text('سيريال'),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return ListView.builder(
                          itemCount: _filteredDistributors.length,
                          itemBuilder: (context, i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _filteredDistributors[i]
                                                    .shopName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredDistributors[i]
                                                    .respName,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _filteredDistributors[i].code,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    MerchantLocMap.ROUTE_NAME,
                                                    arguments: {
                                                      'id':
                                                          _filteredDistributors[
                                                                  i]
                                                              .id,
                                                      'title':
                                                          _filteredDistributors[
                                                                  i]
                                                              .shopName,
                                                      'lat':
                                                          _filteredDistributors[
                                                                  i]
                                                              .lat,
                                                      'lon':
                                                          _filteredDistributors[
                                                                  i]
                                                              .lon,
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
                                                      'tel:${_filteredDistributors[i].telephoneNumber}');
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewOrdersScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id':
                                                            _filteredDistributors[
                                                                    i]
                                                                .id,
                                                        'type': 2,
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewGiftScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id':
                                                            _filteredDistributors[
                                                                    i]
                                                                .id,
                                                        'type': 2,
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
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          NewVisitScreen
                                                              .ROUTE_NAME,
                                                          arguments: {
                                                        'id':
                                                            _filteredDistributors[
                                                                    i]
                                                                .id,
                                                        'type': 2,
                                                      });
                                                },
                                              ),
                                              Text('زيارة'),
                                            ],
                                          ),
                                          // Column(
                                          //   children: [
                                          //     IconButton(
                                          //       icon: Icon(
                                          //         Icons.qr_code,
                                          //         color: Colors.red,
                                          //         size: 32,
                                          //       ),
                                          //       onPressed: () {
                                          //         Navigator.of(context)
                                          //             .pushNamed(SerialsScreen
                                          //                 .ROUTE_NAME);
                                          //       },
                                          //     ),
                                          //     Text('سيريال'),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
