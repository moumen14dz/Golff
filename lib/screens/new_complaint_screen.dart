import 'package:flutter/material.dart';
import 'package:golf/providers/complaints.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewComplaintScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newComplaintScreen';

  @override
  _NewComplaintScreenState createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _selectedComplaintTypeId;
  int _selectedUserId;

  String _complaintTitle = '';
  String _complaintMessage = '';

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      await Provider.of<Complaints>(context, listen: false).getUsers();
    } catch (error) {
      print(error.toString());
      _showErrorDialog('برجاء التأكد من شبكة الإنترنت');
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

  void _saveForm() async {
    final isValid = _formKey.currentState.validate();
    if (isValid) {
      try {
        setState(() {
          _isLoading = true;
        });
        _formKey.currentState.save();
        final complaintResult =
            await Provider.of<Complaints>(context, listen: false).sendComplaint(
          _complaintTitle,
          _selectedComplaintTypeId,
          _selectedUserId,
          _complaintMessage,
        );
        setState(() {
          _isLoading = false;
        });
        Toast.show(
          complaintResult,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
        Navigator.of(context).pop();
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('برجاء التأكد من شبكة الإنترنت');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintsData = Provider.of<Complaints>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة شكوى'),
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
                      hintText: 'عنوان الشكوى',
                      labelText: 'عنوان الشكوى',
                    ),
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال عنوان الشكوى';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _complaintTitle = text;
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  DropdownButton<int>(
                    hint: Text(
                      "نوع الطلب",
                      textAlign: TextAlign.center,
                    ),
                    value: _selectedComplaintTypeId,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem<int>(
                        child: Text('شكوي'),
                        value: 0,
                      ),
                      DropdownMenuItem<int>(
                        child: Text('طلب'),
                        value: 1,
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedComplaintTypeId = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  DropdownButton<int>(
                    hint: Text(
                      "مرسل إلى",
                      textAlign: TextAlign.center,
                    ),
                    value: _selectedUserId,
                    isExpanded: true,
                    items: complaintsData.users
                        .map((user) => DropdownMenuItem<int>(
                              child: Center(
                                child: Text('${user.name} | ${user.phone}'),
                              ),
                              value: user.id,
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: 'تفاصيل الشكوى'),
                    minLines: 3,
                    maxLines: 10,
                    textInputAction: TextInputAction.newline,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال تفاصيل الشكوى';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (text) {
                      _complaintMessage = text;
                    },
                  ),
                  SizedBox(
                    height: 32.0,
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
