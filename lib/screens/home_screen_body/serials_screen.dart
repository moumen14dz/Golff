import 'package:flutter/material.dart';
import 'package:golf/screens/new_serial_screen.dart';
import 'package:golf/utils/constants.dart';

class SerialsScreen extends StatelessWidget {
  static const ROUTE_NAME = '/serialsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة السيريال'),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Text(
            'معرض الأمانة',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'العدد',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'بداية السيريال: 02030001',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'نهاية السيريال: 02030030',
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            'إسم المسؤول',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: mainColor,
        onPressed: () {
          Navigator.of(context).pushNamed(NewSerialScreen.ROUTE_NAME);
        },
      ),
    );
  }
}
