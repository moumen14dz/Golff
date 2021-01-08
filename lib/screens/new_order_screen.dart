import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf/enums/image_type.dart';
import 'package:golf/models/order.dart';
import 'package:golf/providers/orders.dart';
import 'package:golf/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewOrdersScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newOrdersScreen';

  @override
  _NewOrdersScreenState createState() => _NewOrdersScreenState();
}

class _NewOrdersScreenState extends State<NewOrdersScreen> {
  TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File _storedImage;
  String img64;

  bool isLoading = false;

  int _merchantDistId;
  int _type;

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
        print(img64);
      } else {
        print('No image selected.');
        return;
      }
    });
  }

  Future<void> _saveForm(BuildContext context) async {
    bool isValid = _formKey.currentState.validate();
    if (isValid && _storedImage != null) {
      setState(() {
        isLoading = true;
      });
      final ordersData = Provider.of<Orders>(context, listen: false);
      try {
        final message = await ordersData.sendOrder(
          order:
              Order(amount: double.parse(_amountController.text), image: img64),
          type: _type,
          merchantDistId: _merchantDistId,
        );
        Toast.show(
          message,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        setState(() {
          isLoading = false;
          _amountController.text = '';
          _storedImage = null;
        });
        print('Done');
      } catch (error) {
        setState(() {
          isLoading = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('عطل'),
              content: Text('برجاء التحقق من شبكة الإنترنت و إعادة المحاولة'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _merchantDistId = args['id'];
    _type = args['type'];
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة طلبية'),
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'قيمة الطلبية',
                      labelText: 'قيمة الطلبية',
                    ),
                    keyboardType: TextInputType.number,
                    controller: _amountController,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'أدخل قيمة الطلبية';
                      } else if (double.tryParse(text) == null) {
                        return 'برجاء إدخال قيمة صحيحة';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
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
                    height: 32,
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
                      onPressed: isLoading
                          ? null
                          : () {
                              _saveForm(context);
                              //Navigator.of(context).pop();
                            },
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
