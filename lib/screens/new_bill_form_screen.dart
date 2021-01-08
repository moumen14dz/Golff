import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/enums/image_type.dart';
import 'package:golf/models/district.dart';
import 'package:golf/models/governorate.dart';
import 'package:golf/models/merchant.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/providers/districts.dart';
import 'package:golf/providers/governorates.dart';
import 'package:golf/providers/merchants.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/screens/new_bill_categories_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class NewBillFormScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newBillFormScreen';

  @override
  _NewBillFormScreenState createState() => _NewBillFormScreenState();
}

class _NewBillFormScreenState extends State<NewBillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _merchantSearchController = TextEditingController();
  TextEditingController _plumberSearchController = TextEditingController();
  FocusNode _clientPhoneNode = FocusNode();
  FocusNode _addressNode = FocusNode();

  List<Merchant> _merchants = [];
  List<Merchant> _filteredMerchants = [];

  List<Plumber> _plumbers = [];
  List<Plumber> _filteredPlumbers = [];

  List<Governorate> _governorates = [];
  List<District> _districts = [];

  bool _districtsLoading = false;

  Merchant _selectedMerchant;
  Plumber _selectedPlumber;

  int _selectedGovernorateId;
  int _selectedDistrictId;

  Map<String, dynamic> _screen1Data = {
    'clientName': null,
    'clientPhone': null,
    'merchant': null,
    'plumber': null,
    'billNumber': null,
    'governorateId': null,
    'districtId': null,
    'governorateName': null,
    'districtName': null,
    'address': null,
    'elevators': null,
    'bathrooms': null,
    'kitchens': null,
  };

  // bool isInternetAvailable = true;

  @override
  void initState() {
    super.initState();
    getGovernoratesData();
    // isInternet();
  }

  @override
  void dispose() {
    super.dispose();
    _clientPhoneNode.dispose();
    _merchantSearchController.dispose();
    _plumberSearchController.dispose();
  }

  // Future<void> isInternet() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     // I am connected to a mobile network, make sure there is actually a net connection.
  //     if (await DataConnectionChecker().hasConnection) {
  //       // Mobile data detected & internet connection confirmed.
  //       isInternetAvailable = true;
  //     } else {
  //       // Mobile data detected but no internet connection found.
  //       isInternetAvailable = false;
  //     }
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     // I am connected to a WIFI network, make sure there is actually a net connection.
  //     if (await DataConnectionChecker().hasConnection) {
  //       // Wifi detected & internet connection confirmed.
  //       isInternetAvailable = true;
  //     } else {
  //       // Wifi detected but no internet connection found.
  //       isInternetAvailable = false;
  //     }
  //   } else {
  //     // Neither mobile data or WIFI detected, not internet connection found.
  //     isInternetAvailable = false;
  //   }
  //   setState(() {});
  // }

  void getGovernoratesData() async {
    final governoratesData = Provider.of<Governorates>(context, listen: false);
    await governoratesData.getGovernorates(false);
    _governorates = governoratesData.governorates;
    setState(() {});
  }

  Future<void> getDistrictsData() async {
    setState(() {
      _districtsLoading = true;
    });
    final districtsData = Provider.of<Districts>(context, listen: false);
    districtsData.districts.clear();
    _districts.clear();
    _selectedDistrictId = null;
    await districtsData.getDistricts(_selectedGovernorateId, false);
    // _districts = !isInternetAvailable
    //     ? districtsData.tempDistricts
    //         .where((district) => district.govId == _selectedGovernorateId)
    //         .toList()
    //     : districtsData.districts;
    _districts = districtsData.tempDistricts
        .where((district) => district.govId == _selectedGovernorateId)
        .toList();
    setState(() {
      _districtsLoading = false;
    });
  }

  void onMerchantSearchTextChanged(String searchText) {
    _filteredMerchants.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _merchants.forEach((item) {
      if (item.merchantName.contains(searchText.trim()) ||
          item.telephoneNumber.contains(searchText.trim())) {
        _filteredMerchants.add(item);
      }
    });
    setState(() {});
  }

  void onPlumberSearchTextChanged(String searchText) {
    _filteredPlumbers.clear();
    if (searchText.trim().isEmpty) {
      setState(() {});
      return;
    }
    _plumbers.forEach((item) {
      if (item.plumberName.contains(searchText.trim()) ||
          item.plumberPhone.contains(searchText.trim())) {
        _filteredPlumbers.add(item);
      }
    });
    setState(() {});
  }

  void _showMerchantBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Icon(Icons.horizontal_rule),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث',
                      suffixIcon: _merchantSearchController.text.isEmpty
                          ? Icon(Icons.search)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _filteredMerchants.clear();
                                  _merchantSearchController.text = '';
                                });
                              },
                            ),
                    ),
                    textDirection: TextDirection.rtl,
                    controller: _merchantSearchController,
                    onChanged: onMerchantSearchTextChanged,
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: Provider.of<Merchants>(context, listen: false)
                        .getMerchants(false),
                    builder: (context, snapshot) => snapshot.connectionState ==
                            ConnectionState.waiting
                        ? Center(
                            child: SpinKitDoubleBounce(
                              color: Colors.white,
                              size: 50.0,
                            ),
                          )
                        : Consumer<Merchants>(
                            builder: (context, merchantsData, ch) {
                              _merchants = merchantsData.merchants;
                              if (_filteredMerchants.isEmpty) {
                                if (_merchantSearchController.text.isNotEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.yellowAccent,
                                        ),
                                        Text('لم يتم العثور على شئ.'),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount: merchantsData.merchants.length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        title: Text(merchantsData
                                            .merchants[i].merchantName),
                                        subtitle: Text(merchantsData
                                            .merchants[i].telephoneNumber),
                                        onTap: () {
                                          setState(() {
                                            _selectedMerchant =
                                                merchantsData.merchants[i];
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      );
                                    },
                                  );
                                }
                              } else {
                                return ListView.builder(
                                  itemCount: _filteredMerchants.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Text(
                                            _filteredMerchants[i].merchantName),
                                        subtitle: Text(_filteredMerchants[i]
                                            .telephoneNumber),
                                        onTap: () {
                                          setState(() {
                                            _selectedMerchant =
                                                _filteredMerchants[i];
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        textColor: Colors.red[600],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('إلغاء'),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPlumberBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SizedBox(
                  height: 24,
                ),
                Icon(Icons.horizontal_rule),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث',
                      suffixIcon: _plumberSearchController.text.isEmpty
                          ? Icon(Icons.search)
                          : IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _filteredPlumbers.clear();
                                  _plumberSearchController.text = '';
                                });
                              },
                            ),
                    ),
                    textDirection: TextDirection.rtl,
                    controller: _plumberSearchController,
                    onChanged: onPlumberSearchTextChanged,
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: Provider.of<Plumbers>(context, listen: false)
                        .getPlumbers(false, false),
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
                                if (_plumberSearchController.text.isNotEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.yellowAccent,
                                        ),
                                        Text('لم يتم العثور على شئ.'),
                                      ],
                                    ),
                                  );
                                } else {
                                  return ListView.builder(
                                    itemCount: plumbersData.plumbers.length,
                                    itemBuilder: (context, i) {
                                      return ListTile(
                                        title: Text(plumbersData
                                            .plumbers[i].plumberName),
                                        subtitle: Text(plumbersData
                                            .plumbers[i].plumberPhone),
                                        onTap: () {
                                          setState(() {
                                            _selectedPlumber =
                                                plumbersData.plumbers[i];
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      );
                                    },
                                  );
                                }
                              } else {
                                return ListView.builder(
                                  itemCount: _filteredPlumbers.length,
                                  itemBuilder: (context, i) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        title: Text(
                                            _filteredPlumbers[i].plumberName),
                                        subtitle: Text(
                                            _filteredPlumbers[i].plumberPhone),
                                        onTap: () {
                                          setState(() {
                                            _selectedPlumber =
                                                _filteredPlumbers[i];
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlineButton(
                        textColor: Colors.red[600],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('إلغاء'),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveForm() {
    bool isValid = _formKey.currentState.validate();
    if (isValid &&
        _selectedGovernorateId != null &&
        _selectedDistrictId != null &&
        _selectedMerchant != null &&
        _selectedPlumber != null &&
        _selectedGovernorateId != null &&
        _selectedDistrictId != null) {
      _formKey.currentState.save();
      _screen1Data['governorateId'] = _selectedGovernorateId;
      print(_screen1Data['governorateId']);
      _screen1Data['merchant'] = _selectedMerchant;
      print(_selectedMerchant.merchantName);
      _screen1Data['plumber'] = _selectedPlumber;
      print(_selectedPlumber.plumberName);
      print(_screen1Data['governorateId']);
      _screen1Data['districtId'] = _selectedDistrictId;
      print(_screen1Data['districtId']);
      _screen1Data['governorateName'] = _governorates
          .firstWhere((governorate) => governorate.id == _selectedGovernorateId)
          .name;
      print(_screen1Data['governorateName']);
      _screen1Data['districtName'] = _districts
          .firstWhere((district) => district.id == _selectedDistrictId)
          .title;
      print(_screen1Data['districtName']);
      Navigator.of(context).pushNamed(
        NewBillCategoriesScreen.ROUTE_NAME,
        arguments: _screen1Data,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة البيانات الأساسية'),
        backgroundColor: mainColor,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'بيانات العميل',
                    style: kMainTitleStyle,
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'إسم العميل',
                    labelText: 'إسم العميل',
                  ),
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال إسم العميل';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  onSaved: (text) {
                    _screen1Data['clientName'] = text;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'رقم تليفون العميل',
                    labelText: 'رقم تليفون العميل',
                  ),
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال رقم تليفون العميل';
                    } else if (text.length < 11) {
                      return 'برجاء إدخال إحدى عشر رقما أو اكثر';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onSaved: (text) {
                    _screen1Data['clientPhone'] = text;
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.white,
                ),
                Center(
                  child: Text(
                    'بيانات التاجر',
                    style: kMainTitleStyle,
                  ),
                ),
                Table(
                  border: TableBorder(
                      horizontalInside: BorderSide(
                    width: 1,
                    color: Colors.black26,
                  )),
                  children: [
                    TableRow(children: [
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
                        child: Text(_selectedMerchant == null
                            ? ''
                            : _selectedMerchant.merchantName),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم التاجر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_selectedMerchant == null
                            ? ''
                            : _selectedMerchant.telephoneNumber),
                      ),
                    ]),
                  ],
                ),
                Center(
                  child: OutlineButton(
                    onPressed: () {
                      _showMerchantBottomSheet();
                    },
                    child: Text('إختيار التاجر'),
                    textColor: mainColor,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  color: Colors.white,
                ),
                Center(
                  child: Text(
                    'بيانات الفنى',
                    style: kMainTitleStyle,
                  ),
                ),
                Table(
                  border: TableBorder(
                      horizontalInside: BorderSide(
                    width: 1,
                    color: Colors.black26,
                  )),
                  children: [
                    TableRow(children: [
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
                        child: Text(_selectedPlumber == null
                            ? ''
                            : _selectedPlumber.plumberName),
                      ),
                    ]),
                    TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'رقم الفنى',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_selectedPlumber == null
                            ? ''
                            : _selectedPlumber.plumberPhone),
                      ),
                    ]),
                  ],
                ),
                Center(
                  child: OutlineButton(
                    onPressed: () {
                      _showPlumberBottomSheet();
                    },
                    child: Text('إختيار الفنى'),
                    textColor: mainColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButton(
                          value: _selectedGovernorateId,
                          hint: const Text('المحافظة'),
                          isExpanded: true,
                          items: _governorates
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(),
                          onChanged: (i) {
                            setState(() {
                              _selectedGovernorateId = i;
                              _districtsLoading = true;
                            });
                            getDistrictsData();
                          },
                          onTap: () {},
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: _districtsLoading
                            ? SpinKitDoubleBounce(
                                color: Colors.white,
                                size: 50.0,
                              )
                            : DropdownButton(
                                value: _selectedDistrictId,
                                hint: const Text('المنطقة'),
                                isExpanded: true,
                                items: _districts
                                    .map(
                                      (item) => DropdownMenuItem(
                                        value: item.id,
                                        child: Text(item.title),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (i) {
                                  setState(() {
                                    _selectedDistrictId = i;
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'رقم شهادة الضمان',
                    labelText: 'رقم شهادة الضمان',
                  ),
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال رقم الفاتورة';
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (text) {
                    FocusScope.of(context).requestFocus(_addressNode);
                  },
                  onSaved: (text) {
                    _screen1Data['billNumber'] = text;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'العنوان',
                    labelText: 'العنوان',
                  ),
                  minLines: 3,
                  maxLines: 10,
                  focusNode: _addressNode,
                  keyboardType: TextInputType.text,
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال العنوان';
                    } else {
                      return null;
                    }
                  },
                  onSaved: (text) {
                    _screen1Data['address'] = text;
                  },
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'صاعد',
                          labelText: 'صاعد',
                        ),
                        validator: (text) {
                          if (text.isEmpty) {
                            return 'برجاء إدخال رقم الصاعد';
                          } else if (int.tryParse(text) == null) {
                            return 'برجاء إدخال أرقام صحيحة';
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSaved: (text) {
                          _screen1Data['elevators'] = text;
                        },
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.black12,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'حمام',
                          labelText: 'حمام',
                        ),
                        validator: (text) {
                          if (text.isEmpty) {
                            return 'برجاء إدخال عدد الحمامات';
                          } else if (int.tryParse(text) == null) {
                            return 'برجاء إدخال أرقام صحيحة';
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSaved: (text) {
                          _screen1Data['bathrooms'] = text;
                        },
                      ),
                    ),
                    VerticalDivider(
                      color: Colors.black12,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'مطبخ',
                          labelText: 'مطبخ',
                        ),
                        validator: (text) {
                          if (text.isEmpty) {
                            return 'برجاء إدخال عدد المطابخ';
                          } else if (int.tryParse(text) == null) {
                            return 'برجاء إدخال أرقام صحيحة';
                          } else {
                            return null;
                          }
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onSaved: (text) {
                          _screen1Data['kitchens'] = text;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                RaisedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'التالى',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  color: mainColor,
                  onPressed: _saveForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
