import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/bill.dart';
import 'package:golf/providers/bills.dart';
import 'package:provider/provider.dart';

class BillsMenuScreen extends StatefulWidget {
  static const ROUTE_NAME = '/billsMenuScreen';

  @override
  _BillsMenuScreenState createState() => _BillsMenuScreenState();
}

class _BillsMenuScreenState extends State<BillsMenuScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Bill> _bills = [];
  List<Bill> _filteredBills = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getBills();
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

  void onSearchTextChanged(String searchText) {
    _filteredBills.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _bills.forEach((bill) {
      if (bill.code.contains(_searchController.text.trim()) ||
          bill.merchantName.contains(_searchController.text.trim()) ||
          bill.plumberName.contains(_searchController.text.trim()) ||
          bill.governorate.contains(_searchController.text.trim()) ||
          bill.plumberPhone.contains(_searchController.text.trim()) ||
          bill.date.contains(_searchController.text.trim()) ||
          bill.merchantPhone.contains(_searchController.text.trim())) {
        _filteredBills.add(bill);
      }
    });
    setState(() {});
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
                Navigator.of(context).pop();
              },
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void getBills() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final billsData = Provider.of<Bills>(context, listen: false);
      await billsData.getBills();
      _bills = billsData.bills;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error.toString());
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('برجاء التأكد من وجود شبكة إنترنت و إعادة المحاولة');
    }
  }

  @override
  Widget build(BuildContext context) {
    final billsData = Provider.of<Bills>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث',
              suffixIcon: _searchController.text.isEmpty
                  ? Icon(Icons.search)
                  : IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _filteredBills.clear();
                          _searchController.text = '';
                        });
                      },
                    ),
            ),
            textDirection: TextDirection.rtl,
            controller: _searchController,
            onChanged: onSearchTextChanged,
          ),
          _isLoading
              ? Center(
                  child: SpinKitDoubleBounce(
                    color: Colors.white,
                    size: 50.0,
                  ),
                )
              : Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredBills.isEmpty
                              ? billsData.bills.length
                              : _filteredBills.length,
                          itemBuilder: (context, i) {
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Table(
                                  border: TableBorder(
                                    horizontalInside:
                                        BorderSide(color: Colors.black38),
                                    verticalInside:
                                        BorderSide(color: Colors.black38),
                                  ),
                                  children: [
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('الكود'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].code
                                            : _filteredBills[i].code),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('التاريخ'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].date
                                            : _filteredBills[i].date),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('إسم التاجر'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].merchantName
                                            : _filteredBills[i].merchantName),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('رقم التاجر'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].merchantPhone
                                            : _filteredBills[i].merchantPhone),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('إسم الفنى'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].plumberName
                                            : _filteredBills[i].plumberName),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('رقم الفنى'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].plumberPhone
                                            : _filteredBills[i].plumberPhone),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('العنوان'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].address
                                            : _filteredBills[i].address),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('المحافظة'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].governorate
                                            : _filteredBills[i].governorate),
                                      ),
                                    ]),
                                    // TableRow(children: [
                                    //   Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Text('السعر الإجمالى'),
                                    //   ),
                                    //   Padding(
                                    //     padding: const EdgeInsets.all(8.0),
                                    //     child: Text(_filteredBills.isEmpty
                                    //         ? billsData.bills[i].totalAmount
                                    //         : _filteredBills[i].totalAmount),
                                    //   ),
                                    // ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('المستحق'),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 12),
                                        child: Text(_filteredBills.isEmpty
                                            ? billsData.bills[i].reward
                                            : _filteredBills[i].reward),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
