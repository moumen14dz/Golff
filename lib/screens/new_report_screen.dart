import 'package:flutter/material.dart';
import 'package:golf/providers/reports.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewReportScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newReportScreen';

  @override
  _NewReportScreenState createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  TextEditingController _reportTitleController = TextEditingController();
  TextEditingController _reportDetailsController = TextEditingController();
  int _senderId;
  bool isLoading;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      final message =
          await Provider.of<Reports>(context, listen: false).sendReport(
        _reportTitleController.text,
        _reportDetailsController.text,
        _senderId,
      );
      setState(() {
        _reportTitleController.text = '';
        _reportDetailsController.text = '';
      });
      Toast.show(
        message,
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _reportTitleController.dispose();
    _reportDetailsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _senderId = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('إضافة تقرير جديد'),
        backgroundColor: mainColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'عنوان التقرير',
                  labelText: 'عنوان التقرير',
                ),
                controller: _reportTitleController,
                validator: (text) {
                  if (text.isEmpty) {
                    return 'برجاء إدخال عنوان التقرير';
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'تفاصيل التقرير',
                ),
                minLines: 3,
                maxLines: 10,
                controller: _reportDetailsController,
                validator: (text) {
                  if (text.isEmpty) {
                    return 'برجاء إدخال تفاصيل التقرير';
                  } else {
                    return null;
                  }
                },
              ),
              Spacer(),
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
                  onPressed: _saveForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
