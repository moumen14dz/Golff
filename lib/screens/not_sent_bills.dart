import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:golf/db_helper/DBHelper.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import 'bill_success_screen.dart';

class NotSentBills extends StatefulWidget {
  @override
  _NotSentBillsState createState() => _NotSentBillsState();
}

class _NotSentBillsState extends State<NotSentBills> {
  List<dynamic> formData = [];
  List<dynamic> formDataPrimaryKey = [];
  List<dynamic> formImages = [];
  List<dynamic> formVideos = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getNotSentBills();
  }

  Future<void> getNotSentBills() async {
    try {
      final billsData = Provider.of<Products>(context, listen: false);
      await billsData.getNotSentBills();
      formDataPrimaryKey = billsData.notSentBills
          .map((billMap) => billMap[DBHelper.BILL_ID_COL])
          .toList();
      formData = billsData.notSentBills
          .map((billMap) => json.decode(billMap[DBHelper.BILL_CONTENT_COL]))
          .toList();
      formImages = billsData.notSentBills
          .map((billMap) => json.decode(billMap[DBHelper.BILL_IMAGES_COL]))
          .toList();
      formVideos = billsData.notSentBills
          .map((billMap) => json.decode(billMap[DBHelper.BILL_VIDEOS_COL]))
          .toList();
      print('form Data: ' + formData.toString());
      print('form Data Key: ' + formDataPrimaryKey.toString());
      print('form images Key: ' + formImages.toString());
      print('form videos Key: ' + formVideos.toString());
    } catch (error) {
      Toast.show(
        error.toString(),
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  Future<void> _sendBill(int index) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final billsData = Provider.of<Products>(context, listen: false);
      await billsData.sendSavedBills(
        formData[index],
        formDataPrimaryKey[index],
        formImages[index],
        formVideos[index],
        index,
      );
      await getNotSentBills();
      Navigator.of(context).pushNamedAndRemoveUntil(
          BillSuccessScreen.ROUTE_NAME, ModalRoute.withName('/'));
      Toast.show(
        'تم إرسال المعاينة المحفوظة بنجاح',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print('_sendBill not sent bills catch error: ' + error.toString());
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('برجاء التأكد من وجود شبكة إنترنت');
    }
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

  @override
  Widget build(BuildContext context) {
    final billsData = Provider.of<Products>(context);
    final plumbersData = Provider.of<Plumbers>(context, listen: false);
    final merchantsData = Provider.of<Merchants>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: formDataPrimaryKey.length == 0
          ? Center(
              child: const Text(
                'لا يوجد معاينات محفوظة',
                style: kTableRowColumnTitleStyle,
              ),
            )
          : ListView.builder(
              itemCount: formDataPrimaryKey.length,
              itemBuilder: (context, i) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'إسم العميل: ' + formData[i]['clientName'],
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'رقم العميل: ' + formData[i]['clientPhone'],
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'إسم التاجر: ' +
                              merchantsData.findMerchantNameById(
                                  int.parse(formData[i]['merchantId'])),
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'رقم التاجر: ' +
                              merchantsData.findMerchantPhoneById(
                                  int.parse(formData[i]['merchantId'])),
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'إسم الفنى: ' +
                              plumbersData.findPlumberNameById(
                                  int.parse(formData[i]['plumberId'])),
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'رقم الفنى: ' +
                              plumbersData.findPlumberPhoneById(
                                  int.parse(formData[i]['plumberId'])),
                          style: kTableRowColumnTitleStyle,
                        ),
                        Text(
                          'رقم الفاتورة: ' + formData[i]['billNumber'],
                          style: kTableRowColumnTitleStyle,
                        ),
                        OutlineButton(
                          child: Text('إعادة الإرسال'),
                          textColor: mainColor,
                          onPressed: _isLoading
                              ? null
                              : () {
                                  _sendBill(i);
                                },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
