import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/customer_services_agent.dart';
import 'package:golf/providers/customer_services_agents.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../merchant_loc_map.dart';
import '../new_report_screen.dart';

class CustomerServicesAgentsPage extends StatefulWidget {
  @override
  _CustomerServicesAgentsPageState createState() =>
      _CustomerServicesAgentsPageState();
}

class _CustomerServicesAgentsPageState
    extends State<CustomerServicesAgentsPage> {
  TextEditingController _searchController = TextEditingController();
  List<CustomerServicesAgent> _csAgents = [];
  List<CustomerServicesAgent> _filteredCSAgent = [];

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }

  void onSearchTextChanged(String searchText) {
    _filteredCSAgent.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _csAgents.forEach((agent) {
      if (agent.name.contains(searchText.trim()) ||
          agent.phoneNumber.contains(searchText.trim()) ||
          agent.code.contains(searchText.trim())) {
        _filteredCSAgent.add(agent);
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
                          _filteredCSAgent.clear();
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
            future: Provider.of<CustomerServicesAgents>(context, listen: false)
                .getCSAgents(),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<CustomerServicesAgents>(
                    builder: (context, csAgentsData, ch) {
                      _csAgents = csAgentsData.customerServicesAgents;
                      if (_filteredCSAgent.isEmpty) {
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
                          itemCount: csAgentsData.customerServicesAgents.length,
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
                                                csAgentsData
                                                    .customerServicesAgents[i]
                                                    .name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                csAgentsData
                                                    .customerServicesAgents[i]
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
                                              csAgentsData
                                                  .customerServicesAgents[i]
                                                  .code,
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
                                                      'id': csAgentsData
                                                          .customerServicesAgents[
                                                              i]
                                                          .id,
                                                      'title': csAgentsData
                                                          .customerServicesAgents[
                                                              i]
                                                          .name,
                                                      'lat': csAgentsData
                                                          .customerServicesAgents[
                                                              i]
                                                          .lat,
                                                      'lon': csAgentsData
                                                          .customerServicesAgents[
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
                                                      'tel:${csAgentsData.customerServicesAgents[i].phoneNumber}');
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
                                                    arguments: csAgentsData
                                                        .customerServicesAgents[
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
                      } else {
                        return ListView.builder(
                          itemCount: _filteredCSAgent.length,
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
                                                _filteredCSAgent[i].name,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredCSAgent[i].governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              _filteredCSAgent[i].code,
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
                                                      'id': _filteredCSAgent[i]
                                                          .id,
                                                      'title':
                                                          _filteredCSAgent[i]
                                                              .name,
                                                      'lat': _filteredCSAgent[i]
                                                          .lat,
                                                      'lon': _filteredCSAgent[i]
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
                                                      'tel:${_filteredCSAgent[i].phoneNumber}');
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
                                                        _filteredCSAgent[i].id,
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
