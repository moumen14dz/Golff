import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golf/enums/image_type.dart';
import 'package:golf/providers/plumbers.dart';
import 'package:golf/screens/suggested_gifts_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class SendPlumberGift extends StatefulWidget {
  static const ROUTE_NAME = '/sendPlumberGift';

  @override
  _SendPlumberGiftState createState() => _SendPlumberGiftState();
}

class _SendPlumberGiftState extends State<SendPlumberGift> {
  TextEditingController _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  File _storedImage;
  String img64 = '';

  String _giftId;
  int _plumberId;

  bool _isLoading = false;

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

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      final plumbersData = Provider.of<Plumbers>(context, listen: false);
      try {
        final successMessage = await plumbersData.sendGift(
          image: img64 ?? '',
          notes: _notesController.text,
          giftId: _giftId,
          plumberId: _plumberId,
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
  void dispose() {
    super.dispose();
    _notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _giftId = args['giftId'].toString();
    _plumberId = args['plumberId'];
    return Scaffold(
      appBar: AppBar(
        title: Text('إرسال ' + args['giftName'].toString()),
        backgroundColor: mainColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'ملاحظات',
                    labelText: 'ملاحظات',
                  ),
                  keyboardType: TextInputType.text,
                  controller: _notesController,
                  minLines: 3,
                  maxLines: 10,
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال الملاحظات';
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
                            'إختر صورة (إختيارى)',
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
                        borderRadius: BorderRadius.circular(8)),
                    onPressed: _isLoading ? null : _saveForm,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
