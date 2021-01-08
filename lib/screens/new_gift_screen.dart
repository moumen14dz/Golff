import 'package:flutter/material.dart';
import 'package:golf/models/gift.dart';
import 'package:golf/providers/gifts.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewGiftScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newGiftScreen';

  @override
  _NewGiftScreenState createState() => _NewGiftScreenState();
}

class _NewGiftScreenState extends State<NewGiftScreen> {
  TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Gift> _gifts = [];

  int _selectedValue;

  int _merchantDistId;
  int _type;

  @override
  void initState() {
    super.initState();
    getGiftsData();
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

  void getGiftsData() async {
    final giftsData = Provider.of<Gifts>(context, listen: false);
    try {
      await giftsData.getGifts();
      _gifts = giftsData.gifts;
      setState(() {});
    } catch (error) {
      _showErrorDialog(
          'برجاء التأكد من جودة الإتصال بالإنترنت ثم أعد المحاولة');
    }
  }

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid &&
        _selectedValue != null &&
        _type != null &&
        _merchantDistId != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        final giftsData = Provider.of<Gifts>(context, listen: false);
        final successMessage = await giftsData.sendGift(
          type: _type,
          merchantDistId: _merchantDistId,
          giftId: _selectedValue,
          notes: _notesController.text,
        );
        setState(() {
          _isLoading = false;
          _notesController.text = '';
          _selectedValue = null;
        });

        Toast.show(
          successMessage,
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.CENTER,
        );
      } catch (error) {
        print(error.toString());
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog(
            'برجاء التأكد من جودة الإتصال بالإنترنت ثم أعد المحاولة');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _merchantDistId = args['id'];
    _type = args['type'];
    print('type: ' + _type.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة هدية'),
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownButton(
                  isExpanded: true,
                  value: _selectedValue,
                  hint: Text('إختر الهدية'),
                  items: _gifts
                      .map((item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.title),
                          ))
                      .toList(),
                  onChanged: (item) {
                    setState(() {
                      _selectedValue = item;
                    });
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'ملاحظات',
                  ),
                  minLines: 5,
                  maxLines: 8,
                  controller: _notesController,
                  validator: (text) {
                    if (text.isEmpty) {
                      return 'برجاء إدخال الملاحظات';
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
                    onPressed: _isLoading ? null : _saveForm,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
