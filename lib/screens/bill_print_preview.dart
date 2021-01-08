import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/utils/constants.dart';

import 'package:provider/provider.dart';

import 'bill_media_import.dart';

class BillPrintPreview extends StatefulWidget {
  static const ROUTE_NAME = '/billPrintPreview';

  @override
  _BillPrintPreviewState createState() => _BillPrintPreviewState();
}

class _BillPrintPreviewState extends State<BillPrintPreview> {
  double totalPriceOfProduct = 0.0;
  double totalPointsOfProduct = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context, listen: false);
    final Map<String, dynamic> _prevScreenData =
        ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: AppBar(
        title: Text('معاينة الفاتورة'),
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'البيانات الأساسية',
                style: kMainTitleStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.symmetric(
                  inside: BorderSide(
                    color: Colors.black12,
                  ),
                  outside: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                ),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'إسم العميل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['clientName']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم تليفون العميل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['clientPhone']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'إسم الفنى',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((_prevScreenData['plumber'] as Plumber)
                            .plumberName),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم تليفون الفنى',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((_prevScreenData['plumber'] as Plumber)
                            .plumberPhone),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'إسم التاجر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((_prevScreenData['merchant'] as Merchant)
                            .merchantName),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم تليفون التاجر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text((_prevScreenData['merchant'] as Merchant)
                            .telephoneNumber),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم الفاتورة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['billNumber']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'العنوان',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['address']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'صاعد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['elevators']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'حمام',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['bathrooms']),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'مطبخ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_prevScreenData['kitchens']),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            ListView(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: productsData.coupons.entries.map((entry) {
                double totalPrice = 0;
                double totalPoints = 0.0;
                int totalAmount = 0;
                entry.value.forEach((prod) {
                  totalAmount += prod.amount;
                });
                if (!entry.value.any((prod) => prod.amount != 0)) {
                  return Container();
                } else {
                  return Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.loyalty,
                            color: Colors.yellow,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            productsData.findCouponNameById(entry.key),
                            style: kMainTitleStyle,
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showBottomBorder: true,
                          dataRowHeight: 60,
                          headingRowColor: MaterialStateColor.resolveWith(
                              (state) => Colors.black12),
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                'إسم المنتج',
                                style: kTableRowColumnTitleStyle,
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'الكمية',
                                style: kTableRowColumnTitleStyle,
                              ),
                            ),
                            // DataColumn(
                            //   label: Text(
                            //     'السعر',
                            //     style: kTableRowColumnTitleStyle,
                            //   ),
                            // ),
                            DataColumn(
                              label: Text(
                                'النقاط',
                                style: kTableRowColumnTitleStyle,
                              ),
                            ),
                            // DataColumn(
                            //   label: Text(
                            //     'إجمالى السعر',
                            //     style: kTableRowColumnTitleStyle,
                            //   ),
                            // ),
                            DataColumn(
                              label: Text(
                                'إجمالى النقاط',
                                style: kTableRowColumnTitleStyle,
                              ),
                            ),
                          ],
                          rows: entry.value.map((prod) {
                            totalPriceOfProduct = double.parse(prod.mainPrice) *
                                prod.amount.toDouble();
                            totalPointsOfProduct =
                                prod.points * prod.amount.toDouble();

                            totalPrice += totalPriceOfProduct;
                            totalPoints += totalPointsOfProduct;
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(prod.name),
                                ),
                                DataCell(
                                  Text(prod.amount.toString()),
                                ),
                                // DataCell(
                                //   Text(prod.mainPrice),
                                // ),
                                DataCell(
                                  Text(prod.points.toString()),
                                ),
                                // DataCell(
                                //   Text(totalPriceOfProduct.toString()),
                                // ),
                                DataCell(
                                  Text(totalPointsOfProduct.toString()),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /*Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'إجمالى الكمية',
                                    style: kTableRowColumnTitleStyle,
                                  ),
                                  Text(totalAmount.toString()),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'إجمالى السعر',
                                    style: kTableRowColumnTitleStyle,
                                  ),
                                  Text(totalPrice.toString()),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'إجمالى النقاط',
                                    style: kTableRowColumnTitleStyle,
                                  ),
                                  Text(totalPoints.toString()),
                                ],
                              ),
                            ),*/
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'عدد الكوبونات',
                                    style: TextStyle(color: Colors.transparent),
                                  ),
                                  FutureBuilder(
                                    future: productsData.couponsCountData(
                                        entry.key, totalPrice),
                                    builder: (context, snapshot) =>
                                        snapshot.connectionState ==
                                                ConnectionState.waiting
                                            ? Center(
                                                child: SpinKitDoubleBounce(
                                                  color: Colors.white,
                                                  size: 50.0,
                                                ),
                                              )
                                            : Text(
                                                productsData.eachCouponCount
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Colors.transparent),
                                              ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'الباقى',
                                    style: TextStyle(color: Colors.transparent),
                                  ),
                                  FutureBuilder(
                                    future: productsData.couponsCountData(
                                        entry.key, totalPrice),
                                    builder: (context, snapshot) =>
                                        snapshot.connectionState ==
                                                ConnectionState.waiting
                                            ? Center(
                                                child: SpinKitDoubleBounce(
                                                  color: Colors.white,
                                                  size: 50.0,
                                                ),
                                              )
                                            : Text(
                                                productsData.newRest
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                    color: Colors.transparent),
                                              ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              }).toList(),
            ),
            SizedBox(
              height: 16,
            ),
            RaisedButton(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'إرسال الفاتورة',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              color: mainColor,
              elevation: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  BillMediaImport.ROUTE_NAME,
                  arguments: _prevScreenData,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
