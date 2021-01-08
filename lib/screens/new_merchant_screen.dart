import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:geolocator/geolocator.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewMerchantScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newMerchantScreen';

  @override
  _NewMerchantScreenState createState() => _NewMerchantScreenState();
}

class _NewMerchantScreenState extends State<NewMerchantScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedMerchantCat;
  int _selectedDistId = 0;

  List<MerchantCat> _merchantCat = [];
  List<DistributorType> _distributorTypes = [];

  // TextEditingController _merchantNameController = TextEditingController();
  // TextEditingController _respNameController = TextEditingController();
  // TextEditingController _phoneNumberController = TextEditingController();

  Merchant _merchant = Merchant(
    id: 0,
    code: '',
    shopName: '',
    merchantName: null,
    respName: null,
    lat: 0,
    lon: 0,
    telephoneNumber: null,
    categoryId: null,
  );

  @override
  void initState() {
    super.initState();
    getMerchantCatData();
    getDistributorType();
  }

  Future<void> getMerchantCatData() async {
    final merchantData = Provider.of<Merchants>(context, listen: false);
    await merchantData.getMerchantCat();
    _merchantCat = merchantData.merchantCat;
    setState(() {});
  }

  Future<void> getDistributorType() async {
    final merchantData = Provider.of<Merchants>(context, listen: false);
    await merchantData.getDistributorType();
    _distributorTypes = merchantData.distributorTypes;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid && _selectedMerchantCat != null) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      final merchantsData = Provider.of<Merchants>(context, listen: false);
      try {
        final successMessage =
            await merchantsData.addMerchant(_merchant, _selectedDistId);
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

  Future<void> _locateCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      _merchant.lon = position.longitude;
      _merchant.lat = position.latitude;
      print(_merchant.lon);
      print(_merchant.lat);
    } on PermissionDeniedException {
      // Exception thrown when trying to request the device's location
      // when the user denied access.
      _showErrorDialog(
          'لقد رفضت السماح لإذن أخذ موقعك الحالى, لحل المشكلة برجاء الدخول على الإعدادات الخاصة بهاتفك و الذهاب لاعدادات التطبيقات و السماح لهذا التطبيق بأخذ موقعك');
    } on LocationServiceDisabledException {
      // Exception thrown when when the user allowed access,
      // but the location services of the device are disabled.
      _showErrorDialog(
          'خدمة تحديد الموقع غير مفعلة على هاتفك برجاء تفعيلها و إعادة المحاولة');
    } catch (error) {
      _showErrorDialog('حدث عطل مفاجئ. برجاء إعادة المحاولة فى وقت لاحق');
    }
  }

  Future<void> _getLastKnownPosition() async {
    // Position position = await Geolocator.getLastKnownPosition();
    // if (position.longitude != null && position.latitude != null) {
    //   print(
    //       'Last know position: ${position.longitude} and ${position.latitude}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة تاجر جديد',
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
                      _merchant.shopName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'إسم التاجر',
                      labelText: 'إسم التاجر',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال إسم التاجر';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _merchant.merchantName = text;
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
                      _merchant.respName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'رقم تليفون المسؤول',
                      labelText: 'رقم تليفون المسؤول',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال رقم تليفون المسؤول';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _merchant.telephoneNumber = text;
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
                      _merchant.address = text;
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  DropdownButton(
                    value: _selectedMerchantCat,
                    hint: const Text('إختر التصنيف'),
                    isExpanded: true,
                    items: _merchantCat
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.title),
                          ),
                        )
                        .toList(),
                    onChanged: (i) {
                      setState(() {
                        _selectedMerchantCat = i;
                        _merchant.categoryId = _selectedMerchantCat;
                      });
                    },
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  DropdownButton(
                    value: _selectedDistId,
                    isExpanded: true,
                    items: _distributorTypes
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.title),
                          ),
                        )
                        .toList(),
                    onChanged: (i) {
                      setState(() {
                        _selectedDistId = i;
                      });
                    },
                  ),
                  SizedBox(
                    height: 24,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
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
