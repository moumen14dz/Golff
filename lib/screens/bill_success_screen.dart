import 'package:flutter/material.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/utils/constants.dart';

import 'package:provider/provider.dart';

class BillSuccessScreen extends StatelessWidget {
  static const ROUTE_NAME = '/billSuccessScreen';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('إتمام العملية'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: Column(
          children: [
            Text(
              productsData.billSuccessMessage,
              style: kMainTitleStyle,
            ),
            Expanded(
              child: productsData.billSuccessReward.isEmpty
                  ? Center(
                      child: Text('لا يوجد هدايا مستحقة'),
                    )
                  : ListView.builder(
                      itemCount: productsData.billSuccessReward.length,
                      itemBuilder: (context, i) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  productsData.billSuccessReward[i]['title'],
                                  style: kMainTitleStyle,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  productsData.billSuccessReward[i]['descr'],
                                  style: kTableRowColumnTitleStyle,
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            OutlineButton(
              child: Text('إغلاق'),
              textColor: mainColor,
              onPressed: () {
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
    );
  }
}
