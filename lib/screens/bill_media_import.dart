import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity/connectivity.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:golf/enums/image_type.dart';
import 'package:golf/exceptions/products_exception.dart';
import 'package:golf/providers/products.dart';
import 'package:golf/utils/constants.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'bill_success_screen.dart';

class BillMediaImport extends StatefulWidget {
  static const ROUTE_NAME = '/billMediaImport';

  @override
  _BillMediaImportState createState() => _BillMediaImportState();
}

class _BillMediaImportState extends State<BillMediaImport> {
  Map<String, dynamic> _formInputData;
  File _storedFile;
  String img64;

  List<File> _videos = [];
  List<String> _videosPaths = <String>[];
  List<File> _savedVideos = [];
  List<Uint8List> _videoPreviewImages = [];
  List<File> _imageFiles = [];
  List<String> _imagesBase64 = [];

  bool _isLoading = false;

  Future<bool> isInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Mobile data detected & internet connection confirmed.
        return true;
      } else {
        // Mobile data detected but no internet connection found.
        return false;
      }
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a WIFI network, make sure there is actually a net connection.
      if (await DataConnectionChecker().hasConnection) {
        // Wifi detected & internet connection confirmed.
        return true;
      } else {
        // Wifi detected but no internet connection found.
        return false;
      }
    } else {
      // Neither mobile data or WIFI detected, not internet connection found.
      return false;
    }
  }

  void showMediaDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'إختر الوسيلة',
              style: kMainTitleStyle,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('إلتقاط صورة'),
                  leading: Icon(
                    Icons.camera_alt,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickFile(FileType.Camera);
                  },
                ),
                ListTile(
                  title: Text('إلتقاط فيديو'),
                  leading: Icon(
                    Icons.videocam,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickFile(FileType.Video);
                  },
                ),
                ListTile(
                  title: Text('معرض الصور'),
                  leading: Icon(
                    Icons.photo,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    pickFile(FileType.Gallery);
                  },
                ),
              ],
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('إلغاء'))
            ],
          );
        });
  }

  void pickFile(FileType fileType) async {
    final imagePicker = ImagePicker();
    PickedFile pickedFile;
    if (fileType == FileType.Camera) {
      // Camera Part
      pickedFile = await imagePicker.getImage(
        source: ImageSource.camera,
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          _storedFile = File(pickedFile.path);
          final bytes = File(pickedFile.path).readAsBytesSync();
          img64 = base64Encode(bytes);
          setState(() {
            _imageFiles.add(_storedFile);
            _imagesBase64.add(img64);
          });
          print(img64);
        } else {
          print('No image selected.');
          return;
        }
      });
    } else if (fileType == FileType.Gallery) {
      // Gallery Part
      pickedFile = await imagePicker.getImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
      );
      setState(() {
        if (pickedFile != null) {
          _storedFile = File(pickedFile.path);
          final bytes = File(pickedFile.path).readAsBytesSync();
          img64 = base64Encode(bytes);
          setState(() {
            _imageFiles.add(_storedFile);
            _imagesBase64.add(img64);
          });
          print(img64);
        } else {
          print('No image selected.');
          return;
        }
      });
    } else if (fileType == FileType.Video) {
      // Video Part
      pickedFile = await imagePicker.getVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: 30),
      );
      if (pickedFile != null) {
        setState(() {
          _storedFile = File(pickedFile.path);
        });
        _videosPaths.add(_storedFile.path);
        _videos.add(_storedFile);
        final appDir = await getApplicationDocumentsDirectory();
        final videoFileName = basename(_storedFile.path);
        File savedVideo =
            await _storedFile.copy('${appDir.path}/$videoFileName');
        _savedVideos.add(savedVideo);
        final uint8list = await VideoThumbnail.thumbnailData(
          video: _storedFile.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 100,
          // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
          quality: 25,
        );
        setState(() {
          _videoPreviewImages.add(uint8list);
        });
      } else {
        print('No Video Recorded.');
        return;
      }
    }
  }

  void _showErrorDialog(String errorMessage, BuildContext context) {
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

  void _sendBillRequest(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });
      bool isInternetAvailable = await isInternet();
      if (isInternetAvailable) {
        // final billsData = Provider.of<Products>(context, listen: false);
        // await billsData.getNotSentBills();
        await Provider.of<Products>(context, listen: false).sendBill(
            _formInputData, _imagesBase64, _savedVideos, isInternetAvailable);
        Toast.show(
          'تم إرسال المعاينة بنجاح',
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
            BillSuccessScreen.ROUTE_NAME, ModalRoute.withName('/'));
      } else {
        await Provider.of<Products>(context, listen: false).sendBill(
            _formInputData, _imagesBase64, _savedVideos, isInternetAvailable);
        Toast.show(
          'تم حفظ المعاينة فى المعاينات المحفوظة',
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.of(context).popUntil(ModalRoute.withName('/'));
      }
    } on ProductsException catch (error) {
      print('send bill media import Products catch error: ' + error.message);
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error.message, context);
    } catch (error) {
      print('send bill media import catch error: ' + error);
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(error, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _formInputData = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة وسائط'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'الصور',
                style: kTableRowColumnTitleStyle,
              ),
              Container(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, i) {
                    return Image.file(
                      _imageFiles[i],
                      width: 100,
                      height: 100,
                    );
                  },
                ),
              ),
              Divider(),
              Text(
                'الفيديوهات',
                style: kTableRowColumnTitleStyle,
              ),
              Container(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  itemCount: _videoPreviewImages.length,
                  itemBuilder: (context, i) {
                    return Image.memory(
                      _videoPreviewImages[i],
                      width: 100,
                      height: 100,
                    );
                  },
                ),
              ),
              OutlineButton.icon(
                label: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'إضافة وسائط',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.add,
                    color: mainColor,
                  ),
                ),
                textColor: mainColor,
                onPressed: () {
                  showMediaDialog(context);
                },
              ),
              SizedBox(
                height: 32,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 54,
                child: RaisedButton(
                  child: Text(
                    'إرسال المعاينة',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: mainColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: _isLoading
                      ? null
                      : () {
                          _sendBillRequest(context);
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
