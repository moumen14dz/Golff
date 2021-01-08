import 'package:flutter/material.dart';
import 'package:golf/utils/constants.dart';

class NewSerialScreen extends StatelessWidget {
  static const ROUTE_NAME = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة سيريال التاجر'),
        backgroundColor: mainColor,
      ),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'بداية السيريال',
                  labelText: 'بداية السيريال',
                ),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'العدد',
                  labelText: 'العدد',
                ),
                keyboardType: TextInputType.number,
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
                  onPressed: () {
                    //_saveForm();
                    //Navigator.of(context).pop();
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
