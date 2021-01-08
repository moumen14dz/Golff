import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/sales_agent.dart';
import 'package:golf/providers/sales_agents.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../merchant_loc_map.dart';
import '../new_report_screen.dart';

class SalesAgentsPage extends StatefulWidget {
  @override
  _SalesAgentsPageState createState() => _SalesAgentsPageState();
}

class _SalesAgentsPageState extends State<SalesAgentsPage> {
  TextEditingController _searchController = TextEditingController();
  List<SalesAgent> _salesAgents = [];
  List<SalesAgent> _filteredSalesAgents = [];

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredSalesAgents.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _salesAgents.forEach((agent) {
      if (agent.name.contains(searchText.trim()) ||
          agent.phoneNumber.contains(searchText.trim()) ||
          agent.code.contains(searchText.trim())) {
        _filteredSalesAgents.add(agent);
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
                          _filteredSalesAgents.clear();
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
            future: Provider.of<SalesAgents>(context, listen: false)
                .getSalesAgents(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<SalesAgents>(
                    builder: (context, salesAgentsData, ch) {
                      _salesAgents = salesAgentsData.salesAgents;
                      if (_filteredSalesAgents.isEmpty) {
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
                          itemCount: salesAgentsData.salesAgents.length,
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
                                                salesAgentsData
                                                    .salesAgents[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                salesAgentsData
                                                    .salesAgents[i].governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              salesAgentsData
                                                  .salesAgents[i].code,
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
                                                      'id': salesAgentsData
                                                          .salesAgents[i].id,
                                                      'title': salesAgentsData
                                                          .salesAgents[i].name,
                                                      'lat': salesAgentsData
                                                          .salesAgents[i].lat,
                                                      'lon': salesAgentsData
                                                          .salesAgents[i].lon,
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
                                                      'tel:${salesAgentsData.salesAgents[i].phoneNumber}');
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
                                                    arguments: salesAgentsData
                                                        .salesAgents[i].id,
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
                          itemCount: _filteredSalesAgents.length,
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
                                                _filteredSalesAgents[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredSalesAgents[i]
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
                                              _filteredSalesAgents[i].code,
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
                                                          _filteredSalesAgents[
                                                                  i]
                                                              .id,
                                                      'title':
                                                          _filteredSalesAgents[
                                                                  i]
                                                              .name,
                                                      'lat':
                                                          _filteredSalesAgents[
                                                                  i]
                                                              .lat,
                                                      'lon':
                                                          _filteredSalesAgents[
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
                                                      'tel:${_filteredSalesAgents[i].phoneNumber}');
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
                                                        _filteredSalesAgents[i]
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
