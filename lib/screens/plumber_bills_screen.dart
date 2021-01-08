import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/plumber_bill.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class PlumberBillsScreen extends StatefulWidget {
  static const ROUTE_NAME = '/plumberBillsScreen';

  @override
  _PlumberBillsScreenState createState() => _PlumberBillsScreenState();
}

class _PlumberBillsScreenState extends State<PlumberBillsScreen> {
  // TextEditingController _searchController = TextEditingController();

  // List<List<PlumberBill>> _plumberBills = [];
  // List<PlumberBill> _filteredPlumberBills = [];

  @override
  void initState() {
    super.initState();
    // getCredits();
  }

  // void onSearchTextChanged(String searchText) {
  //   _filteredPlumberBills.clear();
  //   if (searchText.trim().isEmpty) {
  //     setState(() {});
  //     return;
  //   }
  //   _plumberBills.forEach((list) {
  //     if (list.any((element) {
  //       return element.merchantName.contains(_searchController.text.trim()) ||
  //           element.billNumber.contains(_searchController.text.trim()) ||
  //           element.id.contains(_searchController.text.trim()) ||
  //           element.clientName.contains(_searchController.text.trim());
  //     })) {
  //       _filteredPlumberBills = list;
  //     }
  //   });
  //   setState(() {});
  // }

  // void getCredits() async {
  //   await Provider.of<Plumbers>(context, listen: false).getCredits();
  // }

  @override
  Widget build(BuildContext context) {
    final int plumberID =
        ModalRoute.of(context).settings.arguments; // plumberId
    return Scaffold(
      appBar: AppBar(
        title: Text('الفواتير'),
        backgroundColor: mainColor,
      ),
      body: FutureBuilder(
        future:
            Provider.of<Plumbers>(context, listen: false).getBills(plumberID),
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
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: plumbersData.plumberBills.length == 0
                        ? Center(
                            child: const Text('لا يوجد فواتير'),
                          )
                        : ListView.builder(
                            itemCount: plumbersData.plumberBills.length,
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
                                          child: Text('رقم تسلسلى'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                              plumbersData.plumberBills[i].id),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('التاريخ'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(plumbersData
                                              .plumberBills[i].date),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('إسم العميل'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(plumbersData
                                              .plumberBills[i].clientName),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('رقم الفاتورة'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(plumbersData
                                              .plumberBills[i].billNumber),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('إسم التاجر'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(plumbersData
                                              .plumberBills[i].merchantName),
                                        ),
                                      ]),
                                      TableRow(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('المستحق'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(plumbersData
                                              .plumberBills[i].reward),
                                        ),
                                      ]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
      ),
    );
  }
}
