import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:golf/global_widgets/nav_drawer.dart';
import 'package:golf/providers/locations.dart';
import 'package:golf/screens/home_screen_body/bills_menu_screen.dart';
import 'package:golf/screens/home_screen_body/cs_managers_page.dart';
import 'package:golf/screens/home_screen_body/customer_services_agents_page.dart';
import 'package:golf/screens/home_screen_body/main_page.dart';
import 'package:golf/screens/home_screen_body/merchants_page.dart';
import 'package:golf/screens/home_screen_body/offers_page.dart';
import 'package:golf/screens/home_screen_body/plumbers_page.dart';
import 'package:golf/screens/home_screen_body/prices_page.dart';
import 'package:golf/screens/home_screen_body/sales_agents_page.dart';
import 'package:golf/screens/home_screen_body/sales_managers_page.dart';
import 'package:golf/screens/new_bill_form_screen.dart';
import 'package:golf/screens/new_distibutor_screen.dart';
import 'package:golf/screens/new_merchant_screen.dart';
import 'package:golf/screens/not_sent_bills.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

import 'home_screen_body/distibutors_page.dart';

class HomeScreen extends StatefulWidget {
  static const ROUTE_NAME = '/homeRoute';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer _locTimer;
  int _selectedHomeIndex = 0;
  bool _isBillsLoading = false;

  void _selectedHomePage(int selectedIndex) {
    setState(() {
      Navigator.pop(context);
      _selectedHomeIndex = selectedIndex;
    });
  }

  List<Map<String, Object>> _homePages;

  @override
  void initState() {
    super.initState();
    // _getData();
    final locData = Provider.of<Locations>(context, listen: false);
    _locTimer = Timer.periodic(Duration(minutes: 10), (_) {
      locData.sendGPSLocation();
    });
    _homePages = [
      {
        'title': 'الصفحة الرئيسية',
        'body': MainPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة التجار',
        'body': MerchantsPage(),
        'floatingActionButton': FloatingActionButton.extended(
          label: Text(
            'إضافة تاجر',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: mainColor,
          onPressed: () {
            Navigator.of(context).pushNamed(NewMerchantScreen.ROUTE_NAME);
          },
        ),
      },
      {
        'title': 'عروض و مسابقات',
        'body': OffersPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة الأسعار',
        'body': PricesPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة الموزعين',
        'body': DistributorsPage(),
        'floatingActionButton': FloatingActionButton.extended(
          label: Text(
            'إضافة موزع',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: mainColor,
          onPressed: () {
            Navigator.of(context).pushNamed(NewDistributorScreen.ROUTE_NAME);
          },
        ),
      },
      {
        'title': 'قائمة مديرين المبيعات',
        'body': SalesManagersPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة مديرين خدمة العملاء',
        'body': CSManagersPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة مناديب خدمة العملاء',
        'body': CustomerServicesAgentsPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'قائمة مناديب المبيعات',
        'body': SalesAgentsPage(),
        'floatingActionButton': null,
      },
      {
        'title': 'المعاينة',
        'body': BillsMenuScreen(),
        'floatingActionButton': FloatingActionButton.extended(
          label: Text(
            'إضافة معاينة',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: mainColor,
          onPressed: _isBillsLoading
              ? null
              : () async {
                  try {
                    setState(() {
                      _isBillsLoading = true;
                    });
                    bool isInternetAvailable = await isInternet();
                    print('Internet available: ' +
                        isInternetAvailable.toString());
                    if (isInternetAvailable) {
                      // final billsData =
                      //     Provider.of<Products>(context, listen: false);
                      // await billsData.getNotSentBills();
                      // if (billsData.notSentBills.isNotEmpty) {
                      //   _showErrorDialog(
                      //       'برجاء إرسال المعاينات المحفوظة أولا ثم إعادة المحاولة');
                      // } else {
                      setState(() {
                        _isBillsLoading = false;
                      });
                      Navigator.of(context)
                          .pushNamed(NewBillFormScreen.ROUTE_NAME);
                      // }
                    } else {
                      setState(() {
                        _isBillsLoading = false;
                      });
                      Navigator.of(context)
                          .pushNamed(NewBillFormScreen.ROUTE_NAME);
                    }
                  } catch (error) {
                    _showErrorDialog(error.toString());
                  }
                },
        ),
      },
      {
        'title': 'المعاينات المحفوظة',
        'body': NotSentBills(),
        'floatingActionButton': null,
      },
      {
        'title': 'الفنيين',
        'body': PlumbersPage(),
        'floatingActionButton': null,
      },
    ];
  }

  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _locTimer.cancel();
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('خطأ'),
          content: Text(errorMessage),
          actions: [
            FlatButton(
              onPressed: () {
                setState(() {
                  _isBillsLoading = false;
                });
                Navigator.of(context).pop();
              },
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationDrawer(_selectedHomePage),
      appBar: AppBar(
        title: Text(_homePages[_selectedHomeIndex]['title']),
        backgroundColor: mainColor,
      ),
      body: _homePages[_selectedHomeIndex]['body'],
      floatingActionButton: _homePages[_selectedHomeIndex]
          ['floatingActionButton'],
    );
  }
}
