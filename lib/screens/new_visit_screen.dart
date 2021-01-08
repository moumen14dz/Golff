import 'package:flutter/material.dart';
import 'package:golf/models/visit.dart';
import 'package:golf/providers/visits.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

class NewVisitScreen extends StatefulWidget {
  static const ROUTE_NAME = '/newVisitScreen';

  @override
  _NewVisitScreenState createState() => _NewVisitScreenState();
}

class _NewVisitScreenState extends State<NewVisitScreen> {
  TextEditingController _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<VisitTypeMenu> _visitsTypeMenu = [];
  List<VisitResultMenu> _visitsResultMenu = [];

  int _visitTypeSelectedValue;
  int _visitResultSelectedValue;

  int _merchantDistId;
  int _type;

  @override
  void initState() {
    super.initState();
    getVisitsData();
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

  void getVisitsData() async {
    final visitsData = Provider.of<Visits>(context, listen: false);
    try {
      await visitsData.getVisitsType();
      await visitsData.getVisitsResult();
      _visitsTypeMenu = visitsData.visitsType;
      _visitsResultMenu = visitsData.visitsResult;
      setState(() {});
    } catch (error) {
      _showErrorDialog(
          'برجاء التأكد من جودة الإتصال بالإنترنت ثم أعد المحاولة');
    }
  }

  Future<void> _saveForm() async {
    bool isValid = _formKey.currentState.validate();
    if (isValid &&
        _visitTypeSelectedValue != null &&
        _visitResultSelectedValue != null &&
        _type != null &&
        _merchantDistId != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        final visitsData = Provider.of<Visits>(context, listen: false);
        final successMessage = await visitsData.sendVisit(
            type: _type,
            merchantDistId: _merchantDistId,
            visitResultMenu: VisitResultMenu(id: _visitResultSelectedValue),
            visitTypeMenu: VisitTypeMenu(id: _visitTypeSelectedValue),
            desc: _descController.text);
        setState(() {
          _isLoading = false;
          _descController.text = '';
          _visitTypeSelectedValue = null;
          _visitResultSelectedValue = null;
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
    } else {
      Toast.show(
        'برجاء إدخال البيانات كاملة و إعادة المحاولة',
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;
    _merchantDistId = args['id'];
    _type = args['type'];
    return Scaffold(
      appBar: AppBar(
        title: Text('عمل زيارة'),
        backgroundColor: mainColor,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButton(
                hint: Text('نوع الزيارة'),
                value: _visitTypeSelectedValue,
                isExpanded: true,
                items: _visitsTypeMenu
                    .map(
                      (item) => DropdownMenuItem(
                        child: Text(item.title),
                        value: item.id,
                      ),
                    )
                    .toList(),
                onChanged: (i) {
                  setState(() {
                    _visitTypeSelectedValue = i;
                  });
                },
              ),
              SizedBox(
                height: 8,
              ),
              DropdownButton(
                hint: Text('نتيجة الزيارة'),
                value: _visitResultSelectedValue,
                isExpanded: true,
                items: _visitsResultMenu
                    .map(
                      (item) => DropdownMenuItem(
                        child: Text(item.title),
                        value: item.id,
                      ),
                    )
                    .toList(),
                onChanged: (i) {
                  setState(() {
                    _visitResultSelectedValue = i;
                  });
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'تفاصيل الزيارة',
                ),
                minLines: 3,
                maxLines: 10,
                controller: _descController,
                validator: (text) {
                  if (text.isEmpty) {
                    return 'برجاء إدخال تفاصيل الزيارة';
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
    );
  }
}
