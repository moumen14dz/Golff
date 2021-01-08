import 'package:flutter/material.dart';
import 'package:golf/exceptions/auth_exception.dart';
import 'package:golf/providers/auth.dart';
import 'package:golf/screens/home_screen.dart';
import 'package:golf/utils/constants.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const ROUTE_NAME = '/loginRoute';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _passwordFocusNode = FocusNode();
  bool _visiblePassword = true;

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

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
                setState(() {
                  _isLoading = false;
                });
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
    bool isValid = _formKey.currentState.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      try {
        final authData = Provider.of<Auth>(context, listen: false);
        await authData.loginUser(
            _usernameController.text, _passwordController.text);
        print('Login Successful');
      } on AuthException catch (error) {
        print("eee");
        _showErrorDialog(error.message);
      } catch (error) {
        print("fff");
        _showErrorDialog(error.toString());
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 32,
                  ),
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    height: 150,
                  ),
                  SizedBox(
                    height: 32,
                  ),
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'رقم المستخدم',
                      labelText: 'رقم المستخدم',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    controller: _usernameController,
                    onFieldSubmitted: (_) {
                      _passwordFocusNode.requestFocus();
                    },
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال رقم المستخدم';
                      } else if (int.tryParse(text) == null) {
                        return 'برجاء إدخال الرقم صحيح';
                      } else {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      labelText: 'كلمة المرور',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _visiblePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _visiblePassword = !_visiblePassword;
                          });
                        },
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    focusNode: _passwordFocusNode,
                    obscureText: _visiblePassword,
                    controller: _passwordController,
                    validator: (text) {
                      if (text.isEmpty) {
                        return 'برجاء إدخال كلمة المرور';
                      } else {
                        return null;
                      }
                    },
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 54,
                    child: RaisedButton(
                      child: Text(
                        'دخول',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: mainColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onPressed: _isLoading
                          ? null
                          : () {
                              _saveForm();
                            },
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
