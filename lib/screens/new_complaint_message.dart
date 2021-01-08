import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:golf/providers/complaints.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewComplaintMessageScreen extends StatefulWidget {
  static const String ROUTE_NAME = '/newComplaintMessageScreen';

  @override
  _NewComplaintMessageScreenState createState() =>
      _NewComplaintMessageScreenState();
}

class _NewComplaintMessageScreenState extends State<NewComplaintMessageScreen> {
  TextEditingController _newMessageController = TextEditingController();
  bool _isLoading = false;
  bool _isSending = false;

  int _complaintId;

  @override
  void initState() {
    super.initState();
    getMessages();
  }

  Future<void> getMessages() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Complaints>(context, listen: false)
          .getComplaintMessages();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> _sendComplaintMessage() async {
    try {
      setState(() {
        _isSending = true;
      });
      final successMessage =
          await Provider.of<Complaints>(context, listen: false)
              .sendComplaintMessage(_complaintId, _newMessageController.text);
      Toast.show(
        successMessage,
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
      );
      setState(() {
        _newMessageController.text = '';
        _isSending = false;
      });
    } catch (error) {
      setState(() {
        _isSending = false;
      });
      print(error.toString());
      _showErrorDialog('برجاء التأكد من شبكة الإنترنت');
    }
  }

  @override
  Widget build(BuildContext context) {
    _complaintId = ModalRoute.of(context).settings.arguments;
    final complaintsData = Provider.of<Complaints>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل'),
        backgroundColor: mainColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
                : ListView.builder(
                    itemCount: complaintsData.complaintMessages.length,
                    itemBuilder: (context, i) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                complaintsData.complaintMessages[i].createdBy,
                                style: kTableRowColumnTitleStyle,
                                textAlign: TextAlign.start,
                              ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          complaintsData
                                              .complaintMessages[i].text,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "${complaintsData.complaintMessages[i].date}",
                                              style: TextStyle(
                                                color: Colors.yellow[700],
                                                // fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ));
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _isSending
                ? Center(
                    child: Text('جارى إرسال الرسالة...'),
                  )
                : TextField(
                    controller: _newMessageController,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.black12,
                      hintText: 'إرسال رسالة',
                      suffixIcon: InkWell(
                        onTap: () async {
                          if (_newMessageController.text.isNotEmpty) {
                            // Send Message Here
                            await _sendComplaintMessage();
                          }
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
