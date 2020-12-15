import 'dart:convert';

import 'package:f_todo/model/model.dart';
import 'package:f_todo/model/user_token.dart';
import 'package:f_todo/todo.dart';
import 'package:flutter/services.dart';

class CalendarPlugin {
  static const MethodChannel _channel = const MethodChannel('calendar_plugin');
  static Future<User> mscLogin() async {
    try {
      var result = await _channel.invokeMethod('login', null);
      var jsonMap = json.decode(result);
      var userToken = MscToken.fromJson(jsonMap);
      var mscUser = User(
        expiresIn: userToken.expiresIn,
        token: userToken.accessToken,
        loginTime: DateTime.now(),
      );
      Log.debug("msc login result: $result");
      return mscUser;
    } catch (e) {
      Log.debug("exception: $e");
    }
    return null;
  }
}
