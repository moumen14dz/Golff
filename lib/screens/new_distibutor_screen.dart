import 'dart:math';

import 'package:flutter/material.dart';
import 'package:golf/models/distributor.dart';
import 'package:golf/providers/distributors.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewDistributorScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newDistributorScreen';

  @override
  _NewDistributorScreenState createState() => _NewDistributorScreenState();
}

class _NewDistributorScreenState extends State<NewDistributorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedDistributorCat;

  List<DistributorCat> _distributorCat = [];

  Distributor _distributor = Distributor(
    id: Random().nextInt(99999),
    code: '0006',
    shopName: '',
    distributorName: null,
    respName: null,
    lat: 0,
    lon: 0,
    telephoneNumber: null,
    address: '',
    categoryId: null,
  );

  @override
  void initState() {
    super.initState();
    getDistributorCatData();
  }

  Future<void> getDistributorCatData() async {
    final merchantData = Provider.of<Distributors>(context, listen: false);
    await merchantData.getDistributorCat();
    _distributorCat = merchantData.distributorCat;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid && _selectedDistributorCat != null) {
      setState(() {
        // _isLocated = false;
        _isLoading = true;
      });
      final distributorsData =
          Provider.of<Distributors>(context, listen: false);
      _formKey.currentState.save();
      try {
        final successMessage = await distributorsData.addDistributor(
          _distributor,
          _selectedDistributorCat,
        );
        // await _locateCurrentPosition(); Transferred to Provider Class
        Toast.show(
          successMessage,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(error.toString());
      }
    }
    if (_selectedDistributorCat == null) {
      Toast.show(
        'برجاء إدخال تصنيف الموزع مع باقى البيانات',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('عطل'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة موزع جديد',
        ),
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'إسم المحل',
                      labelText: 'إسم المحل',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال إسم المحل';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _distributor.shopName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'إسم الموزع',
                      labelText: 'إسم الموزع',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال إسم الموزع';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _distributor.distributorName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'إسم المسؤول',
                      labelText: 'إسم المسؤول',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال إسم المسؤول';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _distributor.respName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'رقم تليفون المسؤول',
                      labelText: 'رقم تليفون المسؤول',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال رقم تليفون المسؤول';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _distributor.telephoneNumber = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'العنوان',
                      labelText: 'العنوان',
                    ),
                    maxLines: 5,
                    minLines: 3,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال العنوان';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _distributor.address = text;
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  DropdownButton(
                    value: _selectedDistributorCat,
                    hint: const Text('إختر التصنيف'),
                    isExpanded: true,
                    items: _distributorCat
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.title),
                          ),
                        )
                        .toList(),
                    onChanged: (i) {
                      setState(() {
                        _selectedDistributorCat = i;
                      });
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 54,
                    child: RaisedButton(
                      child: Text(
                        'حفظ',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onPressed: _isLoading ? null : _saveForm,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
