import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:golf/exceptions/auth_exception.dart';
import 'package:golf/utils/constants.dart';

import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  int id;
  String name;
  int typeId;
  String typeName;
  String govName;

  List<dynamic> rest;

  Future<bool> tryLogin() async {
    print("prefs");
    var a;
    SharedPreferences prefs;
    await SharedPreferences.getInstance().then((prefValue) {
      prefs = prefValue;
      print("ff");
      print(prefs.get("id"));
      a = prefValue.getInt('id') ?? false;
    });

    print("a");
    if (!prefs.containsKey('id')) {
      print('prefs doesn\'t contain id key');
      return false;
    } else {
      id = prefs.getInt('id');
      typeId = prefs.getInt('typeId');
      name = prefs.getString('name');
      typeName = prefs.getString('typeName');
      govName = prefs.getString('govName');
      rest = json.decode(prefs.getString(PREFS_REST_LIST_KEY));
      print(id.toString());
      print(typeId.toString());
      print(name.toString());
      notifyListeners();
      return true;
    }
  }

  bool isAuth() {
    return id != null;
  }

  Future<void> loginUser(String username, String password) async {
    try {
      Response response = await post('$API_URL/login', body: {
        'username': username,
        'password': password,
      });
      final Map<String, dynamic> decodedResponseBody =
          json.decode(response.body);
      if (response.statusCode >= 400) {
        throw AuthException(decodedResponseBody['message']);
      }
      print(decodedResponseBody);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      id = decodedResponseBody['id'];
      typeId = decodedResponseBody['typeId'];
      name = decodedResponseBody['name'];
      typeName = decodedResponseBody['type'];
      govName = decodedResponseBody['extraData']['gov']['name'];
      await getRests();

      print('rest response: ' + rest.toString());
      await prefs.setInt('id', id);
      print(prefs.get("id"));
      await prefs.setInt('typeId', typeId);
      await prefs.setString('name', name);
      await prefs.setString('typeName', typeName);
      await prefs.setString('govName', govName);
      await prefs.setString(PREFS_REST_LIST_KEY, json.encode(rest));
      await prefs.setBool('hasSynced', false);
      notifyListeners();
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  Future<void> getRests() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String url = '$API_URL/getRest/$id';
      Response response = await get(url);

      final decodedResponseBody = json.decode(response.body);
      print(decodedResponseBody.toString());
      rest = decodedResponseBody;
      await prefs.setString(PREFS_REST_LIST_KEY, json.encode(rest));
      notifyListeners();

      print('get rest response: ' + rest.toString());
    } catch (error) {
      print('get rests catch error: ' + error.toString());
      throw (error.toString());
    }
  }

  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('id');
    await prefs.remove('typeId');
    await prefs.remove('name');
    await prefs.remove('typeName');
    await prefs.remove('govName');
    await prefs.remove('hasSynced');

    id = null;
    name = null;
    typeId = null;
    typeName = null;
    govName = null;
    notifyListeners();
  }
}
