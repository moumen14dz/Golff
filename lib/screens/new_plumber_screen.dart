import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf/enums/image_type.dart';
import 'package:golf/models/governorate.dart';
import 'package:golf/models/plumber.dart';
import 'package:golf/providers/governorates.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewPlumberScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/newPlumberScreen';

  @override
  _NewPlumberScreenState createState() => _NewPlumberScreenState();
}

class _NewPlumberScreenState extends State<NewPlumberScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  TextEditingController _addressController = TextEditingController();

  File _storedImage;
  String img64;

  List<Governorate> _governorates = [];

  int _selectedGovernorateId;

  Plumber _plumber = Plumber(
    plumberName: '',
    plumberPhone: '',
    nationalId: '',
  );

  void pickImage(FileType imageType) async {
    final imagePicker = ImagePicker();
    PickedFile pickedFile;
    if (imageType == FileType.Camera) {
      pickedFile = await imagePicker.getImage(
        source: ImageSource.camera,
        maxWidth: 1000,
      );
    } else {
      pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
      );
    }
    setState(() {
      if (pickedFile != null) {
        _storedImage = File(pickedFile.path);
        final bytes = File(pickedFile.path).readAsBytesSync();
        img64 = base64Encode(bytes);
        print('base64 Image: ' + img64);
      } else {
        print('No image selected.');
        return;
      }
    });
  }

  void getGovernoratesData() async {
    final governoratesData = Provider.of<Governorates>(context, listen: false);
    await governoratesData.getGovernorates();
    _governorates = governoratesData.governorates;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getGovernoratesData();
  }

  @override
  void dispose() {
    super.dispose();
    _addressController.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid && img64 != null && _selectedGovernorateId != null) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      final plumbersData = Provider.of<Plumbers>(context, listen: false);
      try {
        final successMessage = await plumbersData.addPlumber(
          address: _addressController.text,
          nIdImage: img64,
          governorateId: _selectedGovernorateId,
          plumber: _plumber,
        );
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
        _showErrorDialog('برجاء التأكد من وجود شبكة إنترنت و أعد المحاولة');
      }
    } else {
      Toast.show(
        'برجاء إكمال باقى البيانات',
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
        title: Text('إضافة فنى'),
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
                      hintText: 'إسم الفنى',
                      labelText: 'إسم الفنى',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال إسم الفنى';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _plumber.plumberName = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'رقم التليفون',
                      labelText: 'رقم التليفون',
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال رقم التليفون';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _plumber.plumberPhone = text;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'الرقم القومى',
                      labelText: 'الرقم القومى',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال رقم الرقم القومى';
                      } else if (int.tryParse(text) == null) {
                        return 'برجاء إدخال رقم قومى صحيح';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _plumber.nationalId = text;
                    },
                  ),
                  DropdownButton(
                    value: _selectedGovernorateId,
                    hint: const Text('إختر المحافظة'),
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
                      });
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
                    controller: _addressController,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 250,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.white70)),
                    child: _storedImage == null
                        ? Center(
                            child: Text(
                              'إختر صورة',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : Image.file(_storedImage),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlineButton(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'فتح معرض الصور',
                              style: TextStyle(color: mainColor),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () {
                            pickImage(FileType.Gallery);
                          },
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: OutlineButton(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'فتح الكاميرا',
                              style: TextStyle(color: mainColor),
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onPressed: () {
                            pickImage(FileType.Camera);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
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
