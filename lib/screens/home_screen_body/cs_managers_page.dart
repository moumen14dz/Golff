import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/manager.dart';
import 'package:golf/providers/cs_managers.dart';
import 'package:golf/providers/sales_managers.dart';
import 'package:golf/screens/new_report_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../merchant_loc_map.dart';

class CSManagersPage extends StatefulWidget {
  @override
  _CSManagersPageState createState() => _CSManagersPageState();
}

class _CSManagersPageState extends State<CSManagersPage> {
  TextEditingController _searchController = TextEditingController();
  List<Manager> _csManagers = [];
  List<Manager> _filteredCSManagers = [];

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredCSManagers.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _csManagers.forEach((manager) {
      if (manager.name.contains(searchText.trim()) ||
          manager.phoneNumber.contains(searchText.trim()) ||
          manager.code.contains(searchText.trim())) {
        _filteredCSManagers.add(manager);
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
                          _filteredCSManagers.clear();
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
            future:
                Provider.of<CSManagers>(context, listen: false).getCSManagers(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<CSManagers>(
                    builder: (context, csManagersData, ch) {
                      _csManagers = csManagersData.csManagers;
                      if (_filteredCSManagers.isEmpty) {
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
                          itemCount: csManagersData.csManagers.length,
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
                                                csManagersData
                                                    .csManagers[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                csManagersData
                                                    .csManagers[i].governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              csManagersData.csManagers[i].code,
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
                                                      'id': csManagersData
                                                          .csManagers[i].id,
                                                      'title': csManagersData
                                                          .csManagers[i].name,
                                                      'lat': csManagersData
                                                          .csManagers[i].lat,
                                                      'lon': csManagersData
                                                          .csManagers[i].lon,
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
                                                      'tel:${csManagersData.csManagers[i].phoneNumber}');
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
                                                          NewReportScreen
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              csManagersData
                                                                  .csManagers[i]
                                                                  .id);
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
                          itemCount: _filteredCSManagers.length,
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
                                                _filteredCSManagers[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredCSManagers[i]
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
                                              _filteredCSManagers[i].code,
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
                                                          _filteredCSManagers[i]
                                                              .id,
                                                      'title':
                                                          _filteredCSManagers[i]
                                                              .name,
                                                      'lat':
                                                          _filteredCSManagers[i]
                                                              .lat,
                                                      'lon':
                                                          _filteredCSManagers[i]
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
                                                      'tel:${_filteredCSManagers[i].phoneNumber}');
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
                                                  Navigator.of(context).pushNamed(
                                                      NewReportScreen
                                                          .ROUTE_NAME,
                                                      arguments:
                                                          _filteredCSManagers[i]
                                                              .id);
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
