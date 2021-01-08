import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/providers/complaints.dart';
import 'package:golf/screens/new_complaint_message.dart';
import 'package:golf/screens/new_complaint_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class ComplaintsPage extends StatefulWidget {
  static const String ROUTE_NAME = '/complaintsPage';

  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getComplaints();
  }

  Future<void> getComplaints() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Complaints>(context, listen: false).getComplaints();
      setState(() {
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    final complaintsData = Provider.of<Complaints>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الشكاوى و المقترحات'),
        backgroundColor: mainColor,
      ),
      body: _isLoading
          ? SpinKitDoubleBounce(
              color: Colors.white,
              size: 50.0,
            )
          : ListView.builder(
              itemCount: complaintsData.complaints.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        NewComplaintMessageScreen.ROUTE_NAME,
                        arguments: complaintsData.complaints[i].id,
                      );
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "${complaintsData.complaints[i].title}",
                              style: kMainTitleStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "انشاءه بمعرفة : ",
                                  style: kTableRowColumnTitleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${complaintsData.complaints[i].createdBy}",
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "مقدم الى : ",
                                  style: kTableRowColumnTitleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${complaintsData.complaints[i].createdTo}",
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "تاريخ : ",
                                  style: kTableRowColumnTitleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${complaintsData.complaints[i].date}",
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "نوع المذكره : ",
                                  style: kTableRowColumnTitleStyle,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "${complaintsData.complaints[i].type}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'إضافة شكوى',
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: mainColor,
        onPressed: () {
          Navigator.of(context).pushNamed(NewComplaintScreen.ROUTE_NAME);
        },
      ),
    );
  }
}
