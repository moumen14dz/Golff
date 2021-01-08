import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/manager.dart';
import 'package:golf/providers/sales_managers.dart';
import 'package:golf/screens/new_report_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../merchant_loc_map.dart';

class SalesManagersPage extends StatefulWidget {
  @override
  _SalesManagersPageState createState() => _SalesManagersPageState();
}

class _SalesManagersPageState extends State<SalesManagersPage> {
  TextEditingController _searchController = TextEditingController();
  List<Manager> _salesManagers = [];
  List<Manager> _filteredSalesManagers = [];

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredSalesManagers.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _salesManagers.forEach((manager) {
      if (manager.name.contains(searchText.trim()) ||
          manager.phoneNumber.contains(searchText.trim()) ||
          manager.code.contains(searchText.trim())) {
        _filteredSalesManagers.add(manager);
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
                          _filteredSalesManagers.clear();
                          _searchController.text = '';
                        });
                      },
                    ),
            ),
            textDirection: TextDirection.rtl,
            controller: _searchController,
            onChanged: onSearchTextChanged,
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: Provider.of<SalesManagers>(context, listen: false)
                .getSalesManagers(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<SalesManagers>(
                    builder: (context, salesManagersData, ch) {
                      _salesManagers = salesManagersData.salesManagers;
                      if (_filteredSalesManagers.isEmpty) {
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
                          itemCount: salesManagersData.salesManagers.length,
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
                                                salesManagersData
                                                    .salesManagers[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                salesManagersData
                                                    .salesManagers[i]
                                                    .governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              salesManagersData
                                                  .salesManagers[i].code,
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
                                                      'id': salesManagersData
                                                          .salesManagers[i].id,
                                                      'title': salesManagersData
                                                          .salesManagers[i]
                                                          .name,
                                                      'lat': salesManagersData
                                                          .salesManagers[i].lat,
                                                      'lon': salesManagersData
                                                          .salesManagers[i].lon,
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
                                                      'tel:${salesManagersData.salesManagers[i].phoneNumber}');
                                                }),
                                              ),
                                              Text('إتصال'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.note_add,
                                                  color: Colors.blue,
                                                  size: 32,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    NewReportScreen.ROUTE_NAME,
                                                    arguments: salesManagersData
                                                        .salesManagers[i].id,
                                                  );
                                                },
                                              ),
                                              Text('تقرير'),
                                            ],
                                          ),
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
                          itemCount: _filteredSalesManagers.length,
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
                                                _filteredSalesManagers[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredSalesManagers[i]
                                                    .governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _filteredSalesManagers[i].code,
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
                                                          _filteredSalesManagers[
                                                                  i]
                                                              .id,
                                                      'title':
                                                          _filteredSalesManagers[
                                                                  i]
                                                              .name,
                                                      'lat':
                                                          _filteredSalesManagers[
                                                                  i]
                                                              .lat,
                                                      'lon':
                                                          _filteredSalesManagers[
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
                                                      'tel:${_filteredSalesManagers[i].phoneNumber}');
                                                }),
                                              ),
                                              Text('إتصال'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.note_add,
                                                  color: Colors.blue,
                                                  size: 32,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                    NewReportScreen.ROUTE_NAME,
                                                    arguments:
                                                        _filteredSalesManagers[
                                                                i]
                                                            .id,
                                                  );
                                                },
                                              ),
                                              Text('تقرير'),
                                            ],
                                          ),
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
