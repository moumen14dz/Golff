import 'package:flutter/material.dart';
import 'package:golf/providers/auth.dart';
import 'package:golf/screens/home_screen_body/complaints_page.dart';
import 'package:golf/utils/constants.dart';

import 'package:provider/provider.dart';

class NavigationDrawer extends StatelessWidget {
  final Function selectedIndex;

  NavigationDrawer(this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context, listen: false);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 8,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 100,
                    width: 100,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    Provider.of<Auth>(context).name,
                    style: kTableRowColumnTitleStyle,
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text('الصفحة الرئيسية'),
              onTap: () {
                selectedIndex(0);
              },
            ),
            if (authData.typeId == 1 ||
                authData.typeId == 4 ||
                authData.typeId == 5 ||
                authData.typeId == 6)
              ListTile(
                title: Text('قائمة التجار'),
                onTap: () {
                  selectedIndex(1);
                },
              ),
            ListTile(
              title: Text('عروض و مسابقات'),
              onTap: () {
                selectedIndex(2);
              },
            ),
            if (authData.typeId != 2)
              ListTile(
                title: Text('قائمة الأسعار'),
                onTap: () {
                  selectedIndex(3);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 4 ||
                authData.typeId == 5 ||
                authData.typeId == 6)
              ListTile(
                title: Text('قائمة الموزعين'),
                onTap: () {
                  selectedIndex(4);
                },
              ),
            if (authData.typeId == 1 || authData.typeId == 6)
              ListTile(
                title: Text('قائمة مديرين المبيعات'),
                onTap: () {
                  selectedIndex(5);
                },
              ),
            if (authData.typeId == 1 || authData.typeId == 6)
              ListTile(
                title: Text('قائمة مديرين خدمة العملاء'),
                onTap: () {
                  selectedIndex(6);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 3 ||
                authData.typeId == 6)
              ListTile(
                title: Text('قائمة مناديب خدمة العملاء'),
                onTap: () {
                  selectedIndex(7);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 5 ||
                authData.typeId == 6)
              ListTile(
                title: Text('قائمة مناديب المبيعات'),
                onTap: () {
                  selectedIndex(8);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 2 ||
                authData.typeId == 3)
              ListTile(
                title: Text('المعاينة'),
                onTap: () {
                  selectedIndex(9);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 2 ||
                authData.typeId == 3)
              ListTile(
                title: Text('المعاينات المحفوظة'),
                onTap: () {
                  selectedIndex(10);
                },
              ),
            if (authData.typeId == 1 ||
                authData.typeId == 2 ||
                authData.typeId == 3 ||
                authData.typeId == 6)
              ListTile(
                title: Text('الفنيين'),
                onTap: () {
                  selectedIndex(11);
                },
              ),
            ListTile(
              title: Text('الشكاوى و الإقتراحات'),
              onTap: () {
                Navigator.of(context).pushNamed(ComplaintsPage.ROUTE_NAME);
              },
            ),
            ListTile(
              title: Text('تسجيل خروج'),
              onTap: () async {
                Navigator.of(context).pop();
                await Provider.of<Auth>(context, listen: false).logoutUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}
