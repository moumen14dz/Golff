import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:golf/providers/auth.dart';
import 'package:golf/providers/districts.dart';
import 'package:golf/providers/governorates.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isLoading = false;

  // bool doneSync = false;

  @override
  void initState() {
    super.initState();
    // hasSynced(); // TODO: Shared prefs Bug Resolve
  }

  void hasSynced() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasSynced = prefs.getBool('hasSynced') ?? false;
    if (!hasSynced) {
      /*showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('مزامنة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: SpinKitDoubleBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
                const Text('جارى مزامنة البيانات'),
              ],
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );*/
      await _syncData();
      prefs.setBool('hasSynced', true);
    }
  }

  Future<void> _syncData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool isInternetAvailable = await isInternet();
      await Provider.of<Merchants>(context, listen: false)
          .getMerchants(isInternetAvailable);
      await Provider.of<Plumbers>(context, listen: false)
          .getPlumbers(true, true);
      await Provider.of<Governorates>(context, listen: false)
          .getGovernorates(isInternetAvailable);
      await Provider.of<Districts>(context, listen: false)
          .getDistricts(null, isInternetAvailable);
      await Provider.of<Products>(context, listen: false)
          .getCategories(isInternetAvailable);
      await Provider.of<Auth>(context, listen: false).getRests();
      Toast.show(
        'تمت المزامنة بنجاح',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      Toast.show(
        'برجاء التأكد من وجود شبكة إنترنت متاحة و إعادة المحاولة',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
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
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 150,
              width: 150,
            ),
            SizedBox(
              height: 32,
            ),
            Text(
              'مرحبا بكم فى برنامج شركة الجولف',
              style: kMainTitleStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 32,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 54,
              child: RaisedButton.icon(
                icon: Icon(Icons.sync),
                label: Text(
                  _isLoading ? 'جارى مزامنة البيانات' : 'مزامنة البيانات',
                  style: TextStyle(color: Colors.white),
                ),
                color: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onPressed: _isLoading ? null : _syncData,
              ),
            )
          ],
        ),
      ),
    );
  }
}
