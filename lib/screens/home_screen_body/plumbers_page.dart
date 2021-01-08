import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/global_widgets/badge.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/models/plumber_bill.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/screens/plumber_bills_screen.dart';
import 'package:golf/screens/plumber_credits_screen.dart';
import 'package:golf/screens/suggested_gifts_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PlumbersPage extends StatefulWidget {
  @override
  _PlumbersPageState createState() => _PlumbersPageState();
}

class _PlumbersPageState extends State<PlumbersPage> {
  TextEditingController _searchController = TextEditingController();
  List<Plumber> _plumbers = [];
  List<Plumber> _filteredPlumbers = [];

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
    // _getLastKnownPosition();
  }

  Future<void> _getLastKnownPosition() async {
    // Position position = await Geolocator.getLastKnownPosition();
    // if (position.longitude != null && position.latitude != null) {
    //   print(
    //       'Last know position: ${position.longitude} and ${position.latitude}');
    // }
  }

  void onSearchTextChanged(String searchText) {
    _filteredPlumbers.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _plumbers.forEach((plumber) {
      if (plumber.code.contains(searchText.trim()) ||
          plumber.plumberName.contains(searchText.trim()) ||
          plumber.nationalId.contains(searchText.trim()) ||
          plumber.points.toString().contains(searchText.trim()) ||
          plumber.plumberPhone.contains(searchText.trim())) {
        _filteredPlumbers.add(plumber);
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
                          _filteredPlumbers.clear();
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
            future: Provider.of<Plumbers>(context, listen: false)
                .getPlumbers(true, false),
            builder: (context, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : Consumer<Plumbers>(
                    builder: (context, plumbersData, ch) {
                      _plumbers = plumbersData.plumbers;
                      if (_filteredPlumbers.isEmpty) {
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
                          itemCount: plumbersData.plumbers.length,
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
                                                plumbersData.plumbers[i].code,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                plumbersData
                                                    .plumbers[i].plumberName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                plumbersData
                                                    .plumbers[i].governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                plumbersData
                                                    .plumbers[i].nationalId,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundColor: mainColor,
                                              radius: 25,
                                              child: FittedBox(
                                                child: Text(
                                                  plumbersData
                                                      .plumbers[i].points
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
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
                                                  Icons.credit_card,
                                                  color: Colors.red,
                                                  size: 32,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          PlumberCreditsScreen
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              plumbersData
                                                                  .plumbers[i]
                                                                  .id);
                                                },
                                              ),
                                              Text('رصيد'),
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
                                                      'tel:${plumbersData.plumbers[i].plumberPhone}');
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
                                                          PlumberBillsScreen
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              plumbersData
                                                                  .plumbers[i]
                                                                  .id);
                                                },
                                              ),
                                              Text('فواتير'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Badge(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.wallet_giftcard,
                                                      color: Colors.yellow[700],
                                                      size: 32,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              SuggestedGiftsScreen
                                                                  .ROUTE_NAME,
                                                              arguments:
                                                                  plumbersData
                                                                      .plumbers[
                                                                          i]
                                                                      .id);
                                                    },
                                                  ),
                                                  quantity: plumbersData
                                                      .plumbers[i].giftsCount),
                                              Text('هدية'),
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
                          itemCount: _filteredPlumbers.length,
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
                                                _filteredPlumbers[i].code,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                _filteredPlumbers[i]
                                                    .plumberName,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              Text(
                                                _filteredPlumbers[i]
                                                    .governorate,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                _filteredPlumbers[i].nationalId,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircleAvatar(
                                              backgroundColor: mainColor,
                                              radius: 25,
                                              child: FittedBox(
                                                child: Text(
                                                  _filteredPlumbers[i]
                                                      .points
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
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
                                                  Icons.credit_card,
                                                  color: Colors.red,
                                                  size: 32,
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          PlumberCreditsScreen
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              _filteredPlumbers[
                                                                      i]
                                                                  .id);
                                                },
                                              ),
                                              Text('رصيد'),
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
                                                      'tel:${_filteredPlumbers[i].plumberPhone}');
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
                                                          PlumberBillsScreen
                                                              .ROUTE_NAME,
                                                          arguments:
                                                              _filteredPlumbers[
                                                                      i]
                                                                  .id);
                                                },
                                              ),
                                              Text('فواتير'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Badge(
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.wallet_giftcard,
                                                    color: Colors.yellow[700],
                                                    size: 32,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            SuggestedGiftsScreen
                                                                .ROUTE_NAME,
                                                            arguments:
                                                                _filteredPlumbers[
                                                                        i]
                                                                    .id);
                                                  },
                                                ),
                                                quantity: _filteredPlumbers[i]
                                                    .giftsCount,
                                              ),
                                              Text('هدية'),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.assistant,
                                                  color: Colors.brown,
                                                  size: 32,
                                                ),
                                                onPressed: () {},
                                              ),
                                              Text('إرسال'),
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
